# AI 데이터 시스템 및 인프라 — 1주차 정리

> 2026.09.05(토) · 김영재 교수 · 1주차 "AI 데이터 시스템 및 스토리지 개요"
> 진도라기보다 **"왜 지금 스토리지/메모리가 AI 인프라의 핵심이 되었는가"** 에 대한 배경 설명 중심

---

## 0. 이번 시간의 큰 흐름 (한 문장 요약)

**LLM 추론이 "계산" 문제에서 "상태(context)를 어디에 저장하고 어떻게 다시 꺼내 쓸 것인가" 라는 데이터 문제로 바뀌었고, 그래서 메모리·스토리지 계층이 GPU만큼 중요해졌다.**

흐름:
```
Transformer(auto-regressive) → KV Cache 폭증 → HBM 용량 한계
→ DRAM/로컬 SSD/네트워크 플래시로 계층화(offload)
→ 새로운 스토리지 계층(NVIDIA CMX = G3.5) 등장
→ 반도체·인프라 산업 재편
```

---

## 1. 왜 컨텍스트(맥락)가 데이터 문제가 되는가

### 1-1. Transformer는 auto-regressive다
- Transformer 기반 LLM은 프롬프트를 입력받아 **확률적으로 다음 토큰**을 하나씩 생성한다.
- **Auto-regressive(자기회귀)**: 다음 단어를 뽑으려면 **앞의 모든 토큰을 이해하고 있어야** 한다.
- 즉, 모델은 **히스토리를 계속 들고 있어야** 다음 토큰을 낼 수 있다.
  → 이 "들고 있어야 하는 것"이 바로 **KV Cache**.

### 1-2. 맥락은 행렬(텐서)로 저장된다
- Attention의 **Key(K), Value(V)** 를 다차원 벡터/행렬 형태로 저장해 둔다.
- 실제 KV Cache 텐서의 shape는 대략 **4차원**:
  ```
  [batch, num_heads, seq_len, head_dim]   (× layer 수)
  ```
- 강의에서 든 예("the cat sat on ..." 같은 문장): 이 4차원 행렬로 저장해 뒀더니 모델이 **문맥을 이해하고 있는 상태**가 유지되더라 → 데이터를 "파일"이 아니라 **"텐서/메모리 상태"** 로 다뤄야 하는 시점이 왔다.

### 1-3. 왜 지금 폭발했나
- 생성형 AI로 **데이터가 재생성(re-generation)** 된다. 예: 요약문을 사람이 며칠 걸려 쓰던 걸 모델이 즉시 생성 → 파생 데이터가 계속 불어남.
- **Agentic AI** 확산: 에이전트는 세션이 길고, 이전에 만든 맥락을 **재사용(reuse)** 해야 한다.
- → 맥락을 저장·공유·재사용할 효율적인 계층이 필요 = **Context Memory Storage** 개념의 등장.

---

## 2. 메모리 계층 기초 (SRAM / DRAM / HBM)

| 구분 | 특징 | 용도 |
|---|---|---|
| **SRAM** | 가장 빠름, 극도로 비쌈, 집적도(density) 낮음 | CPU/GPU 캐시. 대용량 저장 불가 |
| **DRAM** | SRAM보다 느리지만 **capacity density**가 좋고 저렴 | 메인 메모리(RAM) |
| **HBM** (High Bandwidth Memory) | DRAM die를 2D 평면이 아니라 **3D로 적층**(1단·2단·3단·4단…, TSV로 연결) | GPU 옆에 붙여 대역폭 확보 |

### 핵심 포인트
- **왜 캐시(SRAM)가 필요한가**: DRAM 접근이 계산기(연산 유닛) 입장에서는 이미 너무 느림. 자주 쓰는 데이터를 옆에 있는 빠른 SRAM에 캐싱해 두면 멀리 갈 필요가 없다.
- **왜 HBM인가**: GPU 코어를 아무리 늘려도(스케일링) **DRAM 대역폭이 병목**이라 코어가 놀게 된다. 그래서 die를 위로 쌓아 **여러 층에서 동시에 데이터를 가져와** 대역폭을 확보한다.
  → *"메모리 월(memory wall)"* 문제.

### GPU 연산 유닛
- **CUDA Core**: 범용 **병렬 연산** 담당.
- **Tensor Core**: **서브행렬 × 서브행렬**(matrix multiply-accumulate)을 고속으로 처리하도록 만든 전용 유닛.
- CPU가 감당 못 하는 대규모 행렬 연산을 GPU가 처리 → 그 데이터를 먹여주는 게 HBM.

