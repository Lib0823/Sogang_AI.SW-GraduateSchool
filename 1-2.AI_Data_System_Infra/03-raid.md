# AI 데이터 시스템 및 인프라 — 3주차 정리
## RAID — Reliability and Performance in Storage Systems

> 김영재 교수 · 3주차
> 강의자료: `3_FileSystem_RAID_v1.pdf` (총 63p) / 담당: 김영재 교수
> 이번 주 범위: p.1 ~ p.59 (RAID 전 레벨 + HDD/SSD Array + Parallel FS)
> p.60~63 (VAST / DASE)는 다음 시간 → 맨 아래 **예습** 섹션에 별도 정리

---

## 0. 이번 주 큰 그림

한 줄 요약: **여러 개의 싼 디스크를 묶어서, 애플리케이션에게는 "빠르고 크고 안 죽는 디스크 한 개"처럼 보이게 만드는 기술이 RAID다.**

이걸 만들기 위한 도구는 딱 두 개뿐이다.

| 도구 | 목적 | 대가 |
|---|---|---|
| **Mapping (striping)** | capacity, performance 확보 | 디스크 하나 죽으면 전부 날아감 |
| **Redundancy (mirror/parity)** | reliability 확보 | 용량 손실, write 비용 증가 |

RAID 레벨이 여러 개 존재하는 이유는 이 두 도구를 어떤 비율로 섞느냐의 **trade-off** 차이일 뿐이다. 따라서 모든 레벨을 `capacity / reliability / latency / throughput` 네 항목으로 계산해서 비교하는 것이 이 챕터의 전부다. **시험도 이 계산이 나온다.**

---

## 1. 왜 디스크가 여러 개 필요한가 (p.2 ~ p.5)

### 1.1 Only One Disk?

디스크를 여러 개 쓰고 싶은 이유는 세 가지다.

- **Capacity** — 디스크 하나 용량으로는 부족함
- **Reliability** — 디스크는 물리적으로 반드시 고장남. 한 개면 고장 = 데이터 전멸
- **Performance** — 한 개의 디스크가 낼 수 있는 throughput에는 한계가 있음 (HDD면 헤드가 하나뿐)

문제는 **대부분의 파일 시스템은 디스크 한 개 위에서만 동작하도록 설계돼 있다**는 점이다. ext4 하나가 디스크 8개를 알아서 묶어주지 않는다. 그래서 "디스크 여러 개"를 어떻게 파일 시스템에게 보여줄 것인가가 설계 문제가 된다.

### 1.2 Solution 1 — JBOD (Just a Bunch Of Disks)

```
        Application
   FS    FS    FS    FS
   D0    D1    D2    D3
```

디스크마다 파일 시스템을 하나씩 따로 올리고, **애플리케이션이 똑똑해서** 어떤 파일을 어느 파일 시스템에 넣을지 직접 결정하는 방식이다.

- 장점: 단순하고 오버헤드 없음. 디스크 하나 죽어도 나머지는 멀쩡함
- 단점: **애플리케이션이 전부 떠안음**. 하나의 큰 파일이 디스크 용량보다 크면 못 넣고, 부하 분산도 직접 해야 하고, redundancy도 없음
- 지금도 HDFS·Ceph 같은 분산 스토리지에서는 하부를 일부러 JBOD로 두고 **소프트웨어 레벨에서 복제·분산**을 처리한다 (RAID가 중복으로 일하는 걸 막기 위해)

### 1.3 Solution 2 — RAID

```
        Application
            FS
     Fake Logical Disk      ← RAID 계층
   D0    D1    D2    D3
```

여러 개의 physical disk를 묶어 **하나의 가짜 논리 디스크(fake logical disk)** 로 위에 보여준다. RAID의 두 가지 핵심 성질:

- **Transparent** — 위쪽(FS, 애플리케이션)은 RAID가 있는지조차 모름. 그냥 큰 디스크 하나로 보임. 코드 수정 불필요
- **Deployable** — 기존 시스템에 그대로 꽂아 쓸 수 있음

그 대가로 논리 디스크가 제공하는 것: **capacity, performance, reliability**.

### 1.4 Why *Inexpensive* Disks?

RAID의 I는 원래 **Inexpensive**(나중에 Independent로도 불림)다.

- **Economies of scale** — 대량 생산되는 commodity 디스크가 단가가 훨씬 싸다
- 고급 디스크 몇 개 살 돈이면 commodity 디스크를 여러 개 살 수 있다
- **전략: 싼 하드웨어 여러 개 + 똑똑한 소프트웨어 = 고품질 논리 장치**
- RAID의 대안은 그냥 비싼 high-end 디스크 하나 사는 것인데, 비용 대비 효율이 나쁘다

> 이 사고방식(싼 부품 + 소프트웨어로 신뢰성 확보)은 이후 GFS, HDFS, 클라우드 인프라 전체를 관통하는 원칙이다.

---

## 2. General Strategy — Mapping과 Redundancy (p.6 ~ p.9)

### 2.1 Mapping: logical block → physical block

논리 블록 주소(LBA)를 물리 블록 주소(PBA)로 어떻게 변환할 것인가. Virtual memory의 주소 변환과 구조적으로 유사하다.

| 구분 | 방식 | 예시 | 특징 |
|---|---|---|---|
| **Dynamic mapping** | 자료구조 사용 (hash table, tree) | page table, SSD의 FTL | 유연·자유도 높음 / **메모리 소모, CPU 사이클 소모, 느림** |
| **Static mapping** | 단순 수식 계산 | **RAID** | 수학 계산 한 번으로 즉시 주소 산출 / 빠르고 하드웨어 구현 쉬움 |

강의 포인트:
- Dynamic은 자료구조를 **메모리에 로딩**해야 하고 조회 비용이 든다. flexibility는 높지만 복잡하고 **하드웨어로 구현하기 어렵다**. 자료구조를 잘 다루는 건 소프트웨어 쪽이다.
- RAID가 static mapping을 쓰는 이유가 바로 이것. RAID 컨트롤러는 하드웨어로 구현되므로, 나눗셈·나머지 연산만으로 주소가 나와야 한다.

### 2.2 Redundancy (중복성)

redundancy 양에 대한 trade-off:

