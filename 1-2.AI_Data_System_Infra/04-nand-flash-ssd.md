# AIDS 4주차 — NAND Flash SSD SoC Architecture

> 2026.10.03 (토) · AI 데이터 시스템 및 인프라 (김영재 교수)
> 주제: 반도체 기반 스토리지 — SSD 장단점, 임베디드 스토리지(eMMC/UFS), Interface vs Protocol(SATA/SAS/PCIe/NVMe), NAND cell 구조

---

## 0. 한눈에 보기

| 구분 | 핵심 |
|---|---|
| 왜 I/O인가 | AI Training은 dataset read, Inference는 KV Cache 저장, DB·과학 시뮬레이션도 I/O 집약적임 |
| HDD → SSD | 기계 부품 없음 + NAND die 병렬 처리 → SATA 대역폭(600MB/s)이 병목이 됨 → PCIe/NVMe 등장 |
| 임베디드 | eMMC(parallel, half-duplex, 느림) → UFS(serial, full-duplex, multi-lane, command queue) |
| Interface vs Protocol | SATA·SAS는 interface이자 protocol, PCIe는 interface이고 그 위 protocol이 NVMe임 |
| PCH | SATA 장치는 PCH 경유(DMI 공유), NVMe SSD는 CPU PCIe lane에 직결 가능 |
| NAND cell | Floating gate에 전자를 가두면 Vth↑ → 0, 비어 있으면 1. 전원 꺼져도 유지(non-volatile) |
| SLC~QLC | cell당 bit 수↑ → 용량↑, 가격↓ / 속도↓, P/E cycle↓ (100K → 10K → 3K → 1K) |
| Array | Page = 한 word line = read/program 단위, Block = page 묶음 = erase 단위 |

---

## 1. 스토리지 I/O가 중요한 이유 — 응용 워크로드

| 워크로드 | I/O 특성 |
|---|---|
| AI Training | 학습 데이터를 계속 읽어야 함. CNN이면 이미지 파일 수백만 개를 반복해서 read → 작은 파일 random read 많음 |
| AI Inference | 생성되는 output token마다 Key/Value를 **KV Cache**로 저장함. 문맥이 길어질수록 커져서 GPU 메모리를 넘으면 CPU 메모리·SSD로 offload해야 함 (1주차 KV cache 내용과 연결) |
| Database | AI 이전부터 대표적인 I/O 집약 응용임 |
| Scientific Simulation | CFD(Computational Fluid Dynamics), 열역학 시뮬레이션 등은 수일~수주 돌아감 → 중간에 시스템 failure가 나도 재시작할 수 있게 주기적으로 **checkpointing** → 대용량 write가 몰아서 발생함 |

---

## 2. HDD → SSD

### 2.1 SSD 장점

- **기계 부품이 없음** → seek time, rotational latency가 없음 → random I/O에서 압도적임
  - HDD: 수백 IOPS 수준 / SSD: 수십만~백만 IOPS 수준
- **내부 병렬성**: SSD 안에는 NAND die가 여러 개 붙어 있고, controller가 여러 channel/way로 동시에 접근함 → 내부에서 뽑아낼 수 있는 bandwidth가 매우 높음
- **저전력** → 전력을 적게 먹으면 열도 적게 발생함 → 냉각 부담↓
- 충격에 강하고 소음 없음

### 2.2 SSD 단점

- GB당 가격이 HDD보다 비쌈
- **수명 제한**: cell마다 P/E(Program/Erase) 횟수가 정해져 있음 (6장)
- **Erase-before-write**: 덮어쓰기가 안 되고 지운 뒤에 써야 하며, 지우는 단위(block)가 쓰는 단위(page)보다 큼 → 이를 숨기기 위해 SSD 내부에 FTL, GC 같은 관리 로직이 필요함
- 마모가 진행될수록, 온도가 높을수록 데이터 retention이 짧아짐

### 2.3 인터페이스가 병목이 됨