---

## 3. 로컬을 넘어서 — 리모트 스토리지와 새로운 계층

### 3-1. 단일 머신의 한계
- 한 서버(로컬 버스에 붙은 디스크)만으로는, 긴 컨텍스트에서 나오는 토큰의 KV를 **전부 저장할 용량이 부족**하다.
- → 대용량 디스크를 여러 장 묶은 **리모트/네트워크 스토리지**를 서버에 연결. 다만 네트워크를 타는 순간 지연(latency)이 문제.

### 3-2. NVIDIA CMX (= 강의 중 "CMX/G3.5")
- NVIDIA가 정의한 새로운 KV Cache 전용 스토리지 계층.
- 원래 이름: **ICMS / ICMSP (Inference Context Memory Storage Platform)** → 이후 **CMX (Context Memory eXtension)** 로 브랜딩.
- **G3.5 계층**: pod 단위 **이더넷 연결 플래시 계층**. 아래 계층 구조에서 G3와 G4 사이를 메운다.

| 계층 | 매체 | 지연 | 특징 |
|---|---|---|---|
| **G1** | GPU HBM | ns | 가장 빠름, 용량 극소 |
| **G2** | CPU DRAM | — | warm 블록 |
| **G3** | 로컬 NVMe SSD | µs | 노드 로컬, 노드 간 공유 불가 |
| **G3.5** | **CMX (이더넷 플래시, BlueField-4 관리)** | — | **pod 단위 공유 컨텍스트 메모리** |
| **G4** | 공유/외부 스토리지 | ms | 용량 무제한급, 너무 느림 |

- 핵심 아이디어: KV 블록을 **온도(hot/warm/cold)** 로 나눠 계층에 배치하고, 필요할 때 GPU 메모리로 **pre-staging**. 재계산(recompute)보다 읽어오는 게 싸다.

### 3-3. NVIDIA는 GPU 회사가 아니라 데이터센터 회사
- GPU뿐 아니라 **BlueField(DPU/네트워크 카드)** 도 판다.
- **BlueField-3**가 2~3년 전 출시, **BlueField-4**가 이번 가을 등장 예정. BF4는 NIC + 연산(Arm 코어)을 합쳐 사실상 **서버 한 대** 역할, I/O 스케줄링을 담당해 GPU가 스토리지를 기다리며 멈추지 않게 한다.
- 에이전트가 많아지면 **CPU가 병목**이 되기 시작 → 그래서 인텔 같은 CPU 진영도 다시 주목받는 흐름.

---

## 4. 산업/현실 관점 코멘트 (교수님 인사이트)

- 메모리·스토리지가 **CPU/GPU만큼 중요한 축**이 될 것이라는 전망. 다만
  - **"기술이 그리로 가느냐"** 와 **"돈이 그리로 가느냐"** 는 다른 문제.
  - 인프라 투자가 회수되려면 demand가 충분히 커져야 하는데, 그 시점인지는 아직 논쟁적.
- **엔드-투-엔드로 봐야 효과가 난다**: 알고리즘만 좋아도, 엔진/하드웨어에 심는 단계에서 여러 챌린지가 생김.
- **이론 연구 ↔ 실제 적용의 갭이 크다.** 논문은 많지만 실제 서비스에 적용된 건 적다.
  → **시스템 관점에서 효용성(정말 이득인가)을 검증**해 볼 필요.
- 정확도 관점에서 미미한 차이라도, **메모리/시스템 관점에서는 큰 이득**일 수 있다. 반대로 시스템 하는 사람 입장에선 "그 점수 차이가 무슨 의미인가"를 잘 안 따진다.
- 프롬프트 입력을 줄이는 접근(핵심 질문만 뽑아 재구성) 같은 소프트웨어적 절약도 하나의 방향.

---

## 5. 저장 장치(HDD) 기초 — 여기서부터 본격 진도 시작

> 강의자료: *Magnetic Disk & HDD Controller Architecture* (김영재)

### 5-1. Basic Interface
- 디스크는 **섹터 단위로 주소가 매겨진(sector-addressable) 주소 공간**이다. 상위 계층에는 **섹터의 배열**로 보인다.
- 섹터 크기: **512 byte** 또는 **4096 byte(4KB Advanced Format)**.
- 기본 연산은 섹터 단위의 **read / write** 뿐.
- 따라서 4바이트만 필요해도 최소 한 섹터를 통째로 읽어야 한다 → **read amplification**.
- **기계 장치**라는 점이 관리(management)를 까다롭게 만든다.

