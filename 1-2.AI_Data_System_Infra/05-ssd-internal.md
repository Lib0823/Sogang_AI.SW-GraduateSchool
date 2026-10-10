# AIDS 5주차 — SSD 내부 구조: NAND Program/Erase, Flash Controller, Channel/Way

> 2026.10.10 (토) · AI 데이터 시스템 및 인프라 (김영재 교수)
> 주제: 시스템 안에서 SSD의 위치(버스·메모리 대역폭), CPU vs GPU와 데이터 경로, NAND의 Program/Erase 비대칭, Page/Block, Flash Controller와 Channel/Way 병렬성, SLC~QLC, "SSD = 하나의 컴퓨터"
> 4주차(NAND cell 구조, SLC~QLC 기초)의 연장선이며, 다음 시간 로그 기반 파일 시스템(LFS)·SSD 최적화로 이어짐

---

## 0. 한눈에 보기

| 구분 | 핵심 |
|---|---|
| 시스템 구조 | CPU·메모리·저장장치는 모두 **버스**(고속도로)에 붙음. 메모리 대역폭 = channel당 대역폭 × channel 수 |
| SSD 시장 구분 | Enterprise(서버) / Client(노트북·PC) / Consumer(모바일 등) |
| CPU vs GPU | CPU는 범용 제어 + 메인 메모리만 직접 주소 지정. GPU는 FPU 달린 코어 수천~만 개짜리 **가속기** |
| 데이터 경로 변화 | 예전: SSD → CPU 메모리 → GPU 메모리. 지금: SSD → GPU 메모리 직접(GPUDirect Storage). Control path는 아직 CPU가 냄 |
| NAND 0/1 | 전자가 차 있으면 **0**(programmed), 비어 있으면 **1**(erased) |
| 비대칭 | **1→0(program)은 page 단위로 선택적 가능**, **0→1(erase)은 block 단위로 한꺼번에만 가능** |
| 크기 | Page 16KB, Block = 256 page = 4MB. 공정이 발전할수록 page·block 모두 커짐 |
| 지연 | Read 수십 µs < Program 수백 µs < Erase 수 ms (erase는 HDD 수준으로 느림) |
| 주소 지정 | DRAM은 **byte-addressable**, SSD는 아님 → page 단위로만 읽고 씀 |
| 내부 병렬성 | NAND die → package(chip) → **channel × way** 구조로 controller가 동시 접근 |
| Flash Controller | NAND ↔ SSD 내부 DRAM ↔ Host 사이 데이터를 옮기는 **data mover** |
| SSD = 컴퓨터 | 내부에 CPU(모바일급)·DRAM·NAND(저장소)가 다 있음 → FTL 같은 소프트웨어가 돎 |

---

## 1. 시스템 안에서 SSD의 위치

### 1.1 버스 구조

- 노트북이든 서버든 논리적으로 보면 **CPU, 메모리, 저장장치**가 있고, 저장장치는 **버스**에 붙어야 CPU와 데이터를 주고받을 수 있음
- 버스 = 데이터가 오가는 **고속도로**. 차선(lane)이 많고 제한 속도가 높을수록 대역폭이 큼
- CPU 안의 **메모리 컨트롤러**가 **메모리 버스**와 연결되고, 저장장치는 PCIe 컨트롤러를 통해 연결됨 (4주차 PCIe/NVMe, PCH 내용과 연결)

### 1.2 메모리 대역폭 계산

- 메모리 버스는 **channel** 단위로 구성되고, channel 하나당 대략 **25~70 GB/s** 수준을 읽고 쓸 수 있음 (DDR 세대에 따라 다름)
- 서버 CPU는 보통 **6~12 channel**을 가짐 → 곱하면 전체 메모리 대역폭이 대략 나옴

```
전체 메모리 대역폭 ≈ channel당 대역폭 × channel 수

예) channel당 50 GB/s, 12 channel 서버
    50 × 12 = 600 GB/s

예) channel당 25 GB/s, 6 channel 서버
    25 × 6 = 150 GB/s
```

- 이 숫자가 중요한 이유: SSD에서 아무리 빨리 데이터를 퍼올려도 결국 메모리(또는 GPU 메모리)에 적재돼야 연산에 쓰임 → **저장장치 → 메모리 → 연산기** 전 구간의 대역폭이 맞아야 함

### 1.3 SSD 시장 클래스

메모리/스토리지 업계는 제품군을 세 클래스로 나눔.