- HDD가 낼 수 있는 sequential 대역폭은 100~200MB/s 수준 → SATA 3(6Gbps, 실효 600MB/s)으로 충분했음
- SSD는 NAND die 병렬 처리로 내부 bandwidth가 SATA 상한을 훌쩍 넘음 → **SATA를 그대로 쓸 수 없음** → PCIe 기반 NVMe로 넘어감

```
SATA 3 실효 대역폭
  6 Gbps × (8/10)  ← 8b/10b encoding: 10bit 보내서 8bit만 실제 데이터
= 4.8 Gbps
= 4.8 / 8 = 600 MB/s
```

---

## 3. 임베디드 스토리지: eMMC vs UFS

**임베디드 스토리지** = NAND 칩과 controller를 하나의 패키지로 묶어 기기 메인보드에 직접 납땜(실장)한 형태임. 스마트폰, 태블릿, IoT 기기, 카메라 등에 들어감. 탈착식 SD 카드와 달리 기기에 내장됨.

### 3.1 eMMC (embedded MultiMediaCard)

- **8-bit parallel bus**, **half-duplex** (read와 write를 동시에 못 함), single channel
- 성능이 느림 → 과거 디지털 카메라, 저가 스마트폰, 현재는 IoT·스마트워치·셋톱박스 등에 사용

| 버전 | 모드 | 최대 interface 속도 |
|---|---|---|
| 4.41 | DDR52 | ~104 MB/s |
| 4.5 | HS200 | ~200 MB/s |
| 5.0 / 5.1 | HS400 | ~400 MB/s |

- **HS400 = DDR(Double Data Rate)**: clock이 올라갈 때(rising edge)와 내려갈 때(falling edge) 모두 데이터를 보냄 → 같은 clock에서 bandwidth 2배
- **Command queuing**: 원래 없었음. low-bandwidth 스토리지 용도라 필요가 없었기 때문임. eMMC 5.1에서 CMDQ가 뒤늦게 추가됨

### 3.2 UFS (Universal Flash Storage)

- JEDEC 표준, 현재 스마트폰의 주력 스토리지
- **serial**, **full-duplex** (read/write 동시), **multi-lane** (보통 2 lane)
- 물리 계층은 MIPI M-PHY, 전송 계층은 UniPro, command는 SCSI 기반
- **Command queue 지원** (queue depth 32)
- **DRAM-less**: 모바일 기기에서 DRAM은 비싼 자원임 → 스토리지 장치 자체에 DRAM을 두지 않고 NAND + controller(내부 SRAM)만 가짐
  - 참고: 매핑 테이블을 담을 DRAM이 없어서 생기는 성능 손실은 HPB(Host Performance Booster)로 host(AP)의 DRAM 일부를 빌려 보완함

| 버전 | Gear | Sequential read (대략) |
|---|---|---|
| UFS 2.x | HS-G3 × 2 lane | ~1.2 GB/s (이론) |
| UFS 3.x | HS-G4 × 2 lane | ~2.1 GB/s |
| UFS 4.0 | HS-G5 × 2 lane | ~4.2 GB/s |

### 3.3 Parallel인데 왜 더 느린가

직관적으로는 병렬(parallel)이 직렬(serial)보다 빠를 것 같지만 반대임.

- **eMMC = 차선은 많지만 각 차선이 느린 도로**: 8개 선으로 동시에 보내지만 각 선의 속도가 낮음
- **UFS = 차선은 적지만 초고속 고속도로**: lane 수는 적어도 lane 하나가 Gbps급임

Parallel bus는 clock을 올리면 선마다 신호 도착 시간이 어긋나는 skew, 선끼리 간섭하는 crosstalk 문제가 커져서 고속화에 한계가 있음. 그래서 고속 인터페이스는 거의 다 serial(차동 신호)로 갔음 — SATA(←PATA), PCIe(←PCI), UFS(←eMMC) 모두 같은 흐름임.

### 3.4 Command Queuing이 필요한 이유

```
[Queue 없음]
CMD1 ──실행──▶ complete ─▶ CMD2 ──실행──▶ complete ─▶ CMD3 ...
→ 모든 read/write I/O가 직렬화됨. 장치 내부 die가 여러 개여도 1개만 일함

[Queue 있음]
CMD1 ┐
CMD2 ├─▶ 장치에 동시에 여러 개 대기 ─▶ 내부 die에 분산·재정렬해서 병렬 처리
CMD3 ┘
```