> 512B 단위 접근은 지금 AI 스토리지에서 다시 화두다. KV 블록이 1KB 미만이라 4KB에 최적화된 SSD에서는 8배 read amplification이 나고, 그래서 NVIDIA/Kioxia가 **512B 랜덤 리드 IOPS**를 성능 지표로 내세우고 있다.

### 5-2. 디스크 구조 용어

| 용어 | 의미 |
|---|---|
| **Platter** | 데이터가 기록되는 원판. 표면에 **자성 필름(magnetic film)** 코팅 |
| **Spindle** | 플래터들을 관통해 묶고 회전시키는 축. 여러 장의 플래터가 붙을 수 있음 |
| **Surface** | 플래터의 윗면·아랫면. 각 면이 기록 대상 |
| **Track** | 한 표면을 나눈 동심원 링 |
| **Cylinder** | 여러 플래터에 걸친 **같은 반지름의 track들의 묶음** |
| **Sector** | track을 쪼갠 번호 매겨진 단위 |
| **Head / Arm** | 각 표면을 읽는 헤드. 움직이는 arm에 달려 있음 |

읽기 동작 순서 (슬라이드의 "Let's Read 12!" 애니메이션):
```
Seek to right track → Wait for rotation → Transfer data
```

### 5-3. Positioning — 헤드는 자기 위치를 어떻게 아는가
- **Drive servo system**이 헤드를 트랙 위에 유지시킨다.
- 문제: 플래터가 완벽히 정렬돼 있지 않고 트랙도 완벽한 동심원이 아니다(**runout**). 트랙 위에 머무는 게 어렵다.
- 밀도가 올라갈수록(**BPI** bits per inch, **TPI** tracks per inch 증가) 더 어려워진다.
- 해법: **Servo burst** — 몇 개 섹터마다(3~5개) 위치 정보를 기록해 두고, 헤드가 이를 지날 때 자기 위치를 계산해 보정한다.

### 5-4. Time = Seek + Rotation + Transfer

**① Seek**
- 비용은 **실린더 간 거리의 함수** (단, 선형은 아님)
- 반드시 **가속(accelerate) → 등속(coast) → 감속(decelerate) → 정착(settle)** 4단계를 거친다
- **settle만 0.5~2 ms**, 전체 seek는 보통 **4~10 ms**
- **평균 seek 거리 ≈ 최대 거리의 1/3**

**② Rotation (회전 지연)**
- RPM에 의존. 7,200 RPM이 일반적, 15,000 RPM이 하이엔드.
- 7,200 RPM → 1회전 = 60초/7200 = **8.3 ms**
- **평균 회전 지연 = 1회전 / 2 = 4.15 ms**

**③ Transfer**
- 셋 중 가장 빠름. RPM과 섹터 밀도에 의존.
- 최대 전송률은 보통 **100+ MB/s**
- 512B 전송 = 512 B ÷ 100 MB/s ≈ **5 µs**

### 5-5. Workload Performance — 그래서 무엇이 빠른가
```
seek 느림, rotation 느림, transfer 빠름
```
| 워크로드 | 지배 요소 | 성능 |
|---|---|---|
| **Sequential** (순서대로 접근) | transfer 지배 | 빠름 |
| **Random** (임의 접근) | seek + rotation 지배 | 매우 느림 |

**계산 예제 (슬라이드 핵심)** — 16KB 랜덤 읽기

| | Cheetah | Barracuda |
|---|---|---|
| Capacity | 300 GB | 1 TB |
| RPM | 15,000 | 7,200 |
| Avg Seek | 4 ms | 9 ms |
| Max Transfer | 125 MB/s | 105 MB/s |
| Platters / Cache | 4 / 16 MB | 4 / 32 MB |

- Cheetah: seek 4 ms + rotation (½ × 60/15000 = **2 ms**) + transfer (16KB ÷ 125MB/s = **125 µs**) = **6.1 ms** → throughput **2.5 MB/s**
- Barracuda: 9 ms + **4.1 ms** + **149 µs** = **13.2 ms** → throughput **1.2 MB/s**

| | Cheetah | Barracuda |
|---|---|---|
| Sequential | 125 MB/s | 105 MB/s |
| Random (16KB) | **2.5 MB/s** | **1.2 MB/s** |

> 시험 포인트: **순차 대비 랜덤이 약 50~90배 느리다.** 이 격차가 파일시스템·DB·LSM-tree가 전부 "순차 쓰기"로 설계되는 이유.

