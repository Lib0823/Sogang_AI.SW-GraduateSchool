# AI 데이터 시스템 및 인프라 — 2주차 정리
## Magnetic Disk & HDD Controller Architecture

> 김영재 교수 · 2주차 (1주차 슬라이드 5-5 이후 내용을 이어서 진행)
> 참고: OSTEP Ch.37 *Hard Disk Drives*, Ch.38 *RAID*

---

## 0. 한눈에 보기

- HDD는 **sector 배열**로 보이는 블록 장치이고, 기계식이라 느림
- I/O 시간 = **Seek + Rotation + Transfer** → Seek·Rotation이 ms 단위, Transfer는 µs 단위
- 그래서 **Sequential** 워크로드는 빠르고 **Random** 워크로드는 수십 배 느림
- 성능 개선 기법: **Track Skew / Zones(ZBR) / Drive Cache(Buffering)**
- Write cache의 조기 ACK는 **전원 장애 시 데이터 손실 → 일관성(consistency) 붕괴** 위험이 있음
- I/O 스케줄링은 CPU 스케줄링과 다르게 **head 위치**가 핵심임 (FCFS, SSTF, SPTF, SCAN, C-SCAN)
- 스케줄러 위치: **OS는 논리 주소(LBA)만 알고, Disk는 물리 geometry를 앎** → 둘을 통합하는 것이 연구 주제
- HDD는 죽지 않았음 → 데이터센터의 PB~EB급 저장에서 여전히 주력 (Helium, HAMR, MAMR, SMR로 용량 확장)

---

## 1. 왜 아직 HDD인가

- SSD가 빠르다는 건 모두 알지만 **가격(GB당 비용)** 이 계속 문제였음
- 성능은 IOPS만이 아니라 **bandwidth(throughput, MB/s)** 관점으로도 봐야 함 → 대용량 순차 I/O에서는 HDD도 충분히 경쟁력이 있음
- "HDD는 곧 안 쓴다"는 말이 나온 지 20년이 됐지만 여전히 대량으로 쓰이고 있음
- 참고로 삼성전자도 HDD를 만들었으나 사업을 정리(2011년 Seagate에 매각)하고 NAND 플래시 쪽에 집중함

---

## 2. Basic Interface

- Disk는 **sector-addressable address space**를 가짐 → 위(OS)에서 보면 **sector의 배열**로 보임
- Sector 크기는 보통 **512 bytes** 또는 **4096 bytes(4K)**
- 주요 연산은 **read / write 두 가지뿐**임
  - **delete 연산은 없음** → 삭제는 파일시스템 메타데이터 처리이고, 디스크 입장에서는 덮어쓰기(overwrite)일 뿐임
- **기계적(mechanical)이라 느림** → 이 느림을 어떻게 관리하느냐가 이 강의 전체의 주제임

---

## 3. Disk Internals (내부 구조)

| 구성 요소 | 설명 |
|---|---|
| **Platter** | 원판. 표면이 **magnetic film(자성 박막)** 으로 코팅됨 |
| **Surface** | Platter의 윗면·아랫면 각각. 양면 모두 기록 가능 |
| **Spindle** | Platter들을 관통하는 회전축. 여러 platter가 하나의 spindle에 묶여 **함께 고속 회전** |
| **Track** | Surface를 나눈 동심원 링 |
| **Cylinder** | 여러 platter에 걸친 **같은 반경의 track 묶음** (수직으로 쌓인 track) |
| **Sector** | Track을 나눈 조각. 번호가 붙은 최소 저장 단위 |
| **Read/Write Head** | Surface마다 하나씩 있는 읽기/쓰기 장치 |
| **Arm (Actuator arm)** | Head를 달고 반경 방향으로 움직이는 팔. 모든 head가 **함께 움직임** |

- 실제 디스크는 2차원 평면이 아니라 **platter가 여러 장 쌓인 3차원 구조**임 → 그래서 cylinder 개념이 필요함
- Drive 안에는 **간단한 microcontroller + DRAM(cache)** 이 들어 있음 → 이게 "HDD Controller"임

### 3.1 Positioning (Servo System)

- **Drive servo system**이 head를 track 위에 유지시킴
- 문제점
  - Head가 지금 어디 있는지 어떻게 아는가?
  - Platter가 완벽히 정렬돼 있지 않고 track도 완벽한 동심원이 아님 (**runout**) → track을 따라가기 어려움
  - 밀도가 높아질수록 더 어려워짐 → **BPI**(bits per inch), **TPI**(tracks per inch) 증가
- 해결: **Servo burst**
  - 몇 개(3~5) sector마다 **위치 정보**를 기록해 둠
  - Head가 servo burst를 지날 때 현재 위치를 파악하고 필요하면 보정함