장치 내부 병렬성이 높아질수록(UFS, SSD) 한 번에 여러 command를 넘겨줘야 그 병렬성을 다 쓸 수 있음 → UFS로 넘어오면서 command queue가 필수가 됨.

### 3.5 eMMC vs UFS 비교

| 항목 | eMMC | UFS |
|---|---|---|
| 신호 방식 | Parallel (8-bit) | Serial (차동 신호) |
| Duplex | Half-duplex | Full-duplex |
| Lane/Channel | Single | Multi-lane (2) |
| Command queue | 없음 (5.1에서 CMDQ 추가) | 기본 지원 (depth 32) |
| 최대 속도 | ~400 MB/s | ~4.2 GB/s (4.0) |
| 주 용도 | IoT, 스마트워치, 저가 기기 | 스마트폰, 태블릿 |

### 3.6 디바이스 분류

| 장치 | 분류 | 저장 매체 | 주 용도 |
|---|---|---|---|
| eMMC | 임베디드 | NAND | IoT, 스마트워치 (UFS보다 느림) |
| UFS | 임베디드 | NAND | 스마트폰 |
| SSD | 범용 | NAND | PC, 서버 |
| HDD | 범용 | 자기 디스크 | PC, 서버, 대용량 저장 |

임베디드 기기 종류에 따라 어떤 인터페이스·표준을 쓰는지가 달라짐. HDD와 SSD는 임베디드에 특화된 장치가 아니라 일반 범용 컴퓨터용임.

---

## 4. Interface vs Protocol — SATA, SAS, PCIe, NVMe

- **Interface**: host 쪽 controller와 장치 쪽 controller를 잇는 물리적·전기적 연결 규격 (SATA, SAS, PCIe)
- **Protocol**: 그 연결 위에서 어떤 command를 어떤 방식으로 주고받을지 정한 규약 (AHCI/ATA, SCSI, NVMe)
- **SATA, SAS는 interface이자 protocol**이라고 함 (규격 안에 command 체계까지 포함)
- **PCIe는 interface**, 그 위에서 스토리지용으로 쓰는 **protocol이 NVMe**임

### 4.1 SATA vs SAS vs NVMe

| 항목 | SATA | SAS | NVMe (over PCIe) |
|---|---|---|---|
| 풀네임 | Serial ATA | Serial Attached SCSI | Non-Volatile Memory Express |
| 대상 | Consumer / Desktop | Enterprise / Datacenter | 둘 다 (현재 주력) |
| 속도 | 6 Gbps (SATA 3) | 12 Gbps (SAS-3), 22.5 Gbps (SAS-4) | PCIe lane 수 × 세대별 속도 |
| Duplex | Half | Full | Full |
| Port | Single | Dual (한쪽 경로 장애 시 failover) | — |
| Command set | ATA (AHCI) | SCSI | NVMe |
| Queue | **1개 × depth 32** | device당 depth ~254 | **최대 64K개 × depth 64K** |

- SAS controller에는 SATA 드라이브도 꽂을 수 있지만 반대는 안 됨
- **NVMe queue**: 스펙상으로는 I/O queue를 약 65,535개, queue마다 65,536개 command까지 만들 수 있음. 실제로는 그렇게 많이 쓰지 않고 8개 정도만 쓰는 경우가 많음. 보통 CPU core마다 Submission Queue / Completion Queue 쌍을 하나씩 둬서 core 간 lock 경합 없이 I/O를 넣음
- AHCI는 HDD 시절 설계라 queue 1개면 충분했음. SSD의 내부 병렬성을 다 쓰려면 queue가 훨씬 많아야 해서 NVMe가 새로 만들어짐

### 4.2 Encoding

직렬 전송에서는 데이터를 그대로 보내지 않고 encoding해서 보냄 → 0/1이 한쪽으로 몰리지 않게(DC balance) 하고, 수신 측이 신호 전환으로 clock을 복원할 수 있게 해서 **신뢰성 있는 전송**을 하기 위함임.