### 5-6. Other Improvements (HDD 최적화 3종)

**① Track Skew**
- 문제: 트랙 15를 다 읽고 바깥 트랙의 16을 읽으려는데, seek 후 **헤드가 settle할 시간이 부족**해서 16을 놓친다 → 한 바퀴 더 돌아야 함.
- 해법: 인접 트랙의 섹터 번호 시작점을 **의도적으로 어긋나게(skew) 배치**. seek + settle 시간을 벌어준다.

**② Zones (ZBR, Zoned Bit Recording)**
- 바깥 트랙이 안쪽 트랙보다 물리적으로 길다.
- → **바깥 트랙에 더 많은 섹터**를 배치해서 용량과 대역폭을 늘린다.
- 결과: 바깥쪽(저 LBA)이 안쪽보다 순차 전송률이 빠르다.

**③ Drive Cache / Buffering**
- 드라이브 내부에 **2MB~16MB 메모리**를 캐시로 탑재 (OS도 별도로 캐싱함).
- **Read-ahead ("Track buffer")**: 회전 지연 동안 어차피 놀고 있으니 **트랙 전체를 미리 읽어** 버퍼에 올린다.
- **Write caching (휘발성 메모리)**: **Immediate reporting** — 실제로는 아직 디스크에 안 썼는데 "썼다"고 응답. 빠르지만 **정전 시 데이터 유실** 위험.
- **Tagged Command Queueing (TCQ)**: 여러 요청을 동시에 걸어두고, **디스크가 스스로 순서를 재배치(reorder)** 해서 성능을 높인다.

### 5-7. I/O Scheduler
- 질문: I/O 요청 스트림이 주어졌을 때 **어떤 순서로 처리할 것인가**.
- CPU 스케줄링과 다르다: **작업 길이보다 헤드의 현재 위치와 요청 위치의 관계**가 더 중요하다.

**FCFS 예제** (랜덤 요청 1건당 seek+rotate = 10 ms 가정)
```
300001, 700001, 300002, 700002, 300003, 700003  →  약 60 ms
300001, 300002, 300003, 700001, 700002, 700003  →  약 20 ms
```
순서만 바꿔도 **3배** 차이.

**스케줄러는 어디에 두어야 하나?** — OS 안? 디스크 안? (둘 다 존재)

| 알고리즘 | 전략 | 특징 |
|---|---|---|
| **FCFS** | 온 순서대로 | 단순, 비효율 |
| **SPTF** (Shortest Positioning Time First) | **positioning time(seek+rotation)이 최소인 요청**을 선택. greedy | 디스크 내부에서만 정확히 구현 가능(회전 위치를 알아야 함). 먼 요청이 **starvation** |
| **SSTF** (Shortest Seek Time First) | seek 거리만 보는 OS용 근사 | OS는 회전 위치를 모르므로 SPTF 대신 사용 |
| **SCAN** (Elevator) | 디스크 한쪽 끝에서 반대편까지 **쓸고 지나가며** 처리. 실린더 번호로 정렬, 회전 지연은 무시 | starvation 완화 |
| **C-SCAN** | **한 방향으로만** 쓸고, 끝나면 처음으로 복귀 | SCAN보다 공정(fairness)함 |

> SPTF를 OS가 못 하는 이유가 시험에 나오기 좋다: OS는 헤드의 **회전 위치를 알 수 없다**. 그건 드라이브만 안다.

### 5-8. Storage Latest Trends

**스토리지 진화의 3가지 방향**: ① High-performance ② High Capacity ③ Specialized Usage
- 방향은 **저장 매체(HDD, SSD)** 와 **인터페이스(SATA, SAS, PCIe)** 에 따라 갈린다.

**HDD는 죽었는가? → 아니다**
- 비용 효율과 대용량 때문에 여전히 널리 쓰인다. 데이터센터는 PB~EB 규모 저장에 HDD를 쓴다.
- **CERN EOS**: Tape + HDD로 EB 규모. 현재 900 disk server, 70k HDD.
  - 미래 스토리지 서버 구상: 서버당 **1.68 PB HDD** + HDD 용량의 **약 10%를 NVMe/SSD**로, 200/400 GE 네트워크, 384 GB 메모리.
- **ORNL Frontier**: HDD + SSD로 PB 규모 고속 저장.