- Track이 매우 미세하기 때문에 seek 후 "제대로 도착했는지"를 확인하고 자리를 잡는 **settling 시간**이 필요함

---

## 4. I/O 시간 = Seek + Rotation + Transfer

"12번 sector 읽기" 예시 흐름:

1. **Seek** — arm을 움직여 12번이 있는 track으로 이동 (Arm 이동)
2. **Rotation** — 12번 sector가 head 밑으로 돌아올 때까지 대기 (원판 회전)
3. **Transfer** — 실제로 데이터를 읽고/씀

```
T_io = T_seek + T_rotation + T_transfer
```

### 4.1 Seek

- **Seek cost는 cylinder distance의 함수**이지만 **순수 선형은 아님**
- Arm은 모터로 움직이므로 4단계를 거침
  - **accelerate(가속) → coast(등속) → decelerate(감속) → settle(안착)**
  - **Long seek** (outermost ↔ innermost 수준): 거리가 길어서 가속 후 **coast(등속) 구간**이 생김
  - **Short seek** (옆 track 이동): 가속하자마자 바로 감속해야 해서 **coast 구간이 없음**
- **Settling만 0.5 ~ 2 ms** 걸림
- 전체 seek는 보통 **4 ~ 10 ms**
- **평균 seek distance ≈ 최대 seek distance의 1/3**

> **왜 1/3인가?** (확률통계 연결)
> 현재 위치 X, 목표 위치 Y가 [0, 1]에서 독립·균등분포라고 하면
> E|X − Y| = ∫₀¹∫₀¹ |x − y| dy dx = 2∫₀¹∫₀ˣ (x − y) dy dx = 2∫₀¹ x²/2 dx = **1/3**

### 4.2 Rotation

- **RPM(rotations per minute)** 에 의해 결정됨
  - **7200 RPM**: 일반적 / **15000 RPM**: 하이엔드
- 7200 RPM에서 한 바퀴 시간

```
1 / 7200 RPM
= 1 min / 7200 rotations
= 1 sec / 120 rotations
≈ 8.3 ms / rotation
```

- **평균 rotational delay = 한 바퀴 시간 / 2** ≈ 8.33 / 2 ≈ **4.2 ms**

```
T_rotation(avg) = (1/2) × (60,000 ms / RPM)
```

- RPM은 수십 년 동안 거의 올리지 못했음 → rotation delay는 여전히 큰 비용임
- **연구 사례**: 사람들은 주로 seek(arm 이동)를 줄이는 데 집중했고 rotational delay 자체를 줄이는 고민은 적었음
  - Arm(head)을 **2개** 두면 대기해야 하는 회전량이 줄어듦 → 평균 대기 **1/2 바퀴 → 1/4 바퀴**
  - 기계·물리적 난제는 해당 분야가 풀고, 시스템 아키텍트는 **아키텍처 관점의 설계**를 제시하는 식으로 여러 분야가 함께 풀어야 하는 문제임
  - 참고: 상용 제품으로 Seagate의 multi-actuator HDD(MACH.2)가 있음 (이쪽은 병렬 I/O 목적)

### 4.3 Transfer

- **꽤 빠름** — RPM과 sector density(밀도)에 따라 달라짐
- 최대 transfer rate는 보통 **100+ MB/s**
- 512 bytes 전송 시간

```
512 bytes × (1 s / 100 MB) ≈ 5 µs
```

### 4.4 정리

| 구성 | 크기 | 비고 |
|---|---|---|
| Seek | 4 ~ 10 ms | 느림 (기계적 이동) |
| Rotation | 2 ~ 4 ms (평균) | 느림 (RPM에 종속) |
| Transfer | µs 단위 | 빠름 |

---

## 5. Workload Performance

- Seek 느림, Rotation 느림, Transfer 빠름 → 그럼 디스크에 가장 빠른 워크로드는?
  - **Sequential**: sector를 **순서대로** 접근 → **transfer dominated** → 빠름
  - **Random**: sector를 **임의로** 접근 → **seek + rotation dominated** → 느림

### 5.1 Disk Spec 비교

| | Cheetah | Barracuda |
|---|---|---|
| Capacity | 300 GB | 1 TB |
| RPM | 15,000 | 7,200 |
| Avg Seek | 4 ms | 9 ms |
| Max Transfer | 125 MB/s | 105 MB/s |
| Platters | 4 | 4 |
| Cache | 16 MB | 32 MB |

- Cheetah = 성능형(엔터프라이즈, 15K RPM을 위해 지름이 작은 platter 사용), Barracuda = 용량형(데스크톱, 지름이 큰 platter를 써서 seek 비용이 큼)