- **copy 수를 늘림 (increase)** → **reliability 향상**, 그리고 경우에 따라 **performance도 향상**
  - 같은 데이터가 여러 디스크에 있으면 read를 병렬로 분산할 수 있기 때문
  - 실무에서 분산 시스템은 보통 **3 copy**까지 둔다. 4 copy 이상은 거의 없다 (비용 대비 신뢰성 향상 폭이 미미)
- **copy 수를 줄임 (decrease) = deduplication** → **space efficiency 향상**

### 2.3 Efficiency를 높이는 두 기술: Compression vs Deduplication

| | Compression (압축) | Deduplication (중복 제거) |
|---|---|---|
| 대상 | 데이터 **내부**의 반복 패턴 | 서로 다른 블록/파일 **간**의 동일 내용 |
| 원리 | 규칙적 패턴을 짧은 비트로 재인코딩 | 내용이 같으면 실제 저장은 1개만, 나머지는 포인터 |
| 한계 | 이미 인코딩된 데이터(JPEG, MP4, 암호화 데이터)는 규칙적 패턴이 없어 **거의 안 줄어듦** | fingerprint 계산 비용 |

**Deduplication의 동작 — fingerprint**

```
FileA = {100, 101, 102}
FileB = {200, 201, 202}

fp(100) == fp(200)  →  두 블록은 내용이 같다  →  하나만 저장
fp = fingerprint function { SHA-1 → HASH }
```

- 블록 내용을 해시 함수(SHA-1 등)에 통과시켜 **fingerprint**를 만들고, fingerprint가 같으면 같은 내용으로 간주해 한 벌만 저장한다
- 블록 전체를 바이트 단위로 비교하는 대신 고정 길이 해시만 비교하므로 빠르다
- 이론상 hash collision 가능성이 있어, 민감한 시스템은 fingerprint 일치 후 실제 바이트 비교(byte-by-byte verify)를 한 번 더 한다

---

## 3. 분석 프레임 — Workload × Metric (p.10 ~ p.13)

RAID를 논할 때는 항상 세 가지를 같이 본다.

- **RAID**: logical → physical block을 매핑하는 시스템
- **Workload**: 애플리케이션이 발생시키는 read/write의 종류 (**sequential vs random**)
- **Metric**: capacity, reliability, performance

### 3.1 Workload 4분면

read/write × sequential/random 조합. 이게 그대로 시험 표의 4개 열이 된다.

- **Sequential** — 논리 주소가 연속. 대용량 파일 읽기/쓰기, 로그, AI 학습 데이터 로딩
- **Random** — 논리 주소가 흩어짐. DB 트랜잭션, 메타데이터 접근
- 그 외 단발성 연산인 **one operation**(latency로 측정)과 지속적 부하인 **steady-state I/O**(throughput으로 측정)를 구분한다

### 3.2 Metric 정의 ★ (시험 계산의 기본 단위 — 반드시 암기)

| 기호 | 의미 |
|---|---|
| **N** | 디스크 개수 (number of disks) |
| **C** | 디스크 1개의 용량 (capacity of 1 disk) |
| **S** | 디스크 1개의 **sequential** throughput |
| **R** | 디스크 1개의 **random** throughput |
| **D** | 작은 I/O 연산 1개의 latency |

- **Capacity**: 앱이 실제로 쓸 수 있는 공간이 얼마인가
- **Reliability**: **몇 개의 디스크까지 잃어도 안전한가** (fail-stop 가정)
- **Performance**: 각 workload가 얼마나 걸리는가. **모든 값을 디스크 1개의 특성으로 정규화**해서 표현한다

### 3.3 Fail-Stop 모델

RAID 분석의 기본 고장 가정이다.

- 디스크는 **정상 동작하거나, 완전히 죽거나 둘 중 하나**다 (중간 상태 없음)
- **시스템은 디스크가 죽었다는 사실을 알 수 있다** (어느 디스크가 죽었는지 식별 가능)

이 가정이 있어야 parity 복구가 성립한다. "어느 값이 모르는 값(unknown)인지" 알아야 방정식을 풀 수 있기 때문이다.

**Fail-stop으로 안 잡히는 어려운 에러들 (Tougher Errors):**

- **Latent sector error** — 특정 섹터만 조용히 망가져 있다가, 읽으려는 순간에야 발견됨. 디스크는 살아있으므로 fail-stop이 아님
- **Silent data corruption** — 데이터가 잘못됐는데 디스크가 에러조차 보고하지 않음. 살았냐 죽었냐를 판정하려면 **실제로 데이터를 읽어서 integrity check(checksum 검증)** 를 해봐야 알 수 있음
- 실무에서는 이를 잡기 위해 **scrubbing**(주기적 전체 읽기 검사) + **block checksum**을 쓴다

---

## 4. RAID-0: Striping (p.14 ~ p.18)

### 4.1 개념

**데이터 분산 저장.** capacity와 performance만 최적화하고 **redundancy는 0**이다.

4 disks, chunk size = 1 일 때 레이아웃:

```
Disk0   Disk1   Disk2   Disk3
  0       1       2       3     ← stripe (가로 한 줄)
  4       5       6       7
  8       9      10      11
 12      13      14      15
```

- **stripe**: 여러 디스크에 걸쳐 가로로 한 줄을 이루는 블록들의 집합
- 논리 블록이 디스크들에 **alternate(교대로)** 배치된다

### 4.2 주소 매핑 수식 ★

chunk size = 1 일 때:

```
Disk   = A % disk_count
Offset = A / disk_count      (정수 나눗셈)
```

**예) A = 6, disk_count = 4**
- Disk = 6 % 4 = **2** → Disk2
- Offset = 6 / 4 = **1** → 1번째 행

수식 한 줄로 끝나는 것이 static mapping의 힘이다. 자료구조 조회도, 메모리 접근도 없다.

### 4.3 Chunk size

chunk size = 2 일 때는 연속된 블록 2개가 한 디스크에 묶여 들어간다.

```
chunk size = 1              chunk size = 2
D0  D1  D2  D3              D0    D1    D2    D3
 0   1   2   3              0,1   2,3   4,5   6,7
 4   5   6   7              8,9  10,11 12,13 14,15
```

chunk size 일반화 수식:

```
Disk   = (A / chunk_size) % N
Offset = (A / (chunk_size × N)) × chunk_size + (A % chunk_size)
```

**chunk size trade-off:**

