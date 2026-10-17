# AI 데이터 시스템 및 인프라 중간고사 — 기본 학습 가이드

> **범위**: 1~6주차 실제 강의 내용 (AI 스토리지 개요 → HDD → RAID → NAND/SSD 하드웨어 → SSD 내부 구조 → FTL)
> **분량**: 블록 0~7 = **약 3시간 40분**
> **문제가 영어로 나오는 것 대비**: 블록마다 **영어 핵심 용어표** + **영어 연습 문제 (한국어 해석 + 짧은 영어 모범 답안)** 를 넣었습니다.
> **예상 문제**: 교수님이 시험 1~2일 전에 유형 힌트를 주신다고 했으므로, 이 파일은 **기본기**용입니다. 힌트를 받으면 해당 블록만 다시 보면 됩니다.
>
> 💡 VSCode에서 `Cmd+Shift+V`(미리보기)로 보세요. 모범 답안은 `▶`로 접혀 있습니다. **먼저 직접 써 보고** 펼치세요.

<br/>

## 시간표

| 블록 | 주제 | 주차 | 시간 | 누적 |
|---|---|---|---|---|
| 0 | 영어 시험 생존법 — 질문 동사 · 답안 문장 틀 | — | 15분 | 0:15 |
| 1 | AI 스토리지 개요 (KV Cache · 메모리 계층) | 1주 | 10분 | 0:25 |
| 2 | HDD — 구조 · I/O 시간 계산 · 스케줄링 | 1~2주 | 40분 | 1:05 |
| 3 | RAID — 매핑 · 성능표 · XOR · Small-write | 3주 | 60분 | 2:05 |
| 4 | SSD 하드웨어 — 인터페이스 · NAND cell · Page/Block · Channel/Way | 4~5주 | 35분 | 2:40 |
| 5 | FTL — RMW · WAF · COW · GC · Wear Leveling | 6주 | 45분 | 3:25 |
| 6 | 최종 점검 — 영어 백지 테스트 | — | 15분 | **3:40** |

**우선순위** (시간이 부족하면 이 순서로): **블록 3 (RAID 계산) > 블록 5 (FTL) > 블록 2 (HDD 계산) > 블록 4 > 블록 1**
- 3주차 강의자료에 RAID 성능표 부분이 **"계산 시험"** 이라고 별표 표시돼 있었습니다 → 최우선.

<br/>

---

## 블록 0. 영어 시험 생존법 (15분)

### 0.1 질문 동사 — 이것만 알면 "뭘 하라는지"는 안다

| 영어 | 뜻 | 답안 형태 |
|---|---|---|
| **Explain** / **Describe** | 설명하라 | 2~4문장 |
| **Why** ~? / **Explain why** | 이유를 말하라 | "because ..." 로 시작 |
| **Compare** A and B / **Contrast** | 비교하라 | 표 또는 "A ..., while B ..." |
| **Calculate** / **Compute** / **What is** | 계산하라 | 식 + 단위 있는 숫자 |
| **Derive** | 유도하라 | 단계별 식 |
| **List** / **Name** | 나열하라 | 단어만 나열해도 OK |
| **Define** | 정의하라 | "X is ..." 한 문장 |
| **Draw** / **Illustrate** | 그려라 | 그림 + 짧은 라벨 |
| **Show the steps** | 과정을 보여라 | 1. 2. 3. 번호 매기기 |
| **Which** ~ is better? **Justify** your answer | 고르고 근거를 대라 | 선택 + 숫자 근거 |
| **Assume** ~ | ~라고 가정하라 | 주어진 조건 (문제 조건임) |
| **Given** ~ | ~가 주어졌을 때 | 주어진 값 |

### 0.2 자주 나올 표현

| 영어 | 뜻 |
|---|---|
| throughput / bandwidth | 처리량 (MB/s, IOPS) |
| latency | 지연 시간 (요청 1개가 끝나는 데 걸리는 시간) |
| sequential / random workload | 순차 / 임의 접근 |
| tolerate N disk failures | 디스크 N개 고장을 견딤 |
| overhead | 부가 비용 |
| bottleneck | 병목 |
| trade-off | 얻는 것과 잃는 것 |
| in-place / out-of-place | 제자리 덮어쓰기 / 다른 곳에 새로 쓰기 |
| amplification | 증폭 |
| lifetime / endurance / wear out | 수명 / 내구성 / 닳다 |
| reclaim | (빈 공간을) 회수하다 |
| redundancy | 중복성 (복사본·parity) |
| at least / at most | 최소 / 최대 |
| respectively | 각각 |
| regardless of N | N과 상관없이 |
| proportional to N | N에 비례 |

### 0.3 답안 문장 틀 — 영어 못 써도 이 틀에 단어만 끼우기

> 영어로 답하라는 말이 없으면 **한국어 + 영어 용어**로 써도 되는지 시험 전에 꼭 확인하세요. 아래 틀은 영어로 써야 할 때를 위한 것입니다.

```
[정의]   X is a technique that ~.           X는 ~하는 기법이다.
[이유]   This is because ~.                   왜냐하면 ~이기 때문이다.
[원인]   X causes Y.  /  Y happens due to X.  X가 Y를 일으킨다.
[해결]   To solve this, we use X.             이를 해결하기 위해 X를 쓴다.
[비교]   A is faster than B, but B is cheaper. A가 B보다 빠르지만 B가 더 싸다.
[대조]   A ~, while B ~.                       A는 ~인 반면 B는 ~이다.
[장단점] The advantage is ~. The disadvantage is ~.
[결과]   As a result, ~.  /  Therefore, ~.     그 결과 / 따라서
[계산]   X = (formula) = (number) (unit).
```

**팁**: 문장이 길어지면 틀립니다. **짧은 문장 3개 + 핵심 영어 용어** 가 긴 문장 1개보다 점수 받기 쉽습니다. 화살표(→)와 표도 적극 쓰세요.

<br/>

---

## 블록 1. AI 스토리지 개요 (10분) — 1주차

### 1.1 핵심 3줄

1. LLM은 **auto-regressive**(앞 토큰을 전부 알아야 다음 토큰 생성) → 이전 토큰의 Key/Value를 저장해 두는 **KV Cache**가 필요하다.
2. KV Cache는 문맥 길이(seq_len)에 비례해 커진다 → GPU **HBM** 용량을 넘침 → DRAM / SSD / 네트워크 스토리지로 **offload**.
3. 그래서 메모리·스토리지 계층이 GPU만큼 중요해졌다. (NVIDIA CMX = **G3.5** 계층: pod 단위 이더넷 플래시, 노드 간 KV 공유)

### 1.2 메모리 계층

| 계층 | 속도 | 용량/비용 | 용도 |
|---|---|---|---|
| **SRAM** | 가장 빠름 | 비쌈, 밀도 낮음 | CPU/GPU 캐시 |
| **DRAM** | 중간 | 싸고 밀도 높음 | 메인 메모리 |
| **HBM** | DRAM die를 **3D 적층**(TSV) → 대역폭↑ | 비쌈 | GPU 옆 메모리 |