| 클래스 | 대상 | 특징 |
|---|---|---|
| **Enterprise** | 서버 (Dell 등 서버 벤더로 납품) | 내구성·성능 일관성·전원 장애 보호 중시, 고가 |
| **Client** | 노트북·데스크톱 | 가격과 성능의 균형 |
| **Consumer** | 개인 소비자용, 더 나아가 모바일 | 가격 중시 |

---

## 2. CPU와 GPU

### 2.1 프로그램이 CPU에서 도는 과정

1. 실행 파일(executable)은 처음에 **저장장치**에 있음
2. 더블클릭해서 실행하면 코드(명령어)가 **메모리로 올라옴** (load)
3. CPU는 메모리에 있는 명령어를 연속적으로 가져와(fetch) 처리함
4. 데이터도 저장장치 → 메모리로 적재된 뒤 CPU가 처리하고, 저장할 때는 다시 메모리 → 저장장치로 내려감

- 핵심: **CPU가 직접 주소 지정(addressing)할 수 있는 건 메모리뿐**임. 저장장치의 데이터는 반드시 메모리를 거쳐야 CPU가 씀

### 2.2 CPU vs GPU

| 구분 | CPU | GPU |
|---|---|---|
| 역할 | 범용 프로세서. 제어 흐름, 분기, OS, I/O 관리 | **가속기(accelerator)**. 시킨 연산만 열심히 하는 연산기 |
| 코어 | 소수의 강력한 코어 | FPU(부동소수점 연산기)를 포함한 작은 코어가 **수천~만 개** |
| 잘하는 일 | 복잡한 순차 로직 | 같은 연산을 대량 데이터에 동시에 적용 (행렬 곱 → 딥러닝) |

- 딥러닝은 부동소수점 행렬 연산 덩어리 → 코어 수가 압도적으로 많은 GPU가 유리함

### 2.3 데이터 경로의 변화 — GPU가 저장장치를 직접

**전통적인 경로 (CPU 경유)**
```
SSD ──▶ CPU 메모리 (bounce buffer) ──▶ GPU 메모리
```
- 데이터가 CPU 메모리를 한 번 거쳐야 함 → 복사 한 번 더, CPU 메모리 대역폭·CPU 시간 소모

**최근 경로 (GPUDirect Storage)**
```
SSD ──(PCIe DMA)──▶ GPU 메모리
```
- 기술적으로는 예전부터 가능했지만 **NVIDIA가 소프트웨어 지원을 안 해줬음**
- 약 5년 전부터 움직임이 시작됐고, 지금은 **CUDA 라이브러리(cuFile 등)에 기능이 들어가서** 데이터가 CPU 메모리를 거치지 않고 SSD ↔ GPU로 바로 이동함

**Data path vs Control path**
- **Data path**: 실제 데이터가 흐르는 길 → GPU로 직접 가능해짐
- **Control path**: "어디서 얼마나 읽어라" 같은 명령을 내리는 길 → **아직 CPU가 날려줘야 함**
- 추세: 연구 단계에서는 GPU가 직접 NVMe 명령을 내는 방식(예: BaM, Big accelerator Memory)까지 나오고 있음 → NVIDIA는 CPU 의존도를 최대한 줄이려는 방향이고, 향후 CPU의 존재감은 계속 줄어들 것이라는 관점임

### 2.4 데이터센터 구조 — Disaggregation

- 요즘 데이터센터는 자원을 서버 한 대 안에 묶어두지 않고 **로컬(local)과 리모트(remote)를 분리**하는 **disaggregation(분리화)** 구조로 감
  - 예: 연산(GPU 서버)과 저장장치(스토리지 노드)를 분리하고 고속 네트워크로 연결 → 각각 독립적으로 확장
- 3주차 예습에서 본 VAST Data의 **DASE**(Disaggregated Shared-Everything)가 대표 사례임 (CNode와 DBox를 따로 늘림)
- GPU 세대 교체가 매우 빠름 (NVIDIA B300 등) → GPU 서버는 비싸고, 클라우드/온프레미스 중 무엇을 택할지가 큰 고민거리임. 실제 기업 업무에 AI를 적용(AX)하면 **데이터 프라이버시** 때문에 온프레미스를 검토하는 경우도 많음

---

## 3. NAND Flash의 0과 1 (4주차 복습 + 심화)

### 3.1 원리

- NAND cell에 **전압(voltage)을 걸어** 전자를 이동시킴
- 전자는 **터널링 효과(tunneling effect)** — 양자역학 이론에 따라 절연막을 뚫고 지나가 floating gate(또는 charge trap)에 갇힘
- 전자가 **얼마나 들어 있느냐**로 데이터 값을 구분함

| 상태 | 전자 | 값 | 동작 |
|---|---|---|---|
| Programmed | 기준(약 50%) 이상 차 있음 | **0** | Program (write) |
| Erased | 거의 다 빠짐 | **1** | Erase |