| chunk size | 병렬성 | 디스크당 접근 효율 |
|---|---|---|
| 작게 | 하나의 요청이 여러 디스크에 퍼짐 → **병렬성 ↑** | 요청마다 positioning 비용 발생 → 오버헤드 ↑ |
| 크게 | 요청이 한 디스크에 몰릴 확률 ↑ → 병렬성 ↓ | 한 번에 chunk 개수만큼 연속 read/write → **디스크 효율 ↑** |

### 4.4 RAID-0 Analysis ★

| 항목 | 값 |
|---|---|
| Capacity | **N × C** (손실 0, 최대) |
| Reliability | **0** (디스크 1개만 죽어도 데이터 로스) |
| Latency (read/write) | **D** |
| Sequential throughput | **N × S** |
| Random throughput | **N × R** |

> **핵심 문장: Buying more disks improves throughput, but not latency!**
> 디스크를 8개로 늘리면 초당 처리량은 8배가 되지만, **요청 하나가 끝나는 시간(latency)은 여전히 D**다. 물리적으로 헤드가 움직이는 시간은 줄어들지 않기 때문이다. 이건 시험에서 헷갈리기 딱 좋은 포인트다.

**왜 RAID-0을 쓰는가**: 디스크 8개로 서버를 구성하면 read/write throughput이 그만큼 좋아진다. 단, redundancy가 없으므로 디스크 하나만 fail 나도 전체 데이터 손실이 발생한다. 임시 데이터, 재생성 가능한 캐시, 스크래치 영역에 쓴다.

---

## 5. RAID-1: Mirroring (p.19 ~ p.29)

### 5.1 개념

**모든 데이터의 복사본을 2벌 유지한다.** redundancy만 지원하는 가장 단순한 형태.

2 disks:
```
Disk0   Disk1
  0       0
  1       1
  2       2
  3       3
```

4 disks (mirroring + striping = 실무의 RAID-10):
```
Disk0   Disk1   Disk2   Disk3
  0       0       1       1
  2       2       3       3
  4       4       5       5
  6       6       7       7
```
→ (Disk0,Disk1)이 한 쌍, (Disk2,Disk3)이 한 쌍이고, 쌍끼리는 striping 되어 있다.

### 5.2 RAID-1 Analysis ★

| 항목 | 값 | 이유 |
|---|---|---|
| Capacity | **(N/2) × C** | 절반은 복사본. 늘어난 디스크는 용량이 아니라 **redundancy 목적** |
| Reliability | **1** (보장), 운 좋으면 최대 **N/2** | 같은 쌍의 두 개가 동시에 죽으면 끝. 서로 다른 쌍이면 N/2개까지 버팀 |
| Latency (read) | **D** | 어느 한쪽만 읽으면 됨 |
| Latency (write) | **D** | 두 디스크에 **병렬로** 쓰므로 D (엄밀히는 둘 중 느린 쪽 기준) |

### 5.3 RAID-1 Throughput ★ (혼동 주의)

| Workload | 값 | 이유 |
|---|---|---|
| **Random read** | **N × R** | 복사본이 2벌이라 **모든 디스크가 서로 다른 요청을 병렬 처리** 가능 → 디스크 N개 전부 유효 |
| **Random write** | **(N/2) × R** | 논리 write 1개 = 물리 write 2개. 병렬이라 latency는 D지만 **throughput은 절반** |
| **Sequential write** | **(N/2) × S** | 위와 동일 |
| **Sequential read** | **(N/2) × S** (교재 기준) | 아래 설명 참고. *다른 모델에서는 N × S로 보기도 함* |

**sequential read가 왜 N×S가 아니라 N/2×S인가 (OSTEP 논리):**
Disk0에서 0,2,4,6을 순서대로 읽는다고 하면, 디스크는 1,3,5,7 자리를 **건너뛰며 회전**해야 한다. 헤드가 그 구간을 지나가는 시간은 그대로 소모되므로 디스크 1개가 실제로 내주는 유효 대역폭은 **S/2**다. 따라서 N × (S/2) = **(N/2) × S**.

> **암기 포인트: read는 mirror 덕에 이득(N×R), write는 mirror 때문에 이득 없음(절반).**

### 5.4 Crash — Consistent-Update Problem (p.24 ~ p.31)

RAID-1에서 논리 블록 3에 T를 쓰는 중 전원이 나간 상황:

```
      Disk0   Disk1
  0     A       A
  1     B       B
  2     A       A
  3     D       T     ← Disk1에만 반영되고 CRASH
```

재부팅 후 블록 3을 읽으면 Disk0은 D, Disk1은 T를 준다. **어느 쪽이 진짜인지 알 수 없다.** 이것이 **Consistent-Update Problem**이고, 이 상태를 "crash consistency가 깨졌다"고 한다.

- 문제의 본질: 두 디스크에 대한 write가 **원자적(atomic)이지 않다**는 것
- **H/W 해법: RAID 컨트롤러에 non-volatile RAM(NVRAM)을 둔다.** 진행 중인 write를 NVRAM에 먼저 기록해두면, 재부팅 후 그 로그를 보고 미완료 write를 마저 완료(replay)시켜 두 사본을 일치시킬 수 있다
- **소프트웨어 RAID(예: Linux `md`)에는 이 옵션이 없다.** 배터리 백업 NVRAM이라는 하드웨어 자원을 쓸 수 없기 때문. 그래서 write-intent bitmap, journaling 같은 소프트웨어 기법으로 우회한다

> 하드웨어로 구현하면 이런 기능을 쓸 수 있고, 소프트웨어로 구현하면 못 쓴다 — H/W RAID와 S/W RAID의 근본적 차이 중 하나.

---

## 6. RAID-4: Parity Disk (p.33 ~ p.44)

### 6.1 Strategy — 방정식으로 생각하기

RAID-1은 신뢰성은 좋지만 **용량을 절반 버리는** 게 너무 아깝다. 그래서 복사본 대신 **parity**를 쓴다.

핵심 아이디어:
- 대수학에서 **미지수가 N개인 방정식에서 N-1개를 알면 나머지 1개를 풀 수 있다**
- stripe를 가로지르는 sector들을 **하나의 방정식**으로 취급한다
- 고장난 디스크의 데이터 = 방정식의 **unknown**
- 선형 방정식(관계식)만 들고 있으면 데이터가 사라져도 복구가 가능하다