**G1~G4**: G1 GPU HBM (ns) → G2 CPU DRAM → G3 로컬 NVMe SSD (µs) → **G3.5 CMX** (공유 플래시) → G4 외부 스토리지 (ms)

### 1.3 영어 용어

| 영어 | 뜻 |
|---|---|
| auto-regressive | 자기회귀 (이전 출력을 입력으로 다음 출력 생성) |
| KV Cache | Attention의 Key/Value를 저장해 둔 캐시 |
| offload | 하위 계층으로 내려 보냄 |
| memory wall | 연산은 빠른데 메모리 대역폭이 못 따라가는 문제 |
| recompute vs reload | 다시 계산 vs 저장된 걸 읽어오기 |

### 1.4 영어 연습 문제

**Q1.** Why does KV Cache become a storage problem in LLM inference?
*(왜 KV Cache가 LLM 추론에서 스토리지 문제가 되는가?)*

<details>
<summary>▶ 모범 답안</summary>

LLMs are auto-regressive, so they must keep the Key/Value of all previous tokens. The KV Cache grows with the context length (seq_len). It exceeds GPU HBM capacity, so it must be offloaded to DRAM, SSD, or network storage.

*(LLM은 자기회귀라서 이전 토큰의 K/V를 다 들고 있어야 한다. KV Cache는 문맥 길이에 비례해 커지고 HBM 용량을 넘기 때문에 DRAM·SSD·네트워크 스토리지로 내려야 한다.)*
</details>

**Q2.** Why does HBM stack DRAM dies in 3D?

<details>
<summary>▶ 모범 답안</summary>

To get higher bandwidth. GPU cores wait for data because DRAM bandwidth is the bottleneck (memory wall). Stacking dies lets the GPU read from many layers at the same time.
</details>

<br/>

---

## 블록 2. HDD (40분) — 1~2주차

### 2.1 구조 (그림으로 나올 수 있음)

| 영어 | 뜻 |
|---|---|
| **platter** | 원판 (자성 필름 코팅) |
| **spindle** | 원판들을 돌리는 회전축 |
| **surface** | 원판의 윗면/아랫면 |
| **track** | 동심원 링 |
| **cylinder** | 여러 원판에서 **같은 반지름의 track 묶음** |
| **sector** | track을 나눈 최소 단위 (**512B** 또는 **4KB**) |
| **head / arm** | 읽기 헤드 / 헤드를 옮기는 팔 (모든 head가 함께 움직임) |
| **servo burst** | 3~5 sector마다 기록된 위치 정보 → 헤드가 자기 위치를 앎 |
| **runout** | track이 완벽한 원이 아니라 흔들리는 현상 |

- 디스크 인터페이스: **sector 배열**, 연산은 **read / write 두 개뿐** (delete 없음)

### 2.2 I/O 시간 = Seek + Rotation + Transfer ★★

```
T_io = T_seek + T_rotation + T_transfer
```

| 요소 | 의미 | 크기 | 공식/특징 |
|---|---|---|---|
| **Seek** | arm을 목표 track으로 이동 | 4~10 ms | 4단계: **accelerate → coast → decelerate → settle** (settle만 0.5~2ms). 평균 seek 거리 ≈ 최대의 **1/3** |
| **Rotation** | 목표 sector가 헤드 밑으로 올 때까지 대기 | 2~4 ms | **평균 = ½ × (60,000 ms / RPM)** |
| **Transfer** | 실제 데이터 전송 | µs | **크기 / 전송률** |

**외울 숫자**: 7,200 RPM → 1회전 8.3ms → 평균 **4.2ms** / 15,000 RPM → 1회전 4ms → 평균 **2ms**

- long seek에는 coast(등속) 구간이 있고, short seek(옆 track)에는 coast가 없다.

**대표 계산 (Cheetah, 16KB random read)**

```
Seek       = 4 ms
Rotation   = ½ × 60,000/15,000 = 2 ms
Transfer   = 16 KB / 125 MB/s ≈ 0.125 ms
Total      ≈ 6.1 ms
Throughput = 16 KB / 6.1 ms ≈ 2.5 MB/s       (sequential은 125 MB/s → 약 50배 차이)
IOPS       ≈ 1000 / 6.1 ≈ 164
```

| | Cheetah (15K RPM, seek 4ms, 125MB/s) | Barracuda (7.2K RPM, seek 9ms, 105MB/s) |
|---|---|---|
| Sequential | 125 MB/s | 105 MB/s |
| Random 16KB | **2.5 MB/s** (6.1 ms) | **1.2 MB/s** (13.2 ms) |

**결론**: random은 seek + rotation이 지배 → sequential보다 **50~90배 느림**. 그래서 FS·DB가 순차 쓰기를 좋아한다.

### 2.3 HDD 성능 개선 3종

| 기법 | 해결하는 문제 | 방법 |
|---|---|---|
| **Track skew** | 15번(안쪽 track 끝) → 16번(바깥 track 시작) 순차 읽기 때, settle 중에 16번이 지나가 버려 한 바퀴 더 기다림 | 인접 track의 sector 시작 위치를 **어긋나게** 배치 |
| **Zones (ZBR)** | 바깥 track이 더 긴데 sector 수가 같으면 공간 낭비 | **바깥 track에 sector를 더 많이** → 바깥 zone의 순차 전송률이 더 빠름 |
| **Drive cache** | — | ① **Read-ahead (track buffer)**: 회전 대기 중 track 전체를 미리 읽음 ② **Write caching (immediate reporting)**: 디스크 DRAM에만 넣고 "다 썼다"고 ACK → 빠르지만 **정전 시 데이터 손실, consistency 깨짐** ③ **TCQ/NCQ**: 여러 요청을 받아 디스크가 순서 재배치 |

- **Jitter**: striping된 요청은 **가장 느린 디스크**를 기다려야 끝남 → 응답 시간 편차 = tail latency 증가

### 2.4 I/O 스케줄링 ★

- CPU 스케줄링과 다른 점: job 길이가 아니라 **head 위치와 요청 위치의 거리**가 중요
- FCFS 예: `300001, 700001, 300002, 700002, 300003, 700003` → 60ms / 정렬하면 → 20ms (3배)

| 알고리즘 | 기준 | 구현 위치 | Starvation |
|---|---|---|---|
| **FCFS** | 도착 순서 | 어디든 | 없음 (비효율) |
| **SSTF** | seek 거리 최소 | **OS** | **있음** |
| **SPTF** | seek + rotation 최소 (greedy) | **Disk** | **있음** |
| **SCAN** (elevator) | 끝에서 끝까지 왕복 | OS | 없음, 단 **가운데 cylinder가 유리** |
| **C-SCAN** | 한 방향으로만 쓸고 처음으로 복귀 | OS | 없음, 더 **공정(fair)** |

**단골 질문: 왜 OS는 SPTF를 못 하나?** → OS는 **논리 주소(LBA)** 만 알고 헤드의 **회전 위치(rotational position)** 를 모른다. 그건 디스크만 안다. 그래서 OS는 SSTF로 근사한다.

### 2.5 HDD 최신 동향