- **Read** = cell에 전자가 얼마나 있는지 **센싱**하는 것. 전자를 넣고 빼는 것보다는 빠르지만, DRAM처럼 즉시 되는 건 아님

### 3.2 Program/Erase 비대칭 ★

- **1 → 0 (program)**: 해당 cell에만 전자를 넣으면 됨 → **선택적으로 가능**, page 단위
- **0 → 1 (erase)**: 전자를 빼야 하는데, 뺄 때는 cell 하나만 골라서 못 하고 **그룹(block)으로 다 같이 빼야 함**

→ 그래서 **erase된 깨끗한 상태(전부 1)에서 필요한 비트만 0으로 만드는 것**이 쓰기임. 0을 다시 1로 돌리려면 block 전체를 erase해야 함

### 3.3 16진수 예제

**16진수 복습**: 4비트 = 16진수 한 자리
```
F = 1111₂ = 1·2³ + 1·2² + 1·2¹ + 1·2⁰ = 8 + 4 + 2 + 1 = 15
5 = 0101₂ = 0·8  + 1·4  + 0·2  + 1·1  = 4 + 1         = 5
```

**경우 1 — F → 5 (프로그래밍만으로 가능)**
```
F : 1 1 1 1
5 : 0 1 0 1
    ↓   ↓
   1→0 1→0   ← 바뀌는 비트가 전부 1→0
```
- 1→0만 있으므로 **program만 하면 됨** (erase 불필요)

**경우 2 — 5 → F (erase 필요)**
```
5 : 0 1 0 1
F : 1 1 1 1
    ↑   ↑
   0→1 0→1   ← 0→1이 하나라도 있음
```
- 0→1은 program으로 불가능 → **block 단위 erase 후 다시 program**해야 함

> 정리: 새 값에 **0→1로 바뀌는 비트가 하나라도 있으면 erase가 필요**함. 실제 SSD는 매번 block을 지우는 대신 **다른 빈 page에 새로 쓰는 방식(out-of-place update)**으로 이를 피함 → 이 아이디어가 FTL, GC, 그리고 다음 시간 **로그 기반 기법**으로 이어짐

---

## 4. Page와 Block

### 4.1 논리적 크기

| 단위 | 크기 | 하는 일 |
|---|---|---|
| **Page** | 16 KB | **Read / Program** 단위 |
| **Block** | Page 256개 = 16KB × 256 = **4 MB** | **Erase** 단위 |

```
Block 크기 = 16 KB × 256 = 4,096 KB = 4 MB
```

- **공정(테크놀로지)이 발전하면서 block 크기가 계속 커지고, page 크기도 같이 커짐** (예전엔 page 2KB/4KB → 현재 16KB 수준)
  - 용량은 늘지만, 작은 데이터를 고쳐도 큰 단위로 움직여야 해서 관리가 더 어려워짐

### 4.2 동작별 지연 시간

| 동작 | 단위 | 지연 (대략) |
|---|---|---|
| Read | Page | 수십 µs |
| Program | Page | 수백 µs (예: ~400 µs) |
| Erase | Block | **수 ms** (예: ~2 ms) |

- Erase는 한 번에 큰 단위를 처리하지만, **1회 수행에 ms 단위 시간이 걸려서 HDD 접근 시간만큼 느림** → erase를 얼마나 피하느냐가 SSD 성능의 핵심임

### 4.3 DRAM vs SSD — Byte-addressable 여부

| 구분 | DRAM | SSD |
|---|---|---|
| 접근 단위 | **byte-addressable** — 1 byte 단위로 읽고 씀 | **byte-addressable 아님** — page 단위 |
| CPU 직접 접근 | load/store 명령으로 바로 | 블록 장치 → 메모리로 가져온 뒤 사용 |

### 4.4 HDD vs SSD 읽기 단위

- HDD는 **512 byte sector** 단위로 읽음
- 16KB를 HDD sector로 환산하면:
```
16 KB / 512 B = 16,384 / 512 = 32 sector
```
- SSD는 움직이는 단위가 page이므로 **커맨드 한 번에 16KB page가 통째로** 들어옴

---

## 5. SSD 내부 구조 — Die, Chip, Channel, Way

### 5.1 계층

```
NAND die (가장 작은 독립 동작 단위, 안에 plane → block → page)
   └─ 여러 die를 묶어 하나의 package(칩)로 출시  예) die 4개 = 1 chip
        └─ 여러 chip이 channel에 연결
             └─ Flash Controller가 여러 channel을 동시에 구동
```