레이아웃 (5 disks = 4 data + 1 parity):
```
      Disk0  Disk1  Disk2  Disk3  Disk4
Stripe: 5      3      0      1      9
                                 (parity)
```

**복구 예시:**
```
5  X  0  1  9   →  X = 9-(5+0+1) = 3
2  1  1  X  5   →  X = 5-(2+1+1) = 1
3  0  1  2  X   →  X = 3+0+1+2   = 6
```

### 6.2 실제 parity 함수는 덧셈이 아니라 XOR ★

위 예시는 이해를 위한 덧셈 예제고, 실제로는 **비트 단위 XOR(⊕)** 를 쓴다.

**XOR 진리표 — 둘 중 하나만 1일 때만 1**

| A | B | A⊕B |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

XOR을 쓰는 이유:
- **자기 역원 성질**: `A ⊕ A = 0`, `A ⊕ 0 = A` → 복구 식이 계산식과 동일한 형태로 나옴
- **오버플로우 없음** (덧셈과 달리 자릿수가 늘지 않음)
- **비트 단위 연산이라 하드웨어로 극도로 빠르다** (XOR 게이트 하나)
- 교환·결합법칙 성립 → 순서 상관없이 계산 가능

```
P     = D0 ⊕ D1 ⊕ D2 ⊕ D3
D2 복구 = D0 ⊕ D1 ⊕ D3 ⊕ P      (고장난 디스크 자리만 P로 치환)
```

**비트 예시**
```
D0 = 1 0 1 1
D1 = 0 1 1 0
D2 = 1 1 0 0
D3 = 0 0 1 1
------------- XOR
P  = 0 0 1 0

D2가 죽으면: D0⊕D1⊕D3⊕P
           = 1011 ⊕ 0110 ⊕ 0011 ⊕ 0010 = 1100 = D2  ✓
```

### 6.3 RAID-4 Analysis ★

| 항목 | 값 |
|---|---|
| Capacity | **(N-1) × C** |
| Reliability | **1** |
| Latency (read) | **D** |
| Latency (write) | **2D** — parity disk를 read하고 write해야 함 |

### 6.4 RAID-4 Throughput ★

| Workload | 값 |
|---|---|
| Sequential read | **(N-1) × S** |
| Sequential write | **(N-1) × S** (full-stripe write) |
| Random read | **(N-1) × R** |
| Random write | **R / 2** ← **N에 무관! 최악의 값** |

### 6.5 Small-Write Problem — random write가 R/2인 이유 ★★

random write는 stripe 전체가 아니라 블록 하나만 갱신한다. 그때 parity를 어떻게 갱신하는가가 문제다.

**방법 1 — Additive parity**: 같은 stripe의 나머지 데이터 블록 N-2개를 전부 읽어서 새 데이터와 함께 XOR → N이 커질수록 비용 증가. 나쁨.

**방법 2 — Subtractive parity** (실제 사용):
```
P_new = P_old ⊕ D_old ⊕ D_new
```
→ 필요한 I/O는 **read D_old, read P_old, write D_new, write P_new 총 4개**. N과 무관하게 항상 4개다.

**그런데 이 4개 중 2개(read P_old, write P_new)가 항상 parity disk로 몰린다.**

- 데이터 디스크는 N-1개로 분산되지만, **parity disk는 단 1개**
- 즉 **모든 random write는 parity disk를 반드시 거친다** → parity disk가 **bottleneck**
- parity disk가 논리 write 1개당 I/O 2개(read+write)를 처리하므로, 시스템 전체 random write throughput = **R / 2**
- 디스크를 아무리 늘려도 이 값은 안 올라간다. **이것이 RAID-4를 실무에서 아무도 안 쓰는 이유다.**

---

## 7. RAID-5: Rotating Parity (p.45 ~ p.47)

### 7.1 개념

parity disk가 고정돼서 병목이 생기니, **parity를 디스크마다 돌아가며(rotate) 배치한다.**

```
Disk0  Disk1  Disk2  Disk3  Disk4
  -      -      -      -      P
  -      -      -      P      -
  -      -      P      -      -
              ...
```

→ parity 부담(workload)이 **N개 디스크 전체에 분산**된다.

### 7.2 RAID-5 Analysis ★

capacity, reliability, latency는 **RAID-4와 완전히 동일**하다.

| 항목 | 값 |
|---|---|
| Capacity | **(N-1) × C** |
| Reliability | **1** |
| Latency (read / write) | **D / 2D** |

### 7.3 RAID-5 Throughput ★★

| Workload | RAID-4 | RAID-5 | 차이 이유 |
|---|---|---|---|
| Sequential read | (N-1)×S | **(N-1)×S** | 동일 |
| Sequential write | (N-1)×S | **(N-1)×S** | 동일 (full-stripe write라 parity 병목 없음) |
| Random read | (N-1)×R | **N × R** | parity 자리도 디스크마다 흩어져 있어 **N개 디스크 전부**가 read에 동원됨 |
| Random write | R/2 | **N × R / 4** | 핵심 개선 |

**random write = N × R / 4 유도 ★**
- 논리 write 1개 → 물리 I/O **4개** (read D_old, read P_old, write D_new, write P_new)
- 전체 디스크가 제공하는 random I/O 총량 = **N × R**
- 논리 write 하나당 4개를 소모 → 초당 처리 가능한 논리 write = **N × R / 4**

→ RAID-4와 달리 **N에 비례해서 증가**한다. 그래서 **RAID-5 is strictly better than RAID-4** (모든 항목에서 같거나 우월).

---

## 8. ★★ 시험 대비: RAID Level 계산 문제 ★★

> 강의자료에 **"계산 시험"** 이라고 별표로 표시된 부분. 이 표의 값을 주고 숫자를 대입해 계산시키는 유형이 실제로 출제된다.

### 8.1 최종 비교표 — 통째로 암기

**Capacity & Reliability**

| | Reliability (잃어도 되는 디스크 수) | Capacity |
|---|---|---|
| RAID-0 | 0 | C × N |
| RAID-1 | 1 | C × N / 2 |
| RAID-4 | 1 | (N-1) × C |
| RAID-5 | 1 | (N-1) × C |

**Latency**

| | Read Latency | Write Latency |
|---|---|---|
| RAID-0 | D | D |
| RAID-1 | D | D |
| RAID-4 | D | **2D** |
| RAID-5 | D | **2D** |