### 5.2 Sequential Throughput

- Seek·rotation이 거의 없으므로 **Max Transfer가 그대로 throughput**
  - Cheetah: **125 MB/s**
  - Barracuda: **105 MB/s**

### 5.3 Random Throughput (16 KB read 가정)

Random은 **요청 1건당 크기**를 알아야 계산 가능 → 16 KB로 가정

**Cheetah**

```
Seek       = 4 ms
Rotation   = 1/2 × (1 min / 15000) × (60 s / 1 min) × (1000 ms / 1 s) = 2 ms
Transfer   = (1 s / 125 MB) × 16 KB × (1,000,000 µs / 1 s) = 125 µs
Total      = 4 + 2 + 0.125 ≈ 6.1 ms

Throughput = (16 KB / 6.1 ms) × (1 MB / 1024 KB) × (1000 ms / 1 s) ≈ 2.5 MB/s
```

**Barracuda**

```
Seek       = 9 ms
Rotation   = 1/2 × (1 min / 7200) × (60 s / 1 min) × (1000 ms / 1 s) ≈ 4.1 ms
Transfer   = (1 s / 105 MB) × 16 KB × (1,000,000 µs / 1 s) ≈ 149 µs
Total      = 9 + 4.1 + 0.149 ≈ 13.2 ms

Throughput = (16 KB / 13.2 ms) × (1 MB / 1024 KB) × (1000 ms / 1 s) ≈ 1.2 MB/s
```

### 5.4 결과

| | Cheetah | Barracuda |
|---|---|---|
| Sequential | **125 MB/s** | **105 MB/s** |
| Random (16KB) | **2.5 MB/s** | **1.2 MB/s** |
| 요청당 시간 | 6.1 ms | 13.2 ms |
| IOPS (≈ 1000 / 요청당 ms) | 약 164 | 약 76 |

- Random이 Sequential보다 **Cheetah는 약 50배, Barracuda는 약 90배** 느림
- 데이터를 옮기는(transfer) 데는 시간이 거의 안 드는데 **위치를 찾는(seek + rotation) 데 시간을 다 씀**
- Barracuda는 platter가 크고 RPM이 낮아서 random에서 격차가 더 큼

---

## 6. AI 워크로드와 HDD

- 워크로드마다 디스크의 **geometry·mechanical 특성에 맞는 패턴**이 있음 → "어떤 AI 워크로드가 **disk-friendly**한가?"가 질문임

### 6.1 학습 데이터 로딩 패턴

```
Disk ──(load)──▶ CPU RAM ──▶ GPU ──▶ 신경망 모델 ──▶ Softmax ──▶ 예측
```

- 이미지 분류 학습 데이터는 **작은 파일이 대량**으로 있음
- Epoch마다 셔플해서 읽으므로 → **작은 파일 Random read** → **HDD 입장에서 최악의 패턴**
- **메모리(RAM)가 크면** 한 번 올린 데이터를 재사용해서 **디스크 접근 비용을 최소화**할 수 있음
- 메모리가 부족한 상태라면 좋은 패턴이 아님
- 게다가 실제 환경은 단일 서버가 아니라 **multi-node 학습**이라 I/O 문제가 더 커짐

### 6.2 개선 방향

- **작은 파일들을 하나의 큰 파일로 묶어(압축/패킹) 저장**하면
  - Random read → **Sequential read**로 바뀌어 HDD 친화적이 됨
  - 파일 수가 줄어 **데이터 관리(메타데이터) 비용**도 줄어듦
  - 대표적인 예: TFRecord, WebDataset(tar shard), HDF5, LMDB
- 반대로 모델 checkpoint처럼 **큰 파일을 순차로 쓰는 작업**은 상대적으로 HDD 친화적임

---

## 7. Other Improvements

### 7.1 Track Skew

- 상황: 15번(안쪽 track 마지막) 다음에 16번(바깥 track 첫 번째)을 순차로 읽는 경우
- 문제: Head가 바깥 track으로 이동·**settle하는 동안 16번이 이미 지나가 버림** → **거의 한 바퀴를 다시 기다려야 함**
- 해결: **Track skew** — 인접 track 간 sector 번호 시작 위치를 **어긋나게(offset)** 배치
  - Arm 이동 시간 + settle 시간 동안 platter가 회전하는 양을 계산해서 번호를 매김
  - Head가 자리를 잡은 직후 16번이 도착하도록 함 → **"enough time to settle now"**
- 핵심: **Arm 이동 시간과 platter 회전 시간을 함께 고려**한 geometry 설계임

### 7.2 Zones (ZBR, Zoned Bit Recording)