- **HDD는 죽지 않았다**: GB당 가격이 싸서 데이터센터의 PB~EB급 저장에 여전히 사용 (CERN EOS, ORNL Frontier)
- **Helium drive**: 마찰↓ → 얇은 platter, 진동↓ → 고장↓, 더 많이 적층 → 용량↑
- 자성 입자를 줄이면 **열적 불안정성** 때문에 한계 → 아래 기술로 우회

| 기술 | 원리 | 장점 | 단점 |
|---|---|---|---|
| **HAMR** (Seagate) | **레이저로 가열**해서 기록 | 가장 높은 밀도 | 제조 난도·발열·비용 |
| **MAMR** (WD) | **마이크로파**(STO)로 자화 반전 보조 | 레이저 불필요, 기존 공정 호환 | 최대 밀도는 HAMR보다 낮음 |
| **SMR** | track을 **기와처럼 겹침** | 싸고 대용량 | zone 안에서 **순차 쓰기만** 가능 → random write 느림 → 백업·아카이브(WORM)용 |

### 2.6 영어 연습 문제

**Q1. (계산)** A disk spins at 10,000 RPM. The average seek time is 5 ms and the maximum transfer rate is 100 MB/s. Calculate the time for one random 4 KB read and the random read throughput.
*(10,000 RPM, 평균 seek 5ms, 최대 전송률 100MB/s. 4KB 랜덤 읽기 1회 시간과 랜덤 읽기 처리량을 구하라.)*

<details>
<summary>▶ 모범 답안</summary>

```
Seek       = 5 ms
Rotation   = ½ × (60,000 ms / 10,000) = ½ × 6 = 3 ms
Transfer   = 4 KB / 100 MB/s ≈ 0.04 ms (40 µs)
Total      ≈ 8.04 ms
Throughput = 4 KB / 8.04 ms ≈ 0.5 MB/s   (IOPS ≈ 1000 / 8.04 ≈ 124)
```
Seek and rotation dominate; transfer is negligible.
</details>

**Q2.** Why is random I/O much slower than sequential I/O on an HDD?

<details>
<summary>▶ 모범 답안</summary>

Random I/O needs a seek and a rotational delay for every request, which take milliseconds. Sequential I/O reads neighboring sectors, so it is dominated by transfer time, which takes only microseconds. As a result, random throughput can be 50~90 times lower.
</details>

**Q3.** Why can the OS not implement SPTF? What does it use instead?

<details>
<summary>▶ 모범 답안</summary>

SPTF needs the current rotational position of the head. The OS only sees logical block addresses (LBA) and does not know the disk geometry or rotation. Only the disk knows it. So the OS uses SSTF, which only considers seek distance.
</details>

**Q4.** What is the problem of write caching with immediate reporting?

<details>
<summary>▶ 모범 답안</summary>

The disk reports "write done" when the data is only in its volatile DRAM, not on the platter. If power fails, the data is lost even though the host was told it was saved. This breaks the consistency of the file system or database.
</details>

**Q5.** Compare SCAN and C-SCAN.

<details>
<summary>▶ 모범 답안</summary>

SCAN sweeps back and forth across the disk, so middle cylinders are served more often than edge cylinders. C-SCAN sweeps in only one direction and then returns to the start, so it is fairer. Both avoid starvation.
</details>

**Q6.** What is track skew and why is it needed?

<details>
<summary>▶ 모범 답안</summary>

Track skew shifts the starting sector of neighboring tracks. When the head moves to the next track, it needs time to settle. Without skew, the next sector passes during settling and the disk must wait almost a full rotation.
</details>

<br/>

---

## 블록 3. RAID (60분) — 3주차 ★★★ 최우선

### 3.1 개념

- **RAID** = 여러 개의 싼 디스크를 묶어서 위(FS)에 **하나의 큰 논리 디스크(fake logical disk)** 로 보여줌
  - **Transparent**: 위쪽은 RAID가 있는지 모름 / **Deployable**: 기존 시스템에 그대로 사용
- 도구는 두 개: **Mapping(striping)** → 용량·성능 / **Redundancy(mirror·parity)** → 신뢰성
- **JBOD**: 디스크마다 FS를 따로 올리고 앱이 알아서 관리. 단순하지만 redundancy 없음
- RAID는 **static mapping**(수식 계산) — 하드웨어로 빠르게 구현 가능. 반대로 SSD의 FTL은 **dynamic mapping**(테이블).
- **Fail-stop 모델**: 디스크는 정상이거나 완전히 죽거나 둘 중 하나, 그리고 시스템이 **어떤 디스크가 죽었는지 안다**. (못 잡는 에러: latent sector error, silent data corruption → checksum, scrubbing으로 잡음)

### 3.2 기호 (반드시 암기)

| 기호 | 의미 |
|---|---|
| **N** | 디스크 수 |
| **C** | 디스크 1개 용량 |
| **S** | 디스크 1개 **sequential** throughput |
| **R** | 디스크 1개 **random** throughput |
| **D** | I/O 1개의 latency |

### 3.3 RAID-0 주소 매핑 ★

```
chunk = 1:   Disk = A % N            Offset = A / N   (정수 나눗셈)
chunk = k:   Disk = (A / k) % N      Offset = (A / (k×N)) × k + (A % k)
```

- chunk가 작으면 → 병렬성↑ / 크면 → 디스크당 연속 접근 효율↑

### 3.4 최종 비교표 ★★★ (통째로 외우기)

| | Capacity | Reliability | Read lat. | Write lat. | Seq Read | Seq Write | Rand Read | Rand Write |
|---|---|---|---|---|---|---|---|---|
| **RAID-0** | N·C | **0** | D | D | N·S | N·S | N·R | N·R |
| **RAID-1** | (N/2)·C | **1** (운 좋으면 N/2) | D | D | (N/2)·S | (N/2)·S | **N·R** | (N/2)·R |
| **RAID-4** | (N−1)·C | 1 | D | **2D** | (N−1)·S | (N−1)·S | (N−1)·R | **R/2** |
| **RAID-5** | (N−1)·C | 1 | D | **2D** | (N−1)·S | (N−1)·S | **N·R** | **N·R/4** |
| **RAID-6** | (N−2)·C | **2** | — | — | — | — | — | — |

### 3.5 표를 외우지 말고 유도하는 3가지 원리

1. **유효 디스크 수를 센다** → read 계수. RAID-0: N, RAID-1 read: N (복사본 아무 쪽이나 읽음), RAID-4: N−1 (parity 디스크 제외), RAID-5: N (parity가 흩어져 있어 모든 디스크가 일함)
2. **논리 write 1개 = 물리 I/O 몇 개?** → write 분모. RAID-1: 2개 → ÷2, RAID-5 random write: **4개** → ÷4
3. **Latency는 N과 무관.** parity 갱신 시 read → write 왕복 → **2D**

**핵심 문장 (영어로 그대로 나올 수 있음)**: *"Buying more disks improves throughput, but not latency."* — 디스크를 늘려도 요청 하나의 시간은 여전히 D.