- 그림에서는 flash block을 2차원 array처럼 그리지만 실제로는 die 안에 겹겹이 쌓여 있음 (3D NAND)

### 5.2 Channel과 Way

- **Channel**: Flash Controller ↔ NAND chip 사이의 **독립된 버스**. channel끼리는 동시에 데이터 전송 가능
- **Way**: **같은 channel을 공유**하는 chip의 개수(degree)
  - 같은 channel의 way들은 버스를 번갈아 쓰지만, 한 chip이 내부적으로 program/read하는 동안 다른 chip에 데이터를 보낼 수 있음 → **interleaving**으로 버스를 놀리지 않음

```
예) 4 channel × 2 way 구성

            ┌─ CH0 ─ [Chip0] [Chip1]
Flash  ─────┼─ CH1 ─ [Chip2] [Chip3]
Controller  ├─ CH2 ─ [Chip4] [Chip5]
            └─ CH3 ─ [Chip6] [Chip7]

→ 4개 channel이 동시에 전송 (channel 병렬)
→ 각 channel 안에서 2개 way가 번갈아 동작 (way interleaving)
```

- 4주차에서 본 "SSD 내부 병렬성으로 SATA 대역폭을 넘어선다"의 실체가 바로 이 channel × way 구조임

### 5.3 Flash Controller의 역할 — Data Mover

- Flash Controller(블록)는 데이터를 옮기는 **data mover** 역할을 함
- 읽기 흐름:
```
NAND page ──(Flash Controller)──▶ SSD 내부 DRAM ──(DMA, PCIe/NVMe)──▶ Host 메모리
```
- NAND에서 바로 호스트로 보내는 게 아니라 **SSD 내부 DRAM에 먼저 올린 뒤** 호스트로 보냄
  - HDD도 마찬가지로 자기 디스크에서 읽은 데이터를 **내부 DRAM(버퍼)**에 올렸다가 호스트로 보냈음 (2주차 HDD controller 구조와 같은 패턴)

---

## 6. SLC / MLC / TLC / QLC 다시 보기

| 종류 | cell당 bit | 전압 상태 수 | 속도 | 수명(P/E) | 가격/용량 |
|---|---|---|---|---|---|
| SLC | 1 | 2 | 가장 빠름 | 가장 김 | 가장 비쌈 |
| MLC | 2 | 4 | ↓ | ↓ | ↓ |
| TLC | 3 | 8 | ↓ | ↓ | ↓ |
| QLC | 4 | 16 | 가장 느림 | 가장 짧음 | 가장 저렴 |

- **bit 수가 늘수록 같은 전압 범위를 더 잘게 쪼개야 함** → 상태 간 간격이 좁아져 더 정밀하게 넣고 읽어야 함
  - → **에러가 많이 발생**함 (더 강한 ECC 필요)
  - → **program 시간, read 시간이 계속 길어짐** (정밀하게 여러 번 나눠 넣고, 여러 기준 전압으로 센싱해야 하므로)
- **SLC**는 가장 빠르지만 1비트밖에 못 저장해서 **가성비가 안 나옴** → 요즘은 **QLC**를 많이 씀
- **AI 시대와 QLC**: 학습 데이터·로그처럼 **한 번 저장해 두고 오랫동안 읽기 위주로 보관**하는 용도에는 QLC가 충분함 (write가 적으면 짧은 P/E 수명도 문제가 덜 됨)
  - 3주차 예습의 VAST Data가 바로 이 전략: QLC + SCM 쓰기 버퍼로 랜덤 쓰기를 QLC에 직접 보내지 않음

---

## 7. SSD는 하나의 컴퓨터다

- SSD(디바이스) 안에는 **마이크로프로세서(컨트롤러)**가 들어 있고, 모바일 폰에 들어갈 정도로 **꽤 강력한 CPU**(보통 ARM 코어 여러 개)임
- 구성 요소를 보면 컴퓨터와 똑같음

| 컴퓨터 | SSD 내부 |
|---|---|
| CPU | 컨트롤러 안의 임베디드 CPU |
| 메모리 | 내부 DRAM (매핑 테이블, 버퍼) |
| 디스크 | NAND die |
| OS/소프트웨어 | **FTL**(Flash Translation Layer) 펌웨어 — 주소 매핑, GC, wear leveling 등 |

- 3장의 erase-before-write 문제를 호스트에게 숨기고 "그냥 덮어쓰는 블록 장치"처럼 보이게 만드는 게 이 내부 소프트웨어의 일임
- **로그 기반 기법(log-structured)**: 덮어쓰지 않고 항상 뒤에 이어서 쓰는 방식 → SSD 내부(FTL)뿐 아니라 **파일 시스템, 데이터베이스가 모두 똑같이 쓰는 기법**임 → 다음 시간 주제
- 교수 코멘트: 디바이스 자체를 너무 깊게 파고들 필요는 없고, **필요한 부분은 "개념이 이렇게 돼 있다" 수준까지** 이해하면 됨