**Throughput ★ 가장 중요**

| | Seq Read | Seq Write | Rand Read | Rand Write |
|---|---|---|---|---|
| **RAID-0** | N × S | N × S | N × R | N × R |
| **RAID-1** | (N/2) × S | (N/2) × S | N × R | (N/2) × R |
| **RAID-4** | (N-1) × S | (N-1) × S | (N-1) × R | **R / 2** |
| **RAID-5** | (N-1) × S | (N-1) × S | N × R | **N × R / 4** |

**결론 3줄 (서술형으로도 나올 수 있음)**
1. **RAID-0은 항상 가장 빠르고 용량도 최대다. 단 reliability를 완전히 포기한 대가다.**
2. **Sequential workload에서는 RAID-5가 RAID-1보다 낫다.** ((N-1)×S > (N/2)×S, N≥3일 때)
3. **Random workload에서는 RAID-1이 RAID-5보다 낫다.** ((N/2)×R > N×R/4)

### 8.2 값을 외우는 대신 유도하는 법

표를 통째로 외우는 것보다, 아래 3개 원리로 그 자리에서 유도하는 게 안전하다.

1. **유효 데이터 디스크 수를 센다** → sequential/random read throughput의 계수
   - RAID-0: N개, RAID-1: (read는 N개 / write는 N/2쌍), RAID-4/5: N-1개 (parity 제외)
2. **논리 I/O 1개가 물리 I/O 몇 개를 만드는지 센다** → write throughput의 나누는 수
   - RAID-1 write: 2개 → ÷2
   - RAID-5 random write: 4개 → ÷4
   - RAID-4 random write: 4개지만 그중 2개가 **단일 parity disk에 집중** → 분모가 N이 아니라 1이 되어 R/2
3. **latency는 디스크 개수와 무관하다.** parity 갱신이 필요하면 read+write 왕복이 생겨 2D.

---

### 8.3 연습 문제

공통 조건: **C = 4 TB, S = 200 MB/s, R = 100 IOPS, D = 5 ms**

---

**[문제 1] N = 10, RAID-0 / RAID-1 / RAID-5 각각의 사용 가능 용량과 허용 장애 디스크 수는?**

<details>
<summary>풀이</summary>

| | Capacity | Reliability |
|---|---|---|
| RAID-0 | 10 × 4 = **40 TB** | **0개** |
| RAID-1 | (10/2) × 4 = **20 TB** | **1개 보장** (운 좋으면 최대 5개) |
| RAID-5 | (10-1) × 4 = **36 TB** | **1개** |

RAID-5는 RAID-1보다 용량을 16 TB 더 쓰면서 같은 1개의 장애를 견딘다. 이것이 parity 방식의 핵심 이점이다.
</details>

---

**[문제 2] N = 10에서 RAID-4와 RAID-5의 random write throughput을 구하고, N = 20으로 늘리면 각각 어떻게 변하는지 설명하라.**

<details>
<summary>풀이</summary>

N = 10:
- RAID-4 = R/2 = 100/2 = **50 IOPS**
- RAID-5 = N×R/4 = 10×100/4 = **250 IOPS**

N = 20:
- RAID-4 = R/2 = **50 IOPS** — **변화 없음**
- RAID-5 = 20×100/4 = **500 IOPS** — 2배

**RAID-4의 random write는 단일 parity disk가 병목이므로 N에 무관하게 R/2로 고정된다.** 디스크를 아무리 추가해도 성능이 오르지 않는다. RAID-5는 parity가 분산되어 N에 선형 비례한다.
</details>

---

**[문제 3] N = 8. random write가 지배적인 OLTP 워크로드에서 RAID-1과 RAID-5 중 무엇을 골라야 하는가? 수치로 근거를 제시하라.**

<details>
<summary>풀이</summary>

- RAID-1 random write = (N/2) × R = 4 × 100 = **400 IOPS**
- RAID-5 random write = N × R / 4 = 8 × 100 / 4 = **200 IOPS**

**RAID-1이 2배 빠르므로 RAID-1을 선택한다.**

이유: RAID-1은 논리 write 1개당 물리 I/O가 **2개**(mirror 2벌 write)인 반면, RAID-5는 **4개**(read-modify-write)다. 대신 용량은 RAID-1이 16 TB, RAID-5가 28 TB로 RAID-5가 유리하므로 **용량 대비 random write 성능의 trade-off** 문제가 된다.

> 일반화: RAID-1 vs RAID-5 random write 비는 (N/2)R : (N/4)R = **2 : 1**로, N과 무관하게 항상 RAID-1이 2배다.
</details>

---

**[문제 4] N = 8. AI 학습 데이터셋을 순차적으로 읽는 워크로드라면?**

<details>
<summary>풀이</summary>

- RAID-1 seq read = (N/2) × S = 4 × 200 = **800 MB/s**
- RAID-5 seq read = (N-1) × S = 7 × 200 = **1400 MB/s**
- RAID-0 seq read = N × S = 8 × 200 = **1600 MB/s**

**Sequential workload에서는 RAID-5가 RAID-1보다 낫다** (1400 > 800). redundancy를 포기해도 되는 재생성 가능 데이터라면 RAID-0(1600 MB/s)이 최고지만, 장애 시 전체 손실을 감수해야 한다.
</details>

---

**[문제 5] RAID-5 (N=5)에서 논리 블록 1개를 갱신할 때 발생하는 물리 I/O를 모두 나열하고, 총 latency를 구하라.**

<details>
<summary>풀이</summary>

Subtractive parity 방식:
1. `read D_old` (해당 데이터 디스크)
2. `read P_old` (parity 디스크)
3. `write D_new`
4. `write P_new`

총 **4개의 물리 I/O**. 단, 1·2는 서로 다른 디스크라 **병렬**, 3·4도 병렬이므로
**latency = D(read) + D(write) = 2D = 10 ms**

throughput 관점에서는 4개의 I/O 슬롯을 소비하므로 `N×R/4`가 된다. **latency는 2D, throughput 분모는 4** — 이 둘을 헷갈리지 말 것.
</details>

---

**[문제 6] RAID-0, chunk size = 4, N = 5. 논리 블록 A = 37은 어느 디스크의 몇 번째 위치인가?**

<details>
<summary>풀이</summary>