**RAID-1 sequential read가 N·S가 아니라 (N/2)·S인 이유**: 한 디스크가 0, 2, 4, 6을 읽으면 1, 3, 5, 7 자리를 **건너뛰며 회전**해야 하므로 실제 대역폭이 S/2.

### 3.6 Parity = XOR ★

| A | B | A⊕B |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

```
P = D0 ⊕ D1 ⊕ D2 ⊕ D3
잃어버린 블록 = 나머지 전부 XOR (P 포함)
```

- XOR을 쓰는 이유: A⊕A = 0 이라 복구 식 = 계산 식, 자릿수가 안 늘어남, 하드웨어로 매우 빠름

### 3.7 Small-write problem ★★ (RAID-4가 R/2인 이유)

블록 1개만 갱신할 때 parity 갱신 방법:

```
Subtractive parity:   P_new = P_old ⊕ D_old ⊕ D_new
물리 I/O 4개:  read D_old, read P_old, write D_new, write P_new
```

- **RAID-4**: 4개 중 2개(read P, write P)가 항상 **하나뿐인 parity 디스크**로 몰림 → parity 디스크가 **bottleneck** → 전체 random write = **R/2**, **N을 늘려도 그대로**
- **RAID-5**: parity를 디스크마다 **돌아가며(rotate)** 배치 → 부하가 N개에 분산 → **N·R/4** (N에 비례)
- 그래서 **RAID-5는 RAID-4보다 모든 면에서 같거나 낫다** → RAID-4는 실무에서 안 씀
- Latency: read 2개 병렬 (D) + write 2개 병렬 (D) = **2D** / Throughput 분모: **4** ← 헷갈리지 말 것

### 3.8 결론 3줄 (서술형 단골)

1. RAID-0이 가장 빠르고 용량 최대. 단 **reliability 0**.
2. **Sequential**에서는 RAID-5 > RAID-1 ((N−1)·S > (N/2)·S)
3. **Random write**에서는 RAID-1 > RAID-5 ((N/2)·R vs N·R/4 → 항상 **2배**)

### 3.9 RAID-6, Rebuild, Crash

- **RAID-6**: parity 2개 (**P = XOR**, **Q = Reed-Solomon**). 둘 다 XOR이면 **같은 방정식**이 두 개라 미지수 2개를 못 푼다 → **선형 독립**인 식이 필요. 디스크 2개 동시 고장 허용, 용량 (N−2)·C, write 시 물리 I/O 6개.
  - 예: 10 disks, **8+2**, stripe unit 128 KiB → full stripe = 128 KiB × 8 = **1 MB**, 용량 오버헤드 2/10 = **20%**
  - 디스크가 커질수록 rebuild가 길어져 그 사이 두 번째 고장 위험↑ → 대용량에선 RAID-6가 표준
- **Rebuild**: 고장 감지 → spare disk로 교체 → 남은 데이터 + parity를 XOR해서 복구. 서비스 중단 없이 = **self-healing**. 사용자 요청(foreground)에 우선순위를 주고 rebuild(background)는 천천히 → 대신 degraded 기간이 길어짐 (trade-off)
- **Consistent-update problem** (RAID-1): 두 디스크에 쓰다가 하나만 쓰고 crash → 어느 쪽이 맞는지 모름. 해결: H/W RAID 컨트롤러의 **NVRAM**에 진행 중 write를 기록해 두고 재부팅 후 replay. S/W RAID는 NVRAM이 없어 bitmap·journaling으로 우회.
- **Lustre** (parallel FS): 데이터는 여러 OST에 분산되지만 메타데이터는 MDS로 몰림 → **metadata server bottleneck** (작은 파일이 많은 AI 학습에 치명적)

### 3.10 영어 용어

| 영어 | 뜻 |
|---|---|
| striping / stripe / chunk size | 분산 저장 / 디스크를 가로지르는 한 줄 / 한 디스크에 연속으로 놓이는 블록 수 |
| mirroring | 복제 저장 |
| parity | XOR 결과 블록 |
| fail-stop | 동작 or 완전 정지, 시스템이 고장을 앎 |
| small-write problem | 블록 1개 갱신에 물리 I/O 4개 |
| read-modify-write | 읽고 → 수정하고 → 다시 쓰기 |
| rebuild / spare disk / degraded mode | 재구성 / 예비 디스크 / 고장 난 채로 운영 중인 상태 |
| deduplication / fingerprint | 중복 제거 / 해시값 |

### 3.11 영어 연습 문제

공통 조건: **N = 6, C = 2 TB, S = 100 MB/s, R = 50 IOPS, D = 10 ms**

**Q1. (계산)** Calculate the usable capacity and the number of tolerable disk failures for RAID-0, RAID-1, RAID-5, and RAID-6.
*(각 RAID의 사용 가능 용량과 견딜 수 있는 디스크 고장 수)*

<details>
<summary>▶ 모범 답안</summary>

| | Capacity | Tolerable failures |
|---|---|---|
| RAID-0 | 6 × 2 = **12 TB** | **0** |
| RAID-1 | (6/2) × 2 = **6 TB** | **1** (up to 3 if lucky) |
| RAID-5 | (6−1) × 2 = **10 TB** | **1** |
| RAID-6 | (6−2) × 2 = **8 TB** | **2** |
</details>

**Q2. (계산)** Calculate the random write throughput of RAID-4 and RAID-5. What happens if N increases to 12?

<details>
<summary>▶ 모범 답안</summary>

```
N = 6:   RAID-4 = R/2 = 50/2 = 25 IOPS
         RAID-5 = N·R/4 = 6 × 50 / 4 = 75 IOPS
N = 12:  RAID-4 = 25 IOPS (no change)
         RAID-5 = 12 × 50 / 4 = 150 IOPS (doubled)
```
In RAID-4, every small write must read and write the single parity disk, so the parity disk is the bottleneck regardless of N. RAID-5 rotates parity across all disks, so it scales with N.
</details>

**Q3.** For a random-write-heavy database (OLTP), which is better: RAID-1 or RAID-5? Justify with numbers.

<details>
<summary>▶ 모범 답안</summary>

```
RAID-1 random write = (N/2)·R = 3 × 50 = 150 IOPS
RAID-5 random write = N·R/4   = 6 × 50 / 4 = 75 IOPS
```
RAID-1 is 2x faster. One logical write needs 2 physical I/Os in RAID-1, but 4 in RAID-5 (read old data, read old parity, write new data, write new parity). However, RAID-5 has more capacity (10 TB vs 6 TB). It is a trade-off.
</details>

**Q4.** For sequential reading of a large AI training dataset, which is better: RAID-1 or RAID-5?

<details>
<summary>▶ 모범 답안</summary>

```
RAID-1 seq read = (N/2)·S = 3 × 100 = 300 MB/s
RAID-5 seq read = (N−1)·S = 5 × 100 = 500 MB/s
```
RAID-5 is better for sequential workloads.
</details>

**Q5. (매핑)** RAID-0 with 4 disks and chunk size 1. Where is logical block 13? Then, with 3 disks and chunk size 2, where is logical block 11?

<details>
<summary>▶ 모범 답안</summary>