- 바깥쪽 track은 안쪽보다 **둘레가 길다** → 같은 수의 sector만 두면 공간 낭비
- **ZBR: 바깥쪽 track에 더 많은 sector를 배치**
- Track들을 **zone** 단위로 묶음
  - **같은 zone 안의 track들은 track당 sector 수가 같음**
  - 바깥 zone으로 갈수록 track당 sector 수가 많음 (예: 안쪽 zone의 약 2배)
- 이렇게 **geometry상 track당 sector 수를 차등(differential)으로 두는 기술을 zoning**이라고 함
- 부수 효과: 회전 속도(RPM)는 일정하므로 **바깥 zone이 초당 더 많은 sector를 지나감 → sequential transfer rate가 더 높음**

### 7.3 Drive Cache (Buffering)

- Drive는 **read와 write 모두 cache**할 수 있음 (OS도 따로 cache함 — page cache)
- Disk 안에 **internal memory(DRAM, 슬라이드 기준 2~16 MB, spec 예시 16~32 MB)** 가 있어 cache로 사용

#### (1) Read-ahead: "Track buffer"

- **Rotational delay 동안 track 전체를 메모리에 읽어 둠**
- Drive는 위에서 무엇을 읽을지 **아무것도 모름** → 할 수 있는 최선은 휴리스틱
  - "한 번 요청이 오면 그 track에 있는 건 일단 몽땅 읽어 두자"
- 위(OS·파일시스템)는 "순차로 읽으면 빠르다"는 걸 알고 최대한 순차적으로 배치하려 노력함
- 아이디어: **위에서 다음에 뭘 읽을지 힌트를 내려주면** 더 효율적일 것임 → 계층 간 정보 단절이 근본 문제

#### (2) Write caching with volatile memory

- **쓰기 경로**

```
[App heap buffer] ──▶ [OS page cache (RAM)] ──A──▶ [Disk DRAM] ──B──▶ [Magnetic platter]
                                                     (A ≪ B)
```

- Save 버튼을 누르면 데이터는 RAM의 어떤 주소에 있다가 **영속화(persist)** 되어야 함
- 핵심 질문: **디스크는 어디까지 쓴 다음에 "다 썼다"고 ACK를 보내야 하는가?**
- **Writeback / Immediate reporting**
  - Platter까지 기록한 뒤 응답하면 오래 걸림(B가 큼)
  - 그래서 **Disk DRAM에만 넣어 두고 바로 완료 응답**을 보냄 → 실제로는 아직 디스크에 안 써졌는데 썼다고 주장하는 것
  - Disk는 **여유가 될 때** DRAM의 데이터를 platter에 기록함 → 내리는 시점은 **디바이스가 결정**
- 위험: **전원 장애(power failure) 시 DRAM의 데이터가 날아감**
  - Save가 성공했다고 응답받았는데 실제로는 저장이 안 됨 → **데이터 손실**
  - 상위 계층(파일시스템, DB) 입장에서 **consistency(일관성)가 깨짐**

#### (3) 여러 디스크 환경: Striping과 Jitter

- 데이터센터에는 디스크가 1~2개가 아니라 **수천 개** 있음
- **Striping**: 디스크가 여러 대일 때 하나의 데이터를 **여러 디스크에 쪼개서** 저장함
- 컨트롤러 밑에 4개 디스크가 있어도 각 디스크의 상태(writeback 시점, cache 상태 등)가 서로 다름
  - 위에서는 동일하게 썼는데 어떤 디스크는 느리고 어떤 디스크는 빠름
  - Striping된 요청은 **가장 느린 디스크**를 기다려야 완료됨
- 이런 응답 시간 편차를 **Jitter**라고 함 → tail latency를 키우는 위험 요소임

#### (4) Tagged Command Queueing (TCQ)

- 디스크에 **여러 요청을 동시에 걸어 둘 수 있음**(multiple outstanding requests)
- 디스크가 내부 queue(R0, R1, R2, R3, R4 …)를 보고 **각 요청의 위치 정보**를 바탕으로 **순서를 재배치(reorder/schedule)**
  - 스케줄 정책 0번 → 정책 1번처럼 순서를 바꿔 성능을 높임
- **Drive 제조사 쪽에서 한 최적화**임
- SATA에서는 같은 개념을 **NCQ(Native Command Queuing)** 라고 부름

---

## 8. I/O Scheduling

- 질문: **I/O 요청 스트림이 주어졌을 때 어떤 순서로 처리할까?**
- **CPU 스케줄링과 많이 다름**
  - CPU: job 길이가 중요
  - Disk: **요청 위치가 head 위치에서 얼마나 떨어져 있는지**가 job 길이보다 훨씬 중요