| 방식 | 사용처 | 효율 |
|---|---|---|
| 8b/10b | SATA, SAS-3, PCIe Gen1/2 | 80% (20% overhead) |
| 128b/130b | PCIe Gen3 이상 | ~98.5% |

---

## 5. PCIe 대역폭과 PCH

### 5.1 PCIe 대역폭

PCIe는 **lane** 단위로 구성되고, lane마다 링크 속도가 있음 → **대역폭 = lane당 속도 × lane 수**

| 세대 | 전송률 | Lane당 (단방향) | x4 (NVMe SSD 일반적) |
|---|---|---|---|
| Gen3 | 8 GT/s | ~0.985 GB/s | ~3.9 GB/s |
| Gen4 | 16 GT/s | ~1.97 GB/s | ~7.9 GB/s |
| Gen5 | 32 GT/s | ~3.94 GB/s | ~15.8 GB/s |

```
PCIe Gen4 x4 계산
  16 GT/s × (128/130) ≈ 15.75 Gbps   ← lane 1개
  15.75 / 8 ≈ 1.97 GB/s
  × 4 lane ≈ 7.88 GB/s
```

### 5.2 PCH (Platform Controller Hub)

```
            ┌────────────┐
            │    CPU     │──── PCIe lane (직결) ──── NVMe SSD, GPU
            └─────┬──────┘
                  │ DMI (Direct Media Interface)
            ┌─────┴──────┐
            │    PCH     │──── SATA HDD/SSD
            │            │──── LAN card
            │            │──── USB ports, 기타 장치
            └────────────┘
```

- 기존 HDD는 PCH의 SATA 포트에 꽂혔고, PCH는 CPU와 **DMI**로 연결됨
- PCH에는 LAN card, USB 등 여러 장치가 같이 붙어 있음 → 이 장치들이 **DMI 대역폭을 나눠 씀** (DMI 3.0 ≈ PCIe 3.0 x4 ≈ 3.9GB/s)
- NVMe SSD는 CPU의 PCIe lane에 직접 붙일 수 있음 → 경유 단계가 줄어 latency↓, 대역폭을 독점함

---

## 6. NAND Cell 기초

### 6.1 MOSFET

- **MOS** = Metal-Oxide-Semiconductor, 금속-산화막-반도체 구조
- **MOSFET** = MOS Field-Effect Transistor. Gate에 전압을 걸면 아래 반도체에 channel이 생겨 source ↔ drain으로 전류가 흐르는 스위치임
- DRAM과 NAND 모두 MOSFET 기반이지만 bit를 저장하는 방식이 다름

### 6.2 DRAM vs NAND

| 항목 | DRAM | NAND Flash |
|---|---|---|
| 저장 방식 | 1T1C — capacitor에 전하 저장 | Floating gate(또는 charge trap)에 전자를 가둠 |
| 휘발성 | Volatile — 전원 끄면 소멸 | Non-volatile — 전원 없어도 유지 |
| 유지 시간 | capacitor 전하가 새서 **64ms 이내 refresh** 필요 | 수 년 이상 (마모·온도에 따라 감소) |
| 접근 단위 | Byte 단위 | Page 단위 read/program, Block 단위 erase |
| 속도 | ns 수준 | read 수십 µs, program 수백 µs, erase ms 수준 |
| 내구성 | 사실상 무제한 | P/E cycle 제한 |

### 6.3 bit 저장 원리

NAND cell은 MOSFET의 gate 사이에 **절연막으로 둘러싸인 floating gate**가 하나 더 있는 구조임.

```
     Control Gate  ← Word Line에 연결
   ─────────────────
     절연막 (ONO)
   ─────────────────
     Floating Gate ← 전자를 가두는 곳
   ─────────────────
     Tunnel Oxide  ← 전자가 통과하는 얇은 산화막
   ═════════════════
  Source  Substrate  Drain
```