```
Disk   = (A / chunk) % N          = (37 / 4) % 5 = 9 % 5 = 4   → Disk4
Offset = (A / (chunk × N)) × chunk + (A % chunk)
       = (37 / 20) × 4 + (37 % 4) = 1 × 4 + 1 = 5
```
→ **Disk4의 offset 5**
</details>

---

**[문제 7] XOR parity 복구. RAID-4, 4 data + 1 parity. Disk2가 fail 했다.**
```
D0 = 1101,  D1 = 0110,  D2 = ????,  D3 = 1010,  P = 0011
```

<details>
<summary>풀이</summary>

```
D2 = D0 ⊕ D1 ⊕ D3 ⊕ P
   = 1101 ⊕ 0110 = 1011
   = 1011 ⊕ 1010 = 0001
   = 0001 ⊕ 0011 = 0010
```
→ **D2 = 0010**

검산: 1101 ⊕ 0110 ⊕ 0010 ⊕ 1010 = 0011 = P ✓
</details>

---

## 9. RAID-6: Dual Parity (p.55 ~ p.56)

### 9.1 개념

parity를 **2개(P, Q)** 두고, 둘 다 디스크마다 rotate 시킨다.

```
Disk0  Disk1  Disk2  Disk3  Disk4  Disk5
  -      -      -      -      P      P
  -      -      -      P      P      -
  -      -      P      P      -      -
```

- **Reliability = 2** (디스크 2개까지 동시 장애 허용)
- **Capacity = (N-2) × C**
- write 비용은 더 커짐 (parity 2개를 갱신해야 하므로 논리 write 1개당 물리 I/O **6개**)

### 9.2 P와 Q의 계산 방식이 다르다 ★

- **P1 (첫 번째 parity)**: **XOR 연산**으로 계산
- **P2 (두 번째 parity)**: **Reed-Solomon code** 기반으로 계산

왜 둘 다 XOR이면 안 되는가: XOR을 두 번 계산하면 **동일한 선형 방정식**이 두 개 나와서 미지수 2개를 풀 수 없다. 서로 **선형 독립인 방정식**이 필요하므로, 두 번째는 갈루아 체(Galois Field) 위의 다항식 계수를 쓰는 Reed-Solomon을 사용해 독립성을 확보한다. 이렇게 해야 **reliability가 실제로 올라간다.**

### 9.3 RAID-6 Example (p.56) — 숫자 계산 연습

- **10 Disks**
- **8 + 2 Configuration** (8: Data Disk, 2: Parity Disk)
- **Striping size (stripe unit) = 128 KiB**
- **Full stripe = 128 KiB × 8 = 1 MB**

동작: 1 MB짜리 논리 데이터(= object)가 들어오면 → **128 KiB씩 8조각으로 쪼개져 8개 디스크에 striping** → 나머지 **2개 디스크에는 parity가 저장**된다. 위쪽 object storage system이 파일을 1 MB object 단위로 striping 하는 구조와 정확히 맞물린다.

**용량 오버헤드 계산**: 2/10 = **20%** (RAID-1의 50%보다 훨씬 효율적이면서 장애는 2개까지 허용)

> **RAID-6의 trade-off 요약**: 용량 오버헤드 20% + write 비용 증가를 지불하고, 디스크 2개 동시 장애 내성을 산다. 디스크 용량이 커질수록 rebuild 시간이 길어지고 그 사이 두 번째 장애가 날 확률이 높아지기 때문에, 대용량 환경에서는 RAID-5가 아니라 **RAID-6가 사실상 표준**이다.

---

## 10. 디스크 장애 처리와 Rebuild (p.44 ~ p.51)

### 10.1 장애 처리 흐름

```
Fail 발생 → Fail Detect → Rebuild (재구성) → 정상 복귀
```

1. 디스크가 죽으면 스토리지 서버가 **fail-stop 모델**에 따라 죽었다는 것을 감지한다
2. 시스템에는 미리 준비된 **spare disk(예비 디스크)** 가 몇 개 꽂혀 있다
3. "Disk i를 replace하라" → spare로 교체
4. 남은 디스크들의 데이터와 parity로 **XOR 연산을 수행해 잃어버린 데이터를 재계산**하고 새 디스크에 채운다 = **Rebuild**

### 10.2 Self-Healing과 Priority Scheduling ★ (실무 관점)

rebuild 중에도 **서비스는 중단되면 안 된다.** 스토리지 시스템이 스스로 복구하는 것을 **self-healing**이라 한다.

여기서 발생하는 충돌:
- **Foreground I/O**: 사용자가 지금 이미지 파일을 읽으려는 요청
- **Background I/O**: rebuild를 위해 디스크 전체를 읽어대는 작업

rebuild는 디스크를 극도로 바쁘게 만들기 때문에, 그대로 두면 사용자 요청의 응답 시간이 급격히 나빠진다. 그래서:

- **Priority scheduling**을 적용해 **foreground 요청에 우선순위**를 주고, rebuild는 남는 대역폭에서 천천히 진행시킨다
- 목표는 **사용자에게 장애가 발생했다는 사실을 최대한 드러내지 않는 것**
- 반대의 trade-off도 존재한다: rebuild를 천천히 하면 **degraded 상태가 길어져** 그 기간 중 두 번째 디스크가 죽을 위험이 커진다. **복구 속도 vs 서비스 품질**의 균형 문제다

---

## 11. HDD/SSD Arrays & Parallel File System (p.57 ~ p.58)

### 11.1 HDD/SSD Array

여러 SSD를 묶어 array로 구성할 때의 이점:

- **Performance** — 다수 SSD에 대한 병렬 접근
- **Scalability** — 용량 확장이 쉬움
- **Reliability** — RAID 구성을 통한 redundancy
- **Efficiency** — IOPS와 대역폭 활용률 극대화

**Common Configurations**: RAID-0(striping, 성능만) / RAID-1(mirroring, 용량 손실) / RAID-5,6(parity 기반, 균형) / JBOD(raw capacity, RAID 없음)

**All-Flash Array 제품 예시**
| 제품 | 특징 |
|---|---|
| Pure Storage FlashArray | 엔터프라이즈급 all-flash, 높은 신뢰성 + NVMe 지원 |
| Dell EMC PowerStore | NVMe 최적화, block·file 통합 스토리지 플랫폼 |
| NetApp AFF (All Flash FAS) | 고 throughput, 데이터 dedup + 압축 내장 |