```
chunk 1, N 4, A 13:   Disk = 13 % 4 = 1,   Offset = 13 / 4 = 3     → Disk 1, offset 3
chunk 2, N 3, A 11:   Disk = (11/2) % 3 = 5 % 3 = 2
                      Offset = (11 / 6) × 2 + (11 % 2) = 1×2 + 1 = 3  → Disk 2, offset 3
```
검산 (chunk 2, N 3): `D0: 0,1 | 6,7`  `D1: 2,3 | 8,9`  `D2: 4,5 | 10,11` → 11은 D2의 4번째(offset 3) ✓
</details>

**Q6. (XOR)** RAID-4 with D0 = 1010, D1 = 0111, D2 = 1100. (a) Compute the parity P. (b) Disk 1 fails. Recover D1. (c) D1 is updated to 0011. Compute the new parity using subtractive parity.

<details>
<summary>▶ 모범 답안</summary>

```
(a) P  = 1010 ⊕ 0111 ⊕ 1100 = 1101 ⊕ 1100 = 0001
(b) D1 = D0 ⊕ D2 ⊕ P = 1010 ⊕ 1100 ⊕ 0001 = 0110 ⊕ 0001 = 0111  ✓
(c) P_new = P_old ⊕ D1_old ⊕ D1_new = 0001 ⊕ 0111 ⊕ 0011 = 0110 ⊕ 0011 = 0101
    검산: 1010 ⊕ 0011 ⊕ 1100 = 1001 ⊕ 1100 = 0101  ✓
```
</details>

**Q7.** What is the latency of one small write in RAID-5, and why is the throughput divided by 4, not 2?

<details>
<summary>▶ 모범 답안</summary>

Latency = **2D = 20 ms**. The two reads (old data, old parity) happen in parallel (D), then the two writes happen in parallel (D). But throughput counts the total number of physical I/Os: 4 per logical write. So throughput = N·R/4.
</details>

**Q8.** Why does RAID-6 use Reed-Solomon for the second parity instead of XOR?

<details>
<summary>▶ 모범 답안</summary>

To recover two failed disks, we need two independent equations. If both parities use XOR, the two equations are the same, so we cannot solve for two unknowns. Reed-Solomon gives a linearly independent second equation.
</details>

**Q9.** Explain the consistent-update problem in RAID-1 and how hardware RAID solves it.

<details>
<summary>▶ 모범 답안</summary>

If a crash happens after writing to only one of the two mirror disks, the two copies are different and we cannot know which is correct. Hardware RAID uses non-volatile RAM (NVRAM) to log the write in progress. After reboot, it replays the log to make both copies the same. Software RAID has no NVRAM.
</details>

**Q10.** Why does buying more disks not improve latency in RAID-0?

<details>
<summary>▶ 모범 답안</summary>

Each request is still served by one disk, and the physical seek and rotation time of that disk does not change. More disks only allow more requests to be served in parallel, which increases throughput.
</details>

<br/>

---

## 블록 4. SSD 하드웨어 (35분) — 4~5주차

### 4.1 HDD → SSD

| SSD 장점 | SSD 단점 |
|---|---|
| 기계 부품 없음 → seek·rotation 없음 → random I/O 압도적 (수십만 IOPS) | GB당 비쌈 |
| **내부 병렬성** (여러 NAND die를 channel/way로 동시 접근) | **P/E cycle 수명 제한** |
| 저전력, 충격·소음 없음 | **Erase-before-write** → FTL·GC 필요 |

- SSD 내부 대역폭이 SATA 한계(600MB/s)를 넘음 → **PCIe/NVMe**로 넘어감

### 4.2 Interface vs Protocol

- **Interface** = 물리·전기적 연결 (SATA, SAS, PCIe) / **Protocol** = 명령 주고받는 규약 (AHCI, SCSI, NVMe)
- SATA·SAS는 interface이자 protocol, **PCIe는 interface이고 그 위의 protocol이 NVMe**

| | SATA | SAS | NVMe (PCIe) |
|---|---|---|---|
| 대상 | Consumer | Enterprise | 둘 다 |
| Duplex | Half | Full | Full |
| Queue | **1개 × depth 32** | ~254 | **64K개 × depth 64K** |

- NVMe가 queue를 많이 둔 이유: SSD의 내부 병렬성을 다 쓰려면 동시에 많은 명령이 필요. 보통 **CPU core마다 SQ/CQ 쌍** → lock 경합 없음
- **PCH**: SATA 장치는 PCH를 거쳐 DMI 대역폭을 LAN·USB와 나눠 씀. NVMe는 **CPU PCIe lane 직결** 가능

**대역폭 계산 ★**

```
SATA 3:      6 Gbps × 8/10 (8b/10b) ÷ 8 = 600 MB/s
PCIe:        전송률(GT/s) × 128/130 × lane 수 ÷ 8
PCIe Gen4 x4: 16 × 128/130 × 4 ÷ 8 ≈ 7.88 GB/s
메모리:       channel당 대역폭 × channel 수   (예: 50 GB/s × 12 = 600 GB/s)
```

- Encoding을 하는 이유: 0/1 균형(DC balance)과 수신 측 clock 복원 → 신뢰성 있는 전송

### 4.3 eMMC vs UFS

| | eMMC | UFS |
|---|---|---|
| 신호 | **Parallel** (8-bit) | **Serial** |
| Duplex | Half | Full |
| Command queue | 없음 (5.1에서 추가) | 기본 (depth 32) |
| 속도 | ~400 MB/s | ~4.2 GB/s (4.0) |

- **Parallel인데 왜 느린가?** clock을 올리면 선마다 신호 도착이 어긋나는 **skew**, 선끼리 간섭하는 **crosstalk** 때문에 고속화가 어렵다. 그래서 SATA, PCIe, UFS 모두 serial로 갔다.

### 4.4 NAND cell과 0/1 ★

- **Floating gate**에 전자를 가둠 → 전원이 꺼져도 유지 (**non-volatile**). DRAM은 capacitor라 64ms마다 refresh 필요.

| 동작 | 방법 | 결과 | 단위 |
|---|---|---|---|
| **Program** | control gate에 고전압 → 전자가 tunnel oxide를 뚫고 들어감 (tunneling) | Vth↑ → **0** | **Page** |
| **Erase** | substrate에 고전압 → 전자를 빼냄 | Vth↓ → **1** | **Block** |
| **Read** | 기준 전압을 걸어 전류가 흐르는지 sensing | | Page |

**비대칭 ★**: **1 → 0 (program)은 page 단위로 골라서 가능**, **0 → 1 (erase)은 block 단위로 한꺼번에만 가능**

**Erase 필요 판단법**: 바뀌는 비트 중 **0 → 1이 하나라도 있으면 erase 필요**
- F(1111) → 5(0101): 1→0만 있음 → **program만으로 가능**
- 5(0101) → F(1111): 0→1 있음 → **erase 필요**

### 4.5 SLC ~ QLC