| 동작 | 방법 | 결과 |
|---|---|---|
| **Program** | Control gate(word line)에 고전압(~20V) → 전자가 tunnel oxide를 뚫고(F-N tunneling) floating gate에 갇힘 | Vth(문턱 전압) ↑ → **0** |
| **Erase** | Substrate(well)에 고전압 → floating gate의 전자를 빼냄 (block 단위) | Vth ↓ → **1** |
| **Read** | Word line에 기준 전압을 걸고 cell이 켜지는지(전류가 흐르는지) sensing | 전자 많음 → 안 켜짐 → 0 / 전자 적음 → 켜짐 → 1 |

- 단순화하면: cell에 전자가 50% 이상 차 있으면 0, 50% 미만이면 1 (SLC 기준)
- Erase된 상태가 1, program된 상태가 0임
- 어떤 전압을 어디에 거느냐에 따라 program, read, erase가 결정됨

### 6.4 SLC / MLC / TLC / QLC

한 cell의 전자량을 더 잘게 나눠 구분하면 cell 하나에 여러 bit를 저장할 수 있음. **n bit 저장 → 구분해야 할 상태 수 = 2ⁿ**

| 종류 | bit/cell | Vth 상태 수 | P/E cycle (대략) |
|---|---|---|---|
| SLC (Single-Level Cell) | 1 | 2 | ~100,000 |
| MLC (Multi-Level Cell) | 2 | 4 | ~10,000 (SLC의 1/10) |
| TLC (Triple-Level Cell) | 3 | 8 | ~3,000 (MLC의 약 1/3) |
| QLC (Quad-Level Cell) | 4 | 16 | ~1,000 |

- SLC는 cell당 1bit만 저장함. cell 하나에 multi-bit를 저장하는 기술이 MLC 이상임
- **Trade-off**: 같은 전압 범위를 더 잘게 나누니 상태 간 간격(margin)이 좁아짐
  - 정밀하게 sensing·program 해야 해서 **느려짐**
  - 작은 전자 누설에도 다른 값으로 읽힘 → **error↑**
  - 조금만 마모돼도 구분이 안 됨 → **P/E cycle↓**
  - 대신 같은 면적에 **용량↑, GB당 가격↓**
- bit 수는 1→4로 4배인데 구분할 상태는 2→16으로 8배 늘어남 → 난이도가 지수적으로 올라감

### 6.5 P/E cycle과 aging

- Program/Erase는 전자를 채웠다가 빼냈다가를 반복하는 것임
- 그때마다 전자가 tunnel oxide를 통과하면서 산화막이 조금씩 손상됨 (aging effect)
- 손상이 쌓이면 전자가 새거나 잘 안 빠져서 Vth 분포가 퍼짐 → 결국 0/1 구분 불가
- 그래서 cell당 P/E 횟수가 제한되고, 특정 block만 닳지 않게 고르게 쓰는 wear leveling이 필요해짐

### 6.6 NAND Array 구조

```
           BL0      BL1      BL2     ← Bit Line (세로)
            │        │        │
  WL0 ──── [■] ──── [■] ──── [■] ─── ┐ Page 0
  WL1 ──── [■] ──── [■] ──── [■] ─── │ Page 1
  WL2 ──── [■] ──── [■] ──── [■] ─── │ Page 2     Block
   ⋮         ⋮        ⋮        ⋮       │  ⋮       (erase 단위)
  WLn ──── [■] ──── [■] ──── [■] ─── ┘ Page n
            │        │        │
           GND      GND      GND
   (■ = 메모리 cell, 세로로 직렬 연결된 한 줄 = NAND string)
```

- **NAND string**: cell들이 bit line을 따라 직렬로 연결됨 → 회로 모양이 NAND gate와 같아서 NAND라는 이름이 붙음
- **Word line**: 같은 행에 있는 cell들의 control gate를 묶은 선
- **Page**: 한 word line에 연결된 cell 묶음. 그 word line에 전압을 걸면 해당 cell들에 한꺼번에 전자가 trap됨 → **read/program 단위** (수 KB~16KB)
- **Block**: 여러 page를 묶은 단위 → **erase 단위** (수 MB). substrate가 block 단위로 공유돼서 지울 때는 통째로 지워짐
- **Read 동작**: 읽을 word line에만 기준 전압을 걸고, 나머지 word line에는 무조건 켜지는 pass 전압을 걸음 → string에 전류가 흐르는지가 선택된 cell 하나에 의해서만 결정됨