### 11.2 Parallel File System (Lustre)

Lustre 구성 요소:

- **MGT (Management Target)** / **MDT0 (Metadata Target)** — 관리·메타데이터 저장
- **DNE Metadata Targets (MDTi ~ MDTj)** — 메타데이터를 여러 서버로 분산하기 위한 확장(Distributed Namespace)
- **OST (Object Storage Targets)** — 실제 데이터 저장
- 스토리지 서버들은 **failover pair**로 묶여 한쪽이 죽으면 다른 쪽이 인수
- 클라이언트는 1 ~ 100,000+ 규모까지 확장

**핵심 문제: Metadata Server Bottleneck**
데이터는 OST 여러 대로 자유롭게 분산되지만, **파일 열기·디렉터리 조회 같은 메타데이터 연산은 MDS로 몰린다.** 작은 파일을 대량으로 다루는 AI 학습 워크로드에서 특히 치명적이며, DNE로 MDT를 늘려 완화한다. 이 문제의식이 다음 시간의 VAST/DASE 아키텍처로 이어진다.

### 11.3 NAND 기반 SSD 예고

- QLC 등 셀당 비트 수를 늘리면 **capacity는 증가하지만 read/write 속도와 수명이 나빠진다**
- 저장 시장 전체가 HDD에서 **SSD 쪽으로 이동** 중
- NAND 기반 SSD 기술은 다음 시간부터 자세히 다룰 예정

---

## 12. 📖 다음 시간 예습 (p.59 ~ p.63): VAST Data & DASE

> p.60에 "다음시간" 표시. RAID/파일시스템에서 다룬 **'누가 디스크를 소유하는가'** 문제를 NVMe-oF가 무의미하게 만든 사례로 이어진다.

### 12.1 VAST Data — All-Flash Storage at HDD Economics

- **VAST Data** (2016, 뉴욕) — HDD와 **스토리지 티어링을 없애는 것**을 목표로 한 all-flash 데이터 플랫폼
  - 2019년 DASE 아키텍처 기반 Universal Storage 출시
  - 2026년 4월 시리즈 F $1B, 기업가치 $30B (NVIDIA 투자)
- **핵심 아이디어**: 값싼 **QLC 플래시 + 소량의 SCM**을 하나의 공유 풀로 묶고, **상태 없는(stateless) 서버가 NVMe-oF로 직접 접근**
  - 티어 없음, 캐시 미스 없음 — 모든 데이터가 플래시에
  - **용량(DBox)과 성능(CNode)을 서로 독립적으로 확장**
- 숫자 3개: **1** 개의 글로벌 네임스페이스 / **10년** QLC 수명 보장 / **~3%** erasure coding 오버헤드(150+4 스트라이프, 4-drive 장애 허용)
- 주 워크로드: AI 학습 데이터 파이프라인, HPC, 자율주행 센서 로그, 대규모 분석

### 12.2 DASE (Disaggregated Shared-Everything Architecture)

- **CNode (Compute)**: x86/ARM 서버. **상태를 갖지 않아** 어느 노드로 요청이 와도 동일 처리, 장애 시 그냥 교체
- **DBox (Data)**: NVMe SSD를 담은 JBOF. 데이터·메타데이터·트랜잭션 상태 전부 여기에
- **공유 모델**: 모든 CNode가 같은 SSD와 같은 메타데이터를 봄 → **캐시 일관성 프로토콜·락 조정이 불필요**
  - Shared-nothing 스케일아웃(Ceph, Lustre)의 노드 간 리밸런싱·조정 오버헤드 제거
- **독립 확장**: 성능 부족 → CNode 추가, 용량 부족 → DBox 추가. 세대가 다른 하드웨어 혼용 가능
- 변형: **ENode**(CNode+DBox 통합, OEM), **DPU 배치**(CNode를 NVIDIA BlueField-3 위에)

### 12.3 Write Path — SCM Landing + Full-Stripe Writes to QLC

```
① 쓰기 도착 (클라이언트 랜덤 쓰기, 4KB~수MB)
   → ② SCM 착지 & ACK (SCM 쓰기 버퍼 기록 + 미러링 후 즉시 응답)
   → ③ 버퍼 정리·축소 (유사도 기반 dedup, 압축, 메타데이터 갱신)
   → ④ 풀 스트라이프 반영 (QLC erase block에 맞춘 대용량 순차 쓰기 + EC)
```

> **랜덤 쓰기는 QLC에 도달하지 않는다 — QLC는 항상 크고 순차적인 쓰기만 받는다.**

- **QLC의 문제**: 저렴하지만 P/E 사이클이 적고(수백~1천) 랜덤 쓰기·write amplification에 취약
- **해결 1 — SCM 버퍼**: 쓰기를 SCM에 모아 두었다가 erase block 단위로 내려 씀 → SSD 내부 GC를 거의 유발하지 않음
- **해결 2 — 클러스터 단위 FTL**: 개별 SSD 대신 클러스터가 하나의 하이퍼스케일 컨트롤러처럼 배치를 결정 → 플래시 10년 수명 보장, TCO 개선
- **넓은 Erasure Coding**: 큰 SCM 버퍼 덕에 150+4 같은 넓은 스트라이프 가능. 오버헤드 ~3%, 동시 4 드라이브 장애 허용. locally decodable code로 재구성 시 일부 드라이브만 읽음
- **읽기**: CNode가 NVMe-oF로 QLC에서 직접 읽음. 별도 캐시 계층 없음

> RAID 관점에서 보면: **SCM 버퍼가 RAID-5/6의 small-write problem을 구조적으로 제거한 것.** 랜덤 쓰기를 모아 full-stripe write로 바꾸면 read-modify-write 4~6 I/O가 사라진다.

### 12.4 Shared-Nothing vs DASE 비교