### 8.1 FCFS (First-Come-First-Serve) = FIFO

- 가정: random 요청 1건의 seek + rotate = 10 ms, 요청은 sector 번호로 주어짐

| 요청 순서 | 소요 시간 |
|---|---|
| 300001, 700001, 300002, 700002, 300003, 700003 | **약 60 ms** (매번 멀리 점프 → 6 × 10 ms) |
| 300001, 300002, 300003, 700001, 700002, 700003 | **약 20 ms** (큰 점프 2번 → 2 × 10 ms, 나머지는 인접) |

- 순서만 바꿔도 3배 차이 → 이 재배치를 해주는 것이 **command queueing**임

### 8.2 스케줄러는 어디에 둬야 하나? (OS vs Disk)

| | OS Scheduler | Disk Scheduler |
|---|---|---|
| 보는 정보 | **논리 주소(LBA) 0 ~ N−1** 블록 집합만 봄 | 실제 **geometry** (cylinder, head, sector, 현재 회전 위치) |
| 추상화 | 디스크가 몇 개 platter인지, 물리 배치가 어떤지 **알 필요도 없고 모름** | LBA → 물리 위치 매핑을 컨트롤러가 알아서 판단 (예: "15번은 어디") |
| 가능한 스케줄링 | 논리 주소 거리 기반 (SSTF 근사) | 회전 위치까지 고려한 SPTF 가능 |
| 장점 | 상위 워크로드 정보(프로세스, 우선순위)를 앎 | 정확한 위치 비용을 앎 |

- OS는 디스크 geometry를 **추상화(abstraction)** 해서 논리 블록으로만 봄
- Command queueing / TCQ는 **디스크 쪽**에서, 논리 주소 기반 정렬은 **OS 쪽**에서 수행 → 현재는 **둘 다 존재**
- **연구 주제: Unified scheduling / Unified buffer**
  - OS와 Disk의 스케줄러(·버퍼)를 **통합하면 얼마나 효과가 있을까?**
  - 현재 표준 인터페이스를 깨고 **새 표준**이 필요할 수 있음
  - 기술적 challenge를 정의하고 해결하면 좋은 연구가 됨

### 8.3 SPTF (Shortest Positioning Time First)

- **전략**: positioning time(**seek + rotation**)이 가장 짧은 요청을 항상 먼저 처리
  - **Greedy 알고리즘** — 바로 다음 한 수만 최선으로 고름
- **Disk에서 구현**: 현재 head 위치·회전 위치를 알기 때문에 구현 가능
- **OS에서 구현**: 회전 위치를 모르므로 대신 **SSTF(Shortest Seek Time First)** 사용
  - SSTF = seek(head 이동)만 최소화하도록 스케줄링
- **단점**: 멀리 있는 요청이 계속 밀려 **starvation(기아 현상)** 이 발생하기 쉬움

### 8.4 SCAN / C-SCAN

- **SCAN (Elevator Algorithm)**
  - 디스크 한쪽 끝에서 다른 쪽 끝까지 **왕복 sweep**하면서 지나가는 cylinder의 요청을 처리
  - **cylinder 번호로 정렬**, rotation delay는 **무시**
  - 장점: starvation이 없음
  - 단점: 왕복하기 때문에 **가운데 cylinder가 더 자주 서비스됨** (양 끝은 불리), rotation 비용 미반영
- **C-SCAN (Circular SCAN)** — 더 나은 방식
  - **한 방향으로만 sweep**하고 끝에 도달하면 처음으로 돌아가 다시 시작
  - 위치에 따른 대기 시간 편차가 줄어 더 공정함

| 알고리즘 | 기준 | 구현 위치 | Starvation | 비고 |
|---|---|---|---|---|
| FCFS | 도착 순서 | 어디든 | 없음 | 위치 무시 → 비효율 |
| SSTF | seek 거리 | OS | **있음** | 회전 무시 |
| SPTF | seek + rotation | Disk | **있음** | Greedy |
| SCAN | cylinder 순 왕복 | OS | 없음 | 가운데 편향 |
| C-SCAN | cylinder 순 단방향 | OS | 없음 | 더 공정 |

### 8.5 Bad Sector와 Spare Sector 재매핑

- 디스크에 **bad sector**가 생겨도 **여분(spare) sector**가 있으면 해당 영역을 spare sector로 **재매핑(remap)** 함
  - 이 작업은 컨트롤러가 LBA → 물리 매핑 안에서 처리하므로 OS가 인식하는 전체 용량이나 `df`의 Size는 **일반적으로 변하지 않음**