| | bit/cell | 상태 수 (2ⁿ) | P/E cycle (4주차 기준) | P/E cycle (6주차 기준) |
|---|---|---|---|---|
| SLC | 1 | 2 | ~100,000 | ~100,000 |
| MLC | 2 | 4 | ~10,000 | ~3,000 |
| TLC | 3 | 8 | ~3,000 | ~1,000 |
| QLC | 4 | 16 | ~1,000 | ~100–300 |

> ⚠️ 4주차와 6주차 슬라이드의 P/E 숫자가 다릅니다. 시험에서 숫자를 쓸 때는 **"approximately"** 를 붙이고, 핵심은 **"bit 수↑ → 수명 급감"** 입니다.

- bit 수↑ → 같은 전압 범위를 더 잘게 쪼갬 → 상태 간격(margin)이 좁아짐 → **느려짐, 에러↑, 수명↓**, 대신 **용량↑, 가격↓**
- bit는 4배(1→4)인데 상태는 8배(2→16) → 난이도가 지수적으로 증가
- **AI와 QLC**: 학습 데이터처럼 한 번 쓰고 오래 읽는 데이터는 QLC로 충분 (VAST Data: SCM 버퍼에 쓰기를 모았다가 QLC에는 큰 순차 쓰기만)
- **P/E 수명이 있는 이유**: 전자가 tunnel oxide를 통과할 때마다 산화막이 조금씩 손상 (aging)

### 4.6 Page / Block / 지연

| 단위 | 크기 (강의 예시) | 연산 |
|---|---|---|
| **Page** | 16 KB | Read / Program |
| **Block** | 256 pages = 16KB × 256 = **4 MB** | Erase |

| 연산 | 지연 | 순서 |
|---|---|---|
| Read | 수십 µs | 가장 빠름 |
| Program | 수백 µs | 중간 |
| Erase | **수 ms** (HDD 수준) | 가장 느림 |

- DRAM은 **byte-addressable**, SSD는 아님 (page 단위)
- 16KB page = HDD 512B sector **32개**

### 4.7 SSD 내부 구조 ★

```
Channel > Way > Chip > Die > Plane > Block > Page

            ┌─ CH0 ─ [Chip0] [Chip1]
Flash  ─────┼─ CH1 ─ [Chip2] [Chip3]       4 channel × 2 way
Controller  ├─ CH2 ─ [Chip4] [Chip5]
            └─ CH3 ─ [Chip6] [Chip7]
```

- **Channel**: 컨트롤러 ↔ NAND chip 사이 **독립 버스** → channel끼리 동시 전송 (channel parallelism)
- **Way**: 한 channel을 **공유**하는 chip 수 → 한 chip이 program하는 동안 다른 chip에 전송 (**interleaving**)
- **Flash controller = data mover**: NAND → SSD 내부 DRAM → (DMA) → Host 메모리
- **SSD = 하나의 컴퓨터**: CPU (ARM 코어) + DRAM (매핑 테이블·버퍼) + NAND (저장소) + **펌웨어 (FTL)**
- **GPUDirect Storage**: 예전엔 SSD → CPU 메모리 → GPU 메모리. 지금은 **SSD → GPU 메모리 직접 (data path)**. 단 "어디서 얼마나 읽어라"는 명령(**control path**)은 아직 CPU가 낸다.

### 4.8 영어 연습 문제

**Q1.** Why did SSDs move from SATA to PCIe/NVMe?

<details>
<summary>▶ 모범 답안</summary>

SSDs access many NAND dies in parallel, so their internal bandwidth is much higher than the SATA limit (600 MB/s). Also, SATA (AHCI) has only one queue with depth 32, which cannot use the internal parallelism. NVMe over PCIe has many lanes and up to 64K queues.
</details>

**Q2. (계산)** Calculate the effective bandwidth of SATA 3 (6 Gbps, 8b/10b) and PCIe Gen3 x4 (8 GT/s, 128b/130b).

<details>
<summary>▶ 모범 답안</summary>

```
SATA 3:       6 × 8/10 ÷ 8 = 0.6 GB/s = 600 MB/s
PCIe Gen3 x4: 8 × 128/130 × 4 ÷ 8 ≈ 3.94 GB/s
```
</details>

**Q3.** Explain the asymmetry between program and erase in NAND flash.

<details>
<summary>▶ 모범 답안</summary>

Program changes bits from 1 to 0 by putting electrons into the cell. It can be done selectively, in page units. Erase changes bits from 0 to 1 by removing electrons. It can only be done for a whole block at once. So we cannot overwrite a page; we must erase the whole block first (erase-before-write).
</details>

**Q4.** A page stores the hex value C. Can it be changed to 8 without erase? What about 9 → B?

<details>
<summary>▶ 모범 답안</summary>

```
C = 1100 → 8 = 1000 : only 1→0 changes → program only, no erase needed
9 = 1001 → B = 1011 : one bit 0→1        → erase needed
```
If any bit changes from 0 to 1, an erase is required.
</details>

**Q5.** As bits per cell increase from SLC to QLC, what happens to capacity, speed, and endurance? Why?

<details>
<summary>▶ 모범 답안</summary>

Capacity increases and cost per GB decreases. But speed and endurance (P/E cycles) decrease. This is because n bits need 2ⁿ voltage states, so the margin between states becomes very narrow. The controller must program and sense more precisely, errors increase, and small wear makes states hard to distinguish.
</details>

**Q6.** Explain channel and way in an SSD.

<details>
<summary>▶ 모범 답안</summary>

A channel is an independent bus between the flash controller and NAND chips; different channels transfer data at the same time. A way is the number of chips sharing one channel; while one chip is busy programming, the controller sends data to another chip (interleaving). Together they create the SSD's internal parallelism.
</details>

**Q7.** Why is an eMMC (parallel) slower than UFS (serial)?

<details>
<summary>▶ 모범 답안</summary>

At high clock speeds, parallel wires suffer from skew (signals arrive at different times) and crosstalk (interference between wires). So the parallel bus cannot run fast. UFS uses fast serial lanes, full-duplex, and command queuing.
</details>

<br/>

---

## 블록 5. FTL — NAND Flash Management (45분) — 6주차 ★★

### 5.1 흐름 한 줄

> Flash는 덮어쓰기 불가 → 그대로 쓰면 **RMW** (느림 + **write amplification**) → **COW**로 빈 곳에 쓰고 **mapping table**로 주소 변환 = **FTL** → 대가로 쓰레기 발생 → **GC**로 회수 → 수명 한계 → **wear leveling** → 불량·간섭 → **bad block management, data refresh**

### 5.2 SSD 펌웨어 3계층

| 계층 | 역할 |
|---|---|
| **HIL** (Host Interface Layer) | NVMe SQ/CQ에서 요청 가져오기 |
| **FTL** (Flash Translation Layer) | 주소 변환, write buffering, GC, wear leveling |
| **FIL** (Flash Interface Layer) | 실제 NAND 명령으로 변환 |

- 전통 API: `read sector`, `write sector` (덮어쓰기 가정) ↔ Flash: `read`, `program`, `erase` → 이 불일치를 FTL이 메움

### 5.3 Read-Modify-Write ★ (계산)

Page 하나 수정 (Block = 4 pages, MLC: read 100µs, program 800µs, erase 3ms):