| 항목 | Shared-Nothing (Ceph, Lustre, GPFS) | DASE (VAST) |
|---|---|---|
| 데이터/메타데이터 위치 | 각 노드가 자기 디스크의 일부를 소유 | 모든 SSD를 모든 CNode가 공유 (JBOF) |
| 노드 간 통신 | east-west 조정 필수 (락, 일관성, 리밸런싱) | 없음 — CNode는 서로를 모름 |
| 확장 단위 | 노드 = 컴퓨트 + 디스크 동시 추가 | CNode(성능)와 DBox(용량) 독립 추가 |
| 노드 장애 시 | 해당 노드 데이터 재구성/재분배 | CNode 교체만; 데이터는 DBox에 그대로 |
| 미디어 | HDD/SSD 티어링, 캐시 계층 | QLC + SCM 단일 계층, all-flash |
| 보호 방식 | 복제 또는 노드 단위 EC (오버헤드 33~200%) | 드라이브 단위 wide-stripe EC (~3%) |
| 프로토콜 | 파일시스템별 클라이언트/게이트웨이 | NFS·SMB·S3·블록·테이블을 같은 데이터 위에 |

### 12.5 VAST AI OS & 자율주행 데이터 파이프라인

계층 구조 (아래 → 위):
```
DASE — CNode + NVMe-oF + DBox (QLC + SCM)
DataStore    : 파일·오브젝트·블록 (NFS/SMB/S3/CSI)
DataBase / DataSpace : 테이블·벡터·스트림·카탈로그, 글로벌 네임스페이스
DataEngine / SyncEngine : 이벤트 기반 함수 실행, 사이트 간 동기화
AgentEngine / InsightEngine : 임베딩·분류·에이전트 파이프라인을 데이터 옆에서 실행
```
→ 스토리지 위에 DB·벡터 검색·이벤트 처리까지 한 플랫폼으로. 별도 벡터 DB·파이프라인 계층 제거.

**자율주행 데이터 흐름 (42dot / 현대차그룹 SDV 사례)**
```
수집(차량 로그·센서) → 정제·라벨링(프레임 추출·자동 라벨) → 학습(GPU 클러스터 대용량 순차 읽기) → 시뮬레이션·평가(재현 실행·리그레션)
                        ↑ 하나의 VAST 네임스페이스 — 단계 간 데이터 복사 없음
```
- PB급 센서 로그를 HDD 가격대의 플래시에 그대로 보관 → 콜드 데이터 티어 이동 불필요
- 학습 단계의 대용량 병렬 읽기가 CNode 수에 비례해 확장
- S3로 수집하고 NFS로 학습하는 멀티프로토콜 접근이 같은 데이터 위에서 가능

---

## 부록 A. 용어 정리 (English / 한글)

| 용어 | 의미 |
|---|---|
| **JBOD** | Just a Bunch Of Disks — RAID 없이 디스크를 나열만 한 구성 |
| **Striping** | 논리 블록을 여러 디스크에 분산 저장 |
| **Stripe** | 여러 디스크를 가로지르는 블록들의 한 줄 |
| **Chunk size** | 한 디스크에 연속으로 배치되는 블록 수 (stripe unit) |
| **Mirroring** | 동일 데이터를 2벌 이상 복제 저장 |
| **Parity** | 데이터 블록들의 XOR 결과. 1개 손실 시 복구용 |
| **Fail-stop** | 디스크는 동작하거나 완전 정지하며, 시스템이 그 사실을 안다는 고장 모델 |
| **Latent sector error** | 특정 섹터만 조용히 손상, 읽을 때 발견 |
| **Silent data corruption** | 데이터 손상을 디스크가 보고조차 하지 않는 상태 |
| **Consistent-Update Problem** | 다중 디스크 write 도중 crash로 사본 간 불일치가 생기는 문제 |
| **NVRAM** | 비휘발성 RAM. H/W RAID 컨트롤러가 crash consistency 확보에 사용 |
| **Small-write problem** | 블록 1개 갱신 시 read-modify-write로 물리 I/O 4개가 발생하는 문제 |
| **Subtractive parity** | P_new = P_old ⊕ D_old ⊕ D_new. N과 무관하게 4 I/O |
| **Rebuild** | 고장난 디스크 데이터를 parity로 재계산해 spare에 채우는 과정 |
| **Self-healing** | 서비스 중단 없이 시스템이 스스로 복구하는 성질 |
| **Deduplication** | fingerprint(해시) 비교로 동일 내용 블록을 한 벌만 저장 |
| **Reed-Solomon code** | RAID-6의 두 번째 parity 생성에 쓰는 오류 정정 부호 |
| **Erasure Coding (EC)** | 데이터를 k개 조각 + m개 패리티로 부호화. RAID parity의 일반화 |
| **SCM** | Storage Class Memory. DRAM과 NAND 사이 계층, 쓰기 버퍼로 활용 |
| **NVMe-oF** | NVMe over Fabrics. 네트워크 너머 SSD를 로컬처럼 접근 |
| **JBOF** | Just a Bunch Of Flash — SSD 버전 JBOD |

---

## 부록 B. 복습 체크리스트

- [ ] RAID가 제공하는 두 성질(transparent, deployable)과 두 전략(mapping, redundancy)을 설명할 수 있다
- [ ] Dynamic mapping과 Static mapping의 차이, RAID가 static을 쓰는 이유를 말할 수 있다
- [ ] N, C, S, R, D 다섯 기호의 정의를 외웠다
- [ ] fail-stop 모델과, 이 모델로 못 잡는 두 가지 에러를 설명할 수 있다
- [ ] `Disk = A % N`, `Offset = A / N` 매핑을 chunk size 포함해서 계산할 수 있다
- [ ] **★ RAID-0/1/4/5의 capacity, reliability, latency, 4분면 throughput을 전부 유도할 수 있다**
- [ ] **★ RAID-4 random write가 R/2이고 N에 무관한 이유를 설명할 수 있다**
- [ ] **★ RAID-5 random write가 N×R/4인 이유(물리 I/O 4개)를 유도할 수 있다**
- [ ] "RAID-5는 sequential에 유리, RAID-1은 random에 유리"를 수식으로 증명할 수 있다
- [ ] XOR parity로 손실 블록을 복구하는 계산을 할 수 있다
- [ ] Consistent-Update Problem과 NVRAM 해법, S/W RAID의 한계를 설명할 수 있다
- [ ] RAID-6에서 P는 XOR, Q는 Reed-Solomon을 쓰는 이유(선형 독립성)를 말할 수 있다
- [ ] RAID-6 8+2 구성에서 full stripe 크기와 용량 오버헤드를 계산할 수 있다
- [ ] Lustre의 Metadata Server Bottleneck이 무엇인지 설명할 수 있다
- [ ] (예습) DASE가 shared-nothing과 무엇이 다른지 한 문장으로 말할 수 있다