- Spare sector가 **모두 소진**되면 더 이상 재매핑이 안 됨 → 해당 물리 영역은 실제 저장에 쓸 수 없음
  - 이때도 디스크의 논리 용량이나 `df` Size가 **자동으로 줄지는 않음**
  - 대신 해당 영역 접근 시 **I/O 오류**가 발생하거나, 파일시스템이 해당 블록을 쓰지 않도록 관리하면서 **실질적인 가용 용량이 감소**함

---

## 9. 데이터센터 관점

### 9.1 노드의 역할

- **Compute node**: GPU·CPU 중심, 계산 담당
- **Storage node**: 서버 수는 적지만 **디스크가 많이 달려 있음**, 저장 담당
- 같은 "서버"라도 **역할**에 따라 구성이 다름 (Storage node에는 GPU가 없을 수도 있음)

### 9.2 데이터 보호 방식

| 방식 | 보호 방법 |
|---|---|
| **단일 서버** | **RAID** 구성 → 1번 디스크가 죽어도 다른 디스크로 복구. **Hot spare**를 두고 장애 시 자동 교체 |
| **분산 저장** | **Replica**를 여러 노드에 두어 **redundancy** 제공 |

- 분산 저장이라고 데이터 손실이 없는 게 아니므로 replica 등으로 보호해야 함
- AI DC는 **high performance** 방향으로 가면서 매우 **reliable한 환경**을 전제로 설계됨

---

## 10. Storage Latest Trends

- 스토리지는 다음 세 조건을 만족하는 방향으로 진화 중
  1. **High performance**
  2. **High capacity**
  3. **Specialized usage** (특정 용도 특화)
- 진화 방향은 **스토리지 종류**(HDD, SSD)와 **인터페이스**(SATA, SAS, PCIe)에 따라 다름

### 10.1 Is HDD Dead? → No

- **비용 효율과 대용량** 덕분에 여전히 널리 쓰임
- 데이터센터는 **PB ~ EB 규모** 대용량 저장에 여전히 HDD 사용
- **CERN EOS**: Tape + HDD로 EB급 저장
  - 현재: **디스크 서버 약 900대, HDD 약 70,000개**
  - 차세대 서버 구성: 서버당 **HDD 1.68 PB**, Single CPU, 384 GB RAM, 200/400 GbE, **NVMe/SSD는 HDD 용량의 약 10%**
- **ORNL Frontier**: HDD + SSD 조합으로 PB급 고속 저장

### 10.2 HDD Reliability — Helium-filled Drive

- 공기(Air-filled) 대신 **헬륨(Helium-filled)** 을 채운 드라이브로 전환 중
  1. 마찰 감소 → **더 얇은 platter** 가능
  2. **platter 진동(flutter) 감소** → 고장 감소
  3. 얇은 platter를 더 많이 넣음 → **고용량**
- 예시(HGST Ultrastar He12, 12TB, 8TB air drive 대비): 용량 **50%↑**, 전력(W/TB) **54%↓**, 신뢰성 **25%↑** (MTBF 250만 시간)

### 10.3 HDD Capacity — 기록 방식 혁신

- 기존 자기 기록 방식의 **물리적 한계**로 용량 확장이 막힘
- 고밀도를 위해 자성 입자를 작게 하면 **열적 불안정성**(자기 정보가 쉽게 날아감)이 생김

| 기술 | 원리 | 장점 | 단점 | 적합한 활용 |
|---|---|---|---|---|
| **HAMR** (Seagate, Heat-Assisted) | 레이저 다이오드로 platter 미세 영역을 순간 **가열** → 자성을 쉽게 뒤집어 기록 → 빠르게 식혀 안정화 | 가장 높은 잠재 밀도, 수십~수백 TB 확장성 | 헤드에 레이저 통합 → 제조 난도 높음, 발열·내구성·비용 | 미래 초고용량 HDD |
| **MAMR** (Western Digital, Microwave-Assisted) | 헤드의 **STO(Spin Torque Oscillator)** 가 마이크로파 자기장 발생 → 자기입자를 **공진** 상태로 만들어 자화 반전을 쉽게 함 | 레이저 불필요 → 구현 단순, 기존 공정 호환성 높음 | 이론적 최대 밀도는 HAMR보다 낮음, STO 효율·안정성 | 차세대 상용 HDD |
| **SMR** (Shingled) | Track을 **기와(shingle)처럼 겹쳐** 배열 | 저비용 고용량 (20TB+ 상용화) | **Random write 성능 저하** | 백업, 콜드 스토리지, 아카이빙 |

- HAMR/MAMR의 목표: **데이터 안정성을 유지하면서 고밀도** 달성

### 10.4 SMR HDD 상세