```
1. Read    4 pages  = 4 × 100 µs = 0.4 ms
2. Modify  in DRAM  ≈ 0
3. Erase   1 block  = 3 ms
4. Program 4 pages  = 4 × 800 µs = 3.2 ms
Total = 0.4 + 3 + 3.2 = 6.6 ms    ← HDD 랜덤 쓰기 수준
```

### 5.4 Write Amplification ★

```
WAF = NAND에 실제로 쓴 양 / 호스트가 요청한 양
```

- 위 예: 1 page 요청 → 4 page 씀 → **WAF = 4**
- WAF가 크면 → **느려지고 + P/E 수명도 빨리 닳음**
- 원인: RMW, **GC의 valid page 복사**

### 5.5 Copy-on-Write와 Mapping Table ★

| | In-place update | Out-of-place update (COW) |
|---|---|---|
| 동작 | 그 자리에 덮어씀 | **빈 page에 새로 쓰고 주소를 바꿈**, 옛 page는 버림 |
| 사용처 | HDD | Flash |

- FS에 "주소 바뀌었다"고 알리면 계층 분리가 깨짐 → SSD 내부에 **mapping table** (논리 → 물리)을 둬서 바깥에선 **그냥 디스크처럼 보이게** 함
- Mapping table은 SSD 내부 **DRAM/SRAM**에 있음 → 잃어버리면 데이터 위치를 모름
- **크기 계산**: 1TB / 4KB page = 2²⁸ 개 엔트리 × 4B = **약 1GB** → "SSD 1TB당 DRAM 1GB"
- 줄이는 방법: block 매핑, hybrid 매핑, DFTL (자주 쓰는 매핑만 DRAM에 캐싱)
- COW의 대가: ① **garbage** 발생 → GC 필요 ② page **상태 관리** 필요 ③ **mapping table** 관리

### 5.6 Page 상태 ★

```
          program
  free ───────────▶ valid
   ▲                  │
   │ erase (block)    │ 덮어쓰기(relocate) or TRIM
   │                  ▼
   └────────────── invalid
```

- invalid → free는 **block 단위 erase**로만 가능

**TRIM**: 파일을 지워도 FS 메타데이터만 바뀌어서 SSD는 그 page가 쓸모없다는 걸 모름 → OS가 "이 논리 주소는 안 쓴다"고 SSD에 알려주는 명령 → page를 invalid로 → GC 때 쓸데없이 복사하지 않음. (HDD는 덮어쓰기가 되니 필요 없음)

### 5.7 Garbage Collection ★★

**4단계**
1. 쓰레기(invalid) page가 있는 **victim block**을 고름
2. 그 block의 **valid page를 읽음**
3. valid page를 **다른 빈 block에 씀** (mapping 갱신)
4. victim block 전체를 **erase** → free

- 비용 = **옮겨야 할 valid page 양**. 전부 invalid면 erase 한 번으로 끝 (가장 좋음)
- 복사 받을 **빈 block이 항상 하나는 남아 있어야** 함
- **Over-provisioning**: 보이는 용량보다 NAND를 더 탑재 (예: NAND 1TB, 노출 960GB) → 쓰레기가 많이 쌓일 때까지 기다릴 수 있음 → GC 비용↓
- **Background GC**: idle 때 수행해서 사용자 I/O에 영향↓
- **Reactive GC**: 빈 block이 임계치 아래로 떨어지면 수행 (사용자 요청 중에 걸리면 지연 튐) / **Proactive GC**: idle을 **예측**해서 미리 수행 (독립변수 = 요청 간격·빈 block 수·쓰기 패턴 → 종속변수 = GC 시점, ML 적용 가능)

**Victim 선택**

| 정책 | 기준 | 단점/장점 |
|---|---|---|
| **Greedy** | valid page가 **가장 적은** block | 곧 바뀔 hot data를 복사할 수 있음 |
| **Cost-Benefit** | 아래 점수가 가장 큰 block | age까지 고려 → cold block 우선 |

```
score = benefit / cost = (1 − u) × age / 2u

u   = block의 valid 비율 (0~1)
1−u = 회수할 수 있는 빈 공간
age = 마지막 수정 후 지난 시간 (오래될수록 남은 데이터도 안 바뀔 가능성↑)
2u  = valid 데이터를 읽고(u) + 쓰는(u) 비용
```

### 5.8 Wear Leveling

- **Endurance** = 셀이 견디는 P/E 횟수. 특정 block만 계속 쓰면 그 block이 먼저 죽음
- **Dynamic**: 새 쓰기를 **덜 닳은 빈 block**에 배치
- **Static**: 거의 안 바뀌는 **cold data**를 가끔 옮겨서, 그 data가 차지하던 덜 닳은 block도 쓰기에 참여시킴
- 목표: 모든 block의 P/E 횟수를 **평평하게**

### 5.9 Bad Block & Read Disturb

- **Bad block**: 제조 시 불량 + 사용 중 고장 (runtime) → **OOB 영역**(page마다 붙은 메타데이터 공간)에 표시하고 **spare block**으로 대체
- **Read disturb**: 한 block을 반복해서 **읽기만 해도** 주변 셀에 전압 간섭이 쌓여 에러 발생
- **Data refresh**: 취약해진 block의 데이터를 주기적으로 새 block에 다시 씀 (사용자가 읽기만 한 사진도 SSD가 내부적으로 옮김)

### 5.10 영어 용어

| 영어 | 뜻 |
|---|---|
| erase-before-write | 쓰기 전에 지워야 함 |
| read-modify-write (RMW) | block 읽기 → 수정 → erase → 다시 쓰기 |
| write amplification factor (WAF) | 실제 NAND 쓰기 / 요청 쓰기 |
| copy-on-write (COW) | 새 위치에 쓰고 옛 것은 버림 |
| address translation / mapping table | 주소 변환 / 논리→물리 표 |
| garbage collection (GC) / victim block | 쓰레기 회수 / 회수 대상 block |
| over-provisioning | 여유 용량 탑재 |
| wear leveling | 마모 평준화 |
| endurance / P/E cycle | 내구성 / program-erase 횟수 |
| read disturb / data refresh | 읽기 간섭 / 데이터 재기록 |
| out-of-band (OOB) area | page별 메타데이터 여분 공간 |

### 5.11 영어 연습 문제

**Q1. (계산)** An SSD block has 4 pages. Page read = 50 µs, page program = 300 µs, block erase = 2 ms. Calculate the latency to update one page using read-modify-write. What is the write amplification factor?

<details>
<summary>▶ 모범 답안</summary>

```
Read 4 pages    = 4 × 50  = 0.2 ms
Erase 1 block   = 2 ms
Program 4 pages = 4 × 300 = 1.2 ms
Total           = 0.2 + 2 + 1.2 = 3.4 ms
WAF = 4 pages written / 1 page requested = 4
```
</details>

**Q2.** What is write amplification and why is it bad?

<details>
<summary>▶ 모범 답안</summary>

Write amplification means the SSD writes more data to NAND than the host requested. WAF = (data written to NAND) / (data written by host). It is bad because it reduces performance and wears out the cells faster, shortening the SSD lifetime.
</details>