**HDD 신뢰성 — Helium 충전 드라이브**
- 공기 대신 **헬륨**을 채운다 → 마찰 감소.
  1. 마찰이 줄어 **플래터를 더 얇게** 만들 수 있음
  2. 플래터 진동이 줄어 **고장률 감소**
  3. 얇은 플래터 → **더 많이 적층 → 고용량**
- WD Ultrastar He12(12TB) 기준: 8TB 공기 드라이브 대비 용량 +50%, 전력 -54%, 신뢰성 +25% (MTBF 2.5M시간)

**HDD 용량 확장 기술 3종**

| 기술 | 원리 | 장점 | 단점 | 용도 |
|---|---|---|---|---|
| **HAMR** (Seagate)<br>Heat-Assisted | 레이저 다이오드로 플래터 미세 영역을 순간 가열 후 기록. 가열로 자화 반전을 쉽게 만들고 빠르게 식혀 안정화 | 가장 높은 잠재 밀도, 수십~수백 TB 확장성 | 헤드에 레이저 통합 → 제조 난도 매우 높음, 발열·내구성·비용 | 미래 초고용량 HDD |
| **MAMR** (WD)<br>Microwave-Assisted | 헤드에 **STO(Spin Torque Oscillator)** 를 달아 마이크로파 자기장 생성 → 자기입자를 공진시켜 반전을 쉽게 함 | 레이저 불필요, 기존 공정 호환성 높음 | 이론 최대 밀도가 HAMR보다 낮음, STO 효율·안정성 | 차세대 상용 HDD |
| **SMR**<br>Shingled | 트랙을 **기와처럼 겹쳐서** 배열 → 더 좁은 트랙을 더 많이 | 저비용 고용량 (20TB+ 상용화) | 인접 트랙을 덮으므로 **순차 쓰기만** 가능, 랜덤 쓰기 성능 급락 | 백업, 콜드 데이터, 아카이빙(WORM) |

- SMR은 트랙을 **zone**으로 묶고, zone 내에서는 순차 쓰기만 허용한다. (WD HC670 SMR 26TB vs HC570 일반 22TB)
- **왜 자성 입자를 무작정 줄일 수 없나**: 입자가 너무 작으면 **열적 불안정성**으로 자기 정보가 날아간다. HAMR/MAMR은 이 한계를 우회하는 기법.

### 5-9. HDD/SSD Array & RAID

**어레이의 이점**
- **Performance**: 여러 드라이브 병렬 접근
- **Scalability**: 용량 확장 용이
- **Reliability**: RAID로 이중화
- **Efficiency**: IOPS·대역폭 활용 극대화

| 구성 | 방식 | 특징 |
|---|---|---|
| **RAID-0** | Striping | 고성능, 이중화 없음 |
| **RAID-1** | Mirroring | 이중화, 용량 절반 |
| **RAID-5/6** | Parity 기반 | 이중화 + 성능 균형 |
| **JBOD** | Just a Bunch Of Disks | 원시 용량만, RAID 없음 |

**All-Flash Array 제품**: Pure Storage FlashArray(NVMe 지원 엔터프라이즈), Dell EMC PowerStore(NVMe 최적화 통합 스토리지), NetApp AFF(중복제거·압축 기반 고처리량)

---

## 6. STT 오류 교정표

| 녹취 표기 | 실제 용어 |
|---|---|
| LM 모델 | **LLM** |
| 오토 리그레시브 | **Auto-regressive (자기회귀)** |
| 덧 셋 캣 온 | "the cat sat on ..." (예문) |
| 서머라이즈 | **Summarize** |
| 리우즈 | **Reuse** |
| 에이전트 AI | **Agentic AI** |
| CMX / CNX | **NVIDIA CMX** (Context Memory eXtension, 구 ICMS/ICMSP) |
| g 3.5 | **G3.5 tier** |
| 앤드리아 | **NVIDIA (엔비디아)** |
| 블루 필드 | **BlueField** (NVIDIA DPU) |
| SM / 디자인 SM | **SRAM / DRAM, SRAM** |
| DM | **DRAM** |
| 커패스틱 댄서티 | **Capacity density** |
| HBM 하이 밴드스 메모리 | **High Bandwidth Memory** |
| 후다코 / 쿠다 코어 | **CUDA Core** |
| 1분단 2분단 3분단 | **(die) 1단·2단·3단 적층** |
| 스핀드 | **스핀들(spindle) / 디스크 암** |
| 시크 로테이트 트랜스퍼 | **Seek / Rotate(Rotational latency) / Transfer** |
| AR 시대 | **AI 시대** (문맥상) |