- 인접 track을 **겹쳐서** areal density(면적 밀도)를 높임
- 기존 HDD보다 **track 수가 많고**, 이를 **zone** 단위로 묶음
- 쓰기 시 인접 track을 덮어쓰게 되므로 → **zone 안에서는 sequential write만 허용**
  - Random write가 필요하면 재기록 구간이 생겨 오버헤드 발생
- 순차 쓰기 제약에도 **대용량** 덕분에 **WORM(Write-Once Read-Many)**, 아카이브 스토리지에 널리 사용
  - 예: WD **HC670 (SMR) 26TB** vs **HC570 (CMR) 22TB** → 같은 세대에서 SMR이 더 큼
- 이 **"zone 단위 순차 쓰기"** 개념은 이후 **Zoned Storage / ZNS SSD** 로 이어짐 (5주차 로그 기반 파일시스템·SSD 최적화와 연결)

---

## 11. HDD/SSD Arrays

### 11.1 Array의 장점

| 항목 | 설명 |
|---|---|
| **Performance** | 여러 드라이브에 **병렬 접근** |
| **Scalability** | 용량 확장이 쉬움 |
| **Reliability** | RAID로 **redundancy** 확보 |
| **Efficiency** | IOPS·bandwidth 활용 극대화 |

### 11.2 대표 구성

| 구성 | 방식 | 특징 |
|---|---|---|
| **RAID-0** | **Striping** | 고성능, **redundancy 없음** (하나만 죽어도 전체 손실) |
| **RAID-1** | **Mirroring** | redundancy 있음, 용량 절반으로 감소 |
| **RAID-5/6** | **Parity** 기반 | redundancy + 준수한 성능 (RAID-5: 1개, RAID-6: 2개 디스크 장애 허용) |
| **JBOD** | Just a Bunch Of Disks | RAID 없이 raw 용량 그대로 사용 |

### 11.3 All-Flash SSD Array 제품

- **Pure Storage FlashArray**: 엔터프라이즈급, 고신뢰성, NVMe 지원
- **Dell EMC PowerStore**: NVMe 최적화, block·file 워크로드 통합 스토리지
- **NetApp AFF (All Flash FAS)**: 고처리량, **중복제거(deduplication)·압축** 지원

---

## 12. 실무 연결 (Linux / PostgreSQL)

| 확인 대상 | 명령 / 설정 | 강의 내용과의 연결 |
|---|---|---|
| HDD/SSD 구분 | `lsblk -d -o NAME,ROTA` (ROTA=1이면 회전식 HDD) | 기계식 여부 |
| I/O 스케줄러 | `cat /sys/block/sda/queue/scheduler` → `none`, `mq-deadline`, `bfq`, `kyber` | 8장. deadline 계열은 **요청별 마감 시간**으로 starvation을 막음. NVMe SSD는 보통 `none` |
| Drive write cache | `hdparm -W /dev/sda` | 7.3(2) 조기 ACK·전원 장애 손실 위험 |
| Bad sector 재매핑 수 | `smartctl -A /dev/sda` → `Reallocated_Sector_Ct` | 8.5. 값이 계속 증가하면 교체 신호 |
| Read-ahead 크기 | `blockdev --getra /dev/sda` | 7.3(1) track buffer / 상위 계층 힌트 |
| Postgres 영속성 | `fsync`, `synchronous_commit`, WAL | ACK를 언제 줄 것인가의 DB 버전 (DB 시스템 주차에서 WAL로 다시 다룸) |
| Postgres 플래너 비용 | `seq_page_cost = 1.0`, `random_page_cost = 4.0`(기본) | **HDD의 random ≫ sequential** 가정이 기본값에 반영됨. SSD 환경이면 `random_page_cost`를 1.1 정도로 낮추는 게 일반적 |

---

## 13. 용어 정리