---

## 8. 계산 정리

| 항목 | 식 | 예 |
|---|---|---|
| 메모리 대역폭 | channel당 대역폭 × channel 수 | 50 GB/s × 12 = 600 GB/s |
| Block 크기 | page 크기 × page 수 | 16 KB × 256 = 4 MB |
| page를 HDD sector로 | page 크기 / 512 B | 16 KB / 512 B = 32 |
| cell 상태 수 | 2^(bit 수) | QLC: 2⁴ = 16 |
| erase 필요 여부 | 0→1 비트가 하나라도 있으면 필요 | F→5 불필요 / 5→F 필요 |

---

## 9. 용어 정리

| 용어 | 뜻 |
|---|---|
| Bus | CPU·메모리·장치를 잇는 데이터 고속도로 |
| Memory channel | 메모리 컨트롤러 ↔ DIMM 사이 독립 경로. 많을수록 대역폭↑ |
| Accelerator | 특정 연산만 빠르게 하는 장치 (GPU 등) |
| GPUDirect Storage | SSD ↔ GPU 메모리를 CPU 메모리 거치지 않고 DMA로 직접 전송 |
| Data path / Control path | 데이터가 흐르는 길 / 명령이 흐르는 길 |
| Disaggregation | 연산·메모리·저장 자원을 분리해 독립적으로 확장하는 구조 |
| Tunneling effect | 전자가 양자역학적으로 절연막을 통과하는 현상. NAND program/erase 원리 |
| Program | 1→0. 전자 주입. page 단위 |
| Erase | 0→1. 전자 제거. block 단위 |
| Byte-addressable | 1 byte 단위로 직접 접근 가능 (DRAM O, SSD X) |
| Die | NAND의 독립 동작 단위 |
| Channel | Flash Controller ↔ NAND chip 사이 독립 버스 |
| Way | 한 channel을 공유하는 chip 수 |
| Interleaving | 같은 channel의 chip들을 번갈아 구동해 버스 유휴 시간을 줄이는 기법 |
| Flash Controller | NAND ↔ 내부 DRAM ↔ Host 간 data mover |
| FTL | SSD 내부 펌웨어. 논리 주소 ↔ 물리 page 매핑, GC, wear leveling |
| Out-of-place update | 덮어쓰지 않고 빈 page에 새로 쓰는 방식 |

---

## 10. 셀프 체크

- [ ] 서버의 메모리 대역폭을 channel 정보로 계산할 수 있는가?
- [ ] CPU가 직접 주소 지정할 수 있는 대상은 무엇인가? 저장장치 데이터는 어떻게 CPU까지 가는가?
- [ ] CPU와 GPU의 구조적 차이와, 딥러닝에 GPU가 유리한 이유를 설명할 수 있는가?
- [ ] GPUDirect Storage 이전/이후 데이터 경로를 그릴 수 있는가? control path는 여전히 누가 담당하는가?
- [ ] NAND에서 0과 1은 각각 전자가 어떤 상태인가?
- [ ] 1→0과 0→1의 수행 단위가 다른 이유는?
- [ ] F→5, 5→F 중 erase가 필요한 쪽과 이유를 설명할 수 있는가? 임의의 두 16진수로도 판단할 수 있는가?
- [ ] Page 16KB, page 256개일 때 block 크기는?
- [ ] Read / Program / Erase 지연을 크기 순으로 나열하고, erase가 HDD만큼 느린 이유를 말할 수 있는가?
- [ ] DRAM과 SSD의 byte-addressable 여부 차이는?
- [ ] 16KB를 HDD에서 읽으려면 sector를 몇 번 읽어야 하는가?
- [ ] Die / chip / channel / way의 관계를 설명할 수 있는가? 4 channel × 2 way 구성을 그릴 수 있는가?
- [ ] Flash Controller가 NAND 데이터를 호스트로 보내는 경로는?
- [ ] cell당 bit 수가 늘면 에러·속도·수명이 어떻게 변하고 그 이유는?
- [ ] AI 워크로드에서 QLC가 쓸 만한 이유는?
- [ ] "SSD는 하나의 컴퓨터다"를 구성 요소로 설명할 수 있는가?
- [ ] 로그 기반 기법이 SSD·파일 시스템·DB에서 공통으로 쓰이는 이유를 out-of-place update와 연결할 수 있는가?