---

## 7. 계산·수식 정리

| 항목 | 식 |
|---|---|
| SATA 3 실효 대역폭 | 6 Gbps × 8/10 ÷ 8 = **600 MB/s** |
| PCIe 대역폭 | 전송률(GT/s) × encoding 효율 × lane 수 ÷ 8 |
| PCIe Gen4 x4 | 16 × 128/130 × 4 ÷ 8 ≈ **7.88 GB/s** |
| DDR 효과 | rising + falling edge 전송 → 같은 clock에서 2배 |
| cell 상태 수 | n bit/cell → **2ⁿ** 상태 |
| DRAM refresh 주기 | **64 ms** 이내 |

---

## 8. 용어 정리

| 용어 | 뜻 |
|---|---|
| eMMC | embedded MultiMediaCard. parallel, half-duplex 임베디드 스토리지 |
| UFS | Universal Flash Storage. serial, full-duplex, multi-lane 임베디드 스토리지 |
| DRAM-less | 장치 내부에 DRAM 없이 NAND + controller만 가진 구조 |
| HS400 | eMMC 5.x 고속 모드. DDR 방식으로 ~400MB/s |
| Command Queuing | 여러 command를 장치에 동시에 넘겨 병렬·재정렬 처리하게 하는 기능 |
| SATA | Serial ATA. consumer용 interface/protocol, AHCI queue 1×32 |
| SAS | Serial Attached SCSI. enterprise용, dual port, full-duplex |
| PCIe | lane 기반 고속 serial interface |
| NVMe | PCIe 위에서 동작하는 SSD용 protocol. 다중 queue |
| PCH | Platform Controller Hub. SATA·LAN·USB 등이 붙는 칩셋 |
| DMI | Direct Media Interface. CPU ↔ PCH 연결 |
| MOSFET | Metal-Oxide-Semiconductor Field-Effect Transistor |
| Floating Gate | 절연막에 둘러싸여 전자를 가두는 NAND cell의 저장층 |
| Vth | Threshold Voltage, cell이 켜지는 문턱 전압 |
| P/E Cycle | Program/Erase 반복 가능 횟수 = NAND 수명 지표 |
| Page / Block | read·program 단위 / erase 단위 |
| Checkpointing | 장시간 연산 중간 상태를 주기적으로 저장해 failure 시 복구하는 기법 |

---

## 9. 셀프 체크

- [ ] HDD 시절엔 SATA로 충분했는데 SSD에서 SATA가 병목이 된 이유를 설명할 수 있는가
- [ ] SATA 3가 6Gbps인데 실효 600MB/s인 이유를 계산할 수 있는가
- [ ] eMMC가 parallel인데도 serial인 UFS보다 느린 이유를 설명할 수 있는가
- [ ] eMMC에는 command queue가 원래 없었고 UFS에서는 필수가 된 이유는?
- [ ] HS400의 DDR이 bandwidth를 2배로 만드는 원리는?
- [ ] Interface와 Protocol의 차이를 SATA, PCIe/NVMe 예시로 설명할 수 있는가
- [ ] AHCI(1×32)와 NVMe(64K×64K) queue 구조 차이가 SSD 성능에 왜 중요한가
- [ ] PCIe Gen4 x4 대역폭을 계산할 수 있는가
- [ ] SATA 장치가 PCH를 경유할 때와 NVMe가 CPU에 직결될 때의 차이는?
- [ ] DRAM은 왜 refresh가 필요하고 NAND는 왜 전원 없이 데이터가 유지되는가
- [ ] Program / Erase / Read 시 각각 어디에 전압을 걸고 Vth가 어떻게 변하는가
- [ ] SLC → QLC로 갈수록 용량은 늘지만 속도·수명이 줄어드는 이유는?
- [ ] P/E cycle이 제한되는 물리적 이유(aging)는?
- [ ] Page와 Block이 각각 무엇의 단위이며, 왜 erase 단위가 더 큰가