**Q3.** Explain how the FTL avoids read-modify-write. What are the costs of this approach?

<details>
<summary>▶ 모범 답안</summary>

The FTL uses copy-on-write (out-of-place update). It writes new data to a free page and updates the mapping table from the logical address to the new physical address. The old page becomes invalid. Costs: (1) garbage pages are created, so garbage collection is needed, (2) page states must be managed, (3) the mapping table needs DRAM and must never be lost.
</details>

**Q4. (계산)** A 2 TB SSD uses page-level mapping with 4 KB pages and 4-byte entries. How much DRAM is needed for the mapping table?

<details>
<summary>▶ 모범 답안</summary>

```
Entries = 2 TB / 4 KB = 2⁴¹ / 2¹² = 2²⁹ ≈ 537 million
Size    = 2²⁹ × 4 B = 2³¹ B = 2 GB
```
(Rule of thumb: about 1 GB of DRAM per 1 TB of SSD.)
</details>

**Q5.** Draw the page state diagram and explain each transition.

<details>
<summary>▶ 모범 답안</summary>

```
free --program--> valid --overwrite/TRIM--> invalid --erase(block)--> free
```
A free page becomes valid when data is programmed. A valid page becomes invalid when the same logical address is written to another page, or when TRIM says it is no longer used. Invalid pages return to free only when the whole block is erased.
</details>

**Q6.** Why is TRIM needed for SSDs but not for HDDs?

<details>
<summary>▶ 모범 답안</summary>

When a file is deleted, the file system only updates its metadata, so the SSD still thinks the pages are valid. Without TRIM, GC copies this useless data, increasing write amplification. TRIM tells the SSD which logical addresses are no longer used. HDDs can overwrite in place, so they do not need to know.
</details>

**Q7.** List the steps of garbage collection.

<details>
<summary>▶ 모범 답안</summary>

1. Select a victim block that has invalid pages.
2. Read the valid pages in the victim block.
3. Write the valid pages to a free block and update the mapping table.
4. Erase the victim block so it becomes free.
</details>

**Q8. (계산)** Block X: u = 0.25, age = 8. Block Y: u = 0.1, age = 2. Which block does Greedy choose? Which does Cost-Benefit choose?

<details>
<summary>▶ 모범 답안</summary>

```
Greedy:  fewest valid pages → Y (u = 0.1)
Cost-Benefit:
  X = (1 − 0.25) × 8 / (2 × 0.25) = 6 / 0.5 = 12
  Y = (1 − 0.1)  × 2 / (2 × 0.1)  = 1.8 / 0.2 = 9
  → X (higher score)
```
Cost-Benefit prefers X because it is old (cold), so its remaining valid data will probably not change soon. Y is young (hot), so if we wait, more of its pages may become invalid for free.
</details>

**Q9.** How does over-provisioning reduce GC cost?

<details>
<summary>▶ 모범 답안</summary>

Over-provisioning adds extra flash capacity that the user cannot see. With more free space, the SSD can wait longer before GC, so victim blocks have more invalid pages and fewer valid pages to copy. This lowers GC cost and write amplification.
</details>

**Q10.** Compare dynamic and static wear leveling.

<details>
<summary>▶ 모범 답안</summary>

Dynamic wear leveling places new writes on less-worn free blocks. Static wear leveling also moves cold data that rarely changes, so the blocks it occupies can join the write rotation. Static wear leveling spreads wear more evenly.
</details>

**Q11.** What is read disturb and how does the SSD handle it?

<details>
<summary>▶ 모범 답안</summary>

Read disturb is when reading a block many times causes voltage interference on nearby cells, creating errors even without writes. The SSD uses data refresh: it periodically rewrites the data of weak blocks to new blocks before errors accumulate.
</details>

<br/>

---

## 블록 6. 최종 점검 — 영어 백지 테스트 (15분)

종이 한 장에 **답을 보지 않고** 쓰세요. 막히는 문항만 해당 블록으로 돌아가면 됩니다.

### 6.1 숫자·공식 (5분)

| # | 질문 | 정답 |
|---|---|---|
| 1 | Average rotational delay formula? | ½ × 60,000 / RPM (ms) |
| 2 | 7,200 RPM avg rotation? / 15,000? | ≈ 4.2 ms / 2 ms |
| 3 | HDD I/O time = ? | seek + rotation + transfer |
| 4 | Average seek distance ≈ ? of max | 1/3 |
| 5 | RAID-0 mapping (chunk 1)? | Disk = A % N, Offset = A / N |
| 6 | RAID-4 / RAID-5 random write? | R/2 / N·R/4 |
| 7 | RAID-1 random read / write? | N·R / (N/2)·R |
| 8 | RAID-5 write latency? | 2D |
| 9 | RAID-6 capacity / tolerable failures? | (N−2)·C / 2 |
| 10 | Subtractive parity? | P_new = P_old ⊕ D_old ⊕ D_new |
| 11 | SATA 3 effective bandwidth? | 600 MB/s |
| 12 | Block size if page 16 KB × 256? | 4 MB |
| 13 | n bits per cell → ? states | 2ⁿ |
| 14 | WAF = ? | NAND writes / host writes |
| 15 | Cost-Benefit score? | (1 − u) × age / 2u |
| 16 | Mapping table DRAM per 1 TB? | ≈ 1 GB |

### 6.2 한 문장 영어 설명 (10분) — 키워드만 써도 OK

1. Why is random I/O slow on HDD? → *seek + rotation (ms) dominate*
2. Why can't the OS do SPTF? → *doesn't know rotational position*
3. Why is RAID-4 random write R/2? → *single parity disk bottleneck*
4. Why does RAID-5 fix it? → *rotating parity, load spread over N disks*
5. Why Reed-Solomon in RAID-6? → *need two independent equations*
6. Program vs erase? → *1→0 per page / 0→1 per block*
7. Why erase-before-write is a problem? → *RMW, slow, write amplification*
8. What does the FTL do? → *address translation, GC, wear leveling*
9. Why TRIM? → *SSD doesn't know deleted pages are invalid*
10. Why over-provisioning? → *more free space → fewer valid pages to copy in GC*
11. SLC → QLC trade-off? → *capacity↑ cost↓ / speed↓ endurance↓ errors↑*
12. Read disturb? → *repeated reads disturb nearby cells → data refresh*

<br/>

---

> ⚠️ **참고 사항**
> - 3주차 노트 끝의 **VAST Data / DASE**는 "다음 시간 예습"으로 정리된 부분이며, 이후 4~5주차에서 사례로만 언급됐습니다. 이 가이드에서는 핵심 아이디어(QLC + SCM 버퍼로 small-write 제거)만 넣었습니다.
> - P/E cycle, NAND 지연 숫자는 주차마다 슬라이드 값이 조금씩 다릅니다. **문제에 숫자가 주어지면 그 숫자를 쓰세요.**
> - 교수님이 예상 문제/유형 힌트를 주시면 이 가이드의 해당 블록에 문항을 추가하면 됩니다.