---

## 7. 진도 위치 — 어디까지 나갔나

강의 녹음(약 68분) 기준으로 실제로 말로 다룬 범위는 **5-4의 Seek/Rotate/Transfer 설명 초입까지**다.

| 범위 | 상태 |
|---|---|
| 1~4장 (LLM·KV Cache·메모리 계층·CMX·산업 동향) | 구두 개요 설명, 슬라이드 밖 내용 |
| 5-1 Basic Interface ~ 5-4 Seek/Rotate/Transfer | **다룸** |
| 5-5 Workload Performance (Cheetah/Barracuda 계산) | 슬라이드에만 있음 — 다음 시간 예상 |
| 5-6 Track Skew / Zones / Cache | 슬라이드에만 있음 |
| 5-7 I/O Scheduler (FCFS, SPTF, SSTF, SCAN, C-SCAN) | 슬라이드에만 있음 |
| 5-8 Storage Trends (Helium, HAMR/MAMR/SMR) | 슬라이드에만 있음 |
| 5-9 RAID / All-Flash Array | 슬라이드에만 있음 |

---

## 8. 체크리스트

**개요 파트**
- [ ] KV Cache가 무엇이고 왜 seq_len에 비례해 커지는지 설명할 수 있다
- [ ] SRAM / DRAM / HBM의 속도·용량·비용 트레이드오프를 표로 그릴 수 있다
- [ ] HBM이 3D 적층으로 대역폭을 얻는 원리를 설명할 수 있다
- [ ] CUDA Core와 Tensor Core의 역할 차이를 말할 수 있다
- [ ] G1~G4 + G3.5 계층 구조를 지연/용량 축으로 그릴 수 있다

**HDD 파트**
- [ ] platter / surface / track / cylinder / sector / head·arm 을 그림으로 그릴 수 있다
- [ ] servo burst가 왜 필요한지, runout이 무엇인지 설명할 수 있다
- [ ] seek의 4단계(accelerate–coast–decelerate–settle)를 말할 수 있다
- [ ] 평균 회전 지연 = ½ × (60/RPM) 을 유도해서 계산할 수 있다
- [ ] 임의의 스펙표가 주어졌을 때 랜덤 읽기 시간과 throughput을 계산할 수 있다
- [ ] sequential과 random의 throughput 격차가 왜 수십 배인지 설명할 수 있다
- [ ] Track Skew와 ZBR이 각각 무엇을 해결하는지 구분할 수 있다
- [ ] SPTF를 OS가 구현할 수 없는 이유를 말할 수 있다
- [ ] SCAN과 C-SCAN의 차이, starvation 문제를 설명할 수 있다
- [ ] HAMR / MAMR / SMR을 원리·장단점·용도로 구분할 수 있다
- [ ] RAID 0/1/5/6/JBOD의 차이를 말할 수 있다

### 확장 질문
1. 토큰 1개당 KV Cache 크기는 어떻게 계산하나? (layer 수, head 수, head_dim, dtype으로 유도)
2. "재계산(recompute) vs 스토리지에서 읽기"는 어떤 조건에서 읽기가 유리해지는가?
3. 512B 랜덤 리드 IOPS가 4KB IOPS보다 AI 워크로드에서 더 중요한 지표인 이유는?
4. HDD의 seek/rotational latency는 SSD에서 무엇으로 대체되는가? SSD의 지연 구성 요소는?
5. SMR의 zone 개념은 강의계획서 5주차의 **ZNS SSD**와 어떻게 이어지는가?
6. Write caching의 immediate reporting은 강의계획서 7주차 **WAL/Crash Recovery**와 어떤 긴장 관계에 있는가?

---

## 9. 강의계획서 대조

- 1주차 계획: **"AI 데이터 시스템 및 스토리지 개요"** → 계획대로 진행
- 2주차 예정: **"반도체 기반 스토리지 및 차세대 메모리 기술"** → 오늘 개요 파트(HBM/DRAM/SRAM)에서 이미 선행
- 이번 슬라이드의 뒷부분(스케줄러, SMR, RAID)은 2~3주차에 걸쳐 나올 가능성이 높음
- 참고문헌: *Database System Concepts* (Silberschatz), *Operating Systems: Three Easy Pieces* (OSTEP)
  → **OSTEP 37장 (Hard Disk Drives)** 이 이번 슬라이드와 거의 1:1로 대응한다. Cheetah/Barracuda 예제, SPTF/SCAN 설명도 그대로 나온다. 예습 강력 추천.