| English | 한국어 / 의미 |
|---|---|
| Sector-addressable | sector 단위로 주소 지정 가능 |
| Platter / Spindle | 원판 / 회전축 |
| Surface / Track / Cylinder | 기록면 / 동심원 트랙 / 같은 반경 트랙 묶음 |
| Read/Write Head, Arm (Actuator) | 읽기·쓰기 헤드, 헤드를 옮기는 팔 |
| Servo system / Servo burst | 헤드 위치 제어 시스템 / 주기적으로 기록된 위치 정보 |
| Runout | 트랙이 완벽한 동심원이 아니어서 생기는 흔들림 |
| BPI / TPI | 인치당 비트 수 / 인치당 트랙 수 (기록 밀도) |
| Seek time | 헤드를 목표 트랙으로 옮기는 시간 |
| Accelerate / Coast / Decelerate / Settle | 가속 / 등속 / 감속 / 안착 |
| Rotational delay (latency) | 목표 sector가 헤드 밑에 올 때까지 회전 대기 시간 |
| Transfer time | 실제 데이터 전송 시간 |
| RPM | 분당 회전수 |
| Throughput / IOPS | 초당 처리 데이터량 / 초당 I/O 처리 건수 |
| Sequential / Random workload | 순차 / 임의 접근 워크로드 |
| Track skew | 인접 트랙 sector 번호를 어긋나게 배치하는 기법 |
| ZBR (Zoned Bit Recording) | 바깥 트랙에 sector를 더 많이 두는 zone 기반 기록 |
| Track buffer (Read-ahead) | 트랙 전체를 미리 읽어 캐시 |
| Write caching / Immediate reporting | 쓰기를 DRAM에 받고 바로 완료 응답 |
| Writeback | 캐시 데이터를 나중에 실제 매체에 기록 |
| Striping | 데이터를 여러 디스크에 쪼개 저장 |
| Jitter | 응답 시간 편차 |
| TCQ / NCQ | 디스크 내부에서 여러 명령을 큐잉·재정렬하는 기술 (SCSI/SAS / SATA) |
| LBA (Logical Block Address) | OS가 보는 논리 블록 주소 |
| FCFS, SSTF, SPTF, SCAN, C-SCAN | 디스크 스케줄링 알고리즘 |
| Starvation | 기아 현상 (특정 요청이 계속 밀림) |
| Greedy algorithm | 매 순간 최선만 고르는 알고리즘 |
| Bad sector / Spare sector / Remap | 불량 섹터 / 여분 섹터 / 재매핑 |
| Hot spare | 장애 시 즉시 투입되는 대기 디스크 |
| Replica / Redundancy | 복제본 / 중복성 |
| Helium-filled drive | 헬륨 충전 HDD |
| HAMR / MAMR / SMR | 열 보조 / 마이크로파 보조 / 기와식 자기 기록 |
| STO (Spin Torque Oscillator) | 스핀 토크 발진기 |
| Areal density | 면적 기록 밀도 |
| WORM | Write-Once Read-Many, 한 번 쓰고 여러 번 읽는 저장 |
| RAID-0/1/5/6, JBOD | Striping / Mirroring / Parity / 단순 디스크 묶음 |
| Deduplication | 중복 제거 |
| MTBF | 평균 고장 간격 시간 |

---

## 14. 자기 점검 체크리스트

- [ ] Platter, surface, track, cylinder, sector의 관계를 그림으로 그릴 수 있는가?
- [ ] Servo burst가 왜 필요한지(runout, BPI/TPI 증가) 설명할 수 있는가?
- [ ] I/O 시간 3요소와 각각의 대략적 크기(ms / ms / µs)를 말할 수 있는가?
- [ ] Seek의 4단계와 long seek / short seek의 차이를 설명할 수 있는가?
- [ ] 평균 seek distance가 최대의 1/3인 이유를 적분으로 보일 수 있는가?
- [ ] 임의의 RPM에서 평균 rotational delay를 계산할 수 있는가? (7200 → 약 4.2 ms, 15000 → 2 ms)
- [ ] Cheetah / Barracuda의 random 16KB throughput(2.5 / 1.2 MB/s)을 직접 계산할 수 있는가?
- [ ] 작은 이미지 파일 기반 학습이 HDD에 불리한 이유와 개선 방법을 말할 수 있는가?
- [ ] Track skew가 해결하는 문제를 15→16 예시로 설명할 수 있는가?
- [ ] ZBR에서 바깥 zone의 sequential 성능이 더 좋은 이유를 말할 수 있는가?
- [ ] Write caching의 조기 ACK가 consistency를 깨뜨리는 시나리오를 설명할 수 있는가?
- [ ] Striping 환경에서 jitter가 왜 문제인지 말할 수 있는가?
- [ ] FCFS 예시에서 60 ms → 20 ms가 되는 이유를 설명할 수 있는가?
- [ ] OS 스케줄러와 Disk 스케줄러가 각각 아는 정보의 차이를 설명할 수 있는가?
- [ ] OS에서 SPTF 대신 SSTF를 쓰는 이유, 그리고 둘의 공통 단점은?
- [ ] SCAN과 C-SCAN의 차이, SCAN의 가운데 편향을 설명할 수 있는가?
- [ ] Spare sector가 소진되면 `df` 용량과 실제 가용 용량이 어떻게 되는지 말할 수 있는가?
- [ ] HAMR / MAMR / SMR의 원리·장단점·활용처를 비교할 수 있는가?
- [ ] SMR의 zone이 sequential write만 허용하는 이유를 말할 수 있는가?
- [ ] RAID-0/1/5/6과 JBOD의 차이를 말할 수 있는가?