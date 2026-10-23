# AI 데이터 시스템 및 인프라 중간고사 — 출제 유형별 학습 가이드

> **범위**: 1~6주차 실제 강의 내용 (HDD → RAID → NAND/SSD → FTL)
> **분량**: 블록 0~7 = **약 3시간** (시간이 부족하면 아래 우선순위대로)
> **시험은 영어로 출제** → 모든 개념은 **English 핵심 문장 + 한국어 설명**, 모든 연습 문제는 **영어 문제 + *한국어 해석*** + **영어 모범 답안 + *한국어 해석*** 으로 썼습니다.
>
> 💡 VSCode에서 `Cmd+Shift+V`(미리보기)로 보세요. 답은 `▶`로 접혀 있습니다. **먼저 직접 풀고** 펼치세요.

<br/>

## 교수님이 알려주신 출제 유형 → 이 가이드의 블록

| # | 출제 유형 (교수님 공지) | 블록 | 시간 | 비중 |
|---|---|---|---|---|
| 1 | 강의자료 개념, **True / False** 문제 | 각 블록 + **블록 7 (T/F 50문항)** | 25분 | ★★ |
| 2 | HDD **읽기/쓰기, 응답시간, bandwidth 계산** | 블록 1 | 30분 | ★★★ |
| 3 | HDD **내부 최적화 기법/기술** | 블록 2 | 15분 | ★★ |
| 4 | RAID 기술 이해 (**비교 분석**) | 블록 3 | 35분 | ★★★ |
| 5 | SSD **내부 architecture** 및 개념 | 블록 4 | 20분 | ★★ |
| 6 | **FTL (주소 변환)** — "제대로 이해하기" | 블록 5 | **45분** | ★★★★ |
| — | 영어 시험 생존 키트 / 최종 점검 | 블록 0 / 블록 6 | 10분 / — | — |

**시간표**: 블록 0 (0:10) → 1 (0:40) → 2 (0:55) → 3 (1:30) → 4 (1:50) → **5 (2:35)** → 7 T/F (3:00) → 블록 6은 시험 직전 5분

**우선순위** (시간 부족 시): **블록 5 FTL > 블록 1 HDD 계산 > 블록 3 RAID > 블록 7 T/F > 블록 4 > 블록 2**
- 교수님이 FTL에 "**제대로 이해하기**"라고 강조 → 가장 길게, **주소 변환을 손으로 따라가는 trace 문제**를 넣었습니다.

<br/>

---

## 블록 0. 영어 시험 생존 키트 (10분)

### 0.1 문제 동사 — "무엇을 하라는지"부터 파악

| 영어 | 뜻 | 답안 형태 |
|---|---|---|
| **True or False** (+ *Justify / Explain*) | 참/거짓 (+ 이유) | T/F + "because ..." 한 문장 |
| **Explain / Describe** | 설명하라 | 짧은 문장 2~4개 |
| **Why** ... ? | 이유 | "Because ..." |
| **Compare / Contrast** | 비교하라 | 표, 또는 "A ..., while B ..." |
| **Calculate / Compute / What is** | 계산하라 | 식 → 숫자 → **단위** |
| **Show the steps / Trace** | 과정을 보여라 / 따라가라 | 1. 2. 3. 또는 표 |
| **Which is better? Justify.** | 고르고 근거 | 선택 + **숫자 근거** |
| **Given / Assume** | 주어진 / 가정 | 문제 조건 |
| **List / Name** | 나열하라 | 단어만 OK |

### 0.2 답안 문장 틀 — 단어만 끼우기

```
[정의]   X is a technique that ~.               X는 ~하는 기법이다.
[이유]   This is because ~.                       왜냐하면 ~이기 때문이다.
[문제]   The problem is that ~.                   문제는 ~라는 것이다.
[해결]   To solve this, X ~.                      이를 해결하기 위해 X가 ~한다.
[대조]   A ~, while B ~.                           A는 ~인 반면 B는 ~이다.
[결과]   As a result, ~. / Therefore, ~.          그 결과 / 따라서
[T/F]    False. ~ is actually ~, not ~.           거짓. 실제로는 ~이지 ~가 아니다.
[계산]   X = (formula) = (number) (unit).
```

### 0.3 True / False 함정 패턴 ★

| 함정 | 예 | 체크 방법 |
|---|---|---|
| **단위 바꿔치기** | "erase is done per **page**" | page(읽기·쓰기) vs block(지우기) |
| **방향 바꿔치기** | "program changes 0 → 1" | program = 1→0, erase = 0→1 |
| **주어 바꿔치기** | "the **OS** implements SPTF", "**PCIe** is a protocol" | 누가 / 무엇이 |
| **숫자 바꿔치기** | "avg rotation at 7,200 RPM = 8.3 ms", "RAID-5 write latency = 4D" | 1회전 vs 평균(½), I/O 개수 vs latency |
| **절대 표현** | always, never, only, all, any | 예외 하나만 떠올려도 False |
| **증가/감소 뒤집기** | "more bits per cell → **more** P/E cycles" | ↑/↓ 방향 |

> 시험에서 T/F 옆에 이유를 쓰라고 하면, **False 문장은 "틀린 단어 하나"를 고친 문장**을 쓰면 됩니다.
> 예: *"Erase is done per page."* → **False. Erase is done per block.**

<br/>

---

## 블록 1. HDD 계산 — 읽기/쓰기 · 응답시간 · Bandwidth (30분) ★★★

### 1.1 공식 — 이 4줄이면 모든 문제를 풉니다

```
T_I/O       = T_seek + T_rotation + T_transfer         (읽기·쓰기 동일)
T_rotation  = ½ × (60,000 ms / RPM)                    (평균 = 반 바퀴)
T_transfer  = request size / max transfer rate
Bandwidth   = request size / T_I/O      IOPS = 1 / T_I/O = 1000 / T_I/O(ms)
```

| English | 한국어 |
|---|---|
| **seek time** — the time to move the arm to the target track | 헤드를 목표 track으로 옮기는 시간 (4~10 ms) |
| **rotational delay** — the time waiting for the target sector to rotate under the head | 목표 sector가 헤드 밑으로 올 때까지 기다리는 시간 (평균 반 바퀴) |
| **transfer time** — the time to actually read or write the data | 실제 데이터 전송 시간 (µs) |
| **response time** — the time from request to completion (= waiting in queue + T_I/O) | 요청부터 완료까지의 시간 (큐 대기 + 서비스 시간) |
| **bandwidth (throughput)** — data per second (MB/s) | 초당 전송량 |

**외울 숫자**

| RPM | 1회전 | 평균 rotational delay |
|---|---|---|
| 5,400 | 11.1 ms | 5.6 ms |
| 7,200 | 8.3 ms | **4.2 ms** |
| 10,000 | 6 ms | **3 ms** |
| 15,000 | 4 ms | **2 ms** |

**함정 3개**
1. **1회전 시간 ≠ 평균 rotational delay** (평균은 **½**)
2. 단위: `ms`, `µs`, `MB/s`. 강의 예제는 **1 MB = 1024 KB**로 계산했음 (16KB / 125MB/s = 125 µs). 답안에 단위 가정을 한 줄 써 두면 안전합니다.
3. **Sequential** = seek·rotation이 (거의) 처음 한 번만 → bandwidth ≈ max transfer rate / **Random** = 요청마다 seek + rotation

### 1.2 강의 대표 예제 (반드시 재현할 수 있어야 함)

| | Cheetah 15K.5 | Barracuda |
|---|---|---|
| RPM / Avg seek / Max transfer | 15,000 / 4 ms / 125 MB/s | 7,200 / 9 ms / 105 MB/s |
| Rotation | ½ × 60,000/15,000 = **2 ms** | ½ × 60,000/7,200 ≈ **4.1 ms** |
| Transfer (16 KB) | 16 KB / 125 MB/s = **125 µs** | 16 KB / 105 MB/s ≈ **149 µs** |
| **T_I/O** | 4 + 2 + 0.125 ≈ **6.1 ms** | 9 + 4.1 + 0.149 ≈ **13.2 ms** |
| **Random bandwidth** | 16 KB / 6.1 ms ≈ **2.5 MB/s** | 16 KB / 13.2 ms ≈ **1.2 MB/s** |
| Sequential bandwidth | **125 MB/s** | **105 MB/s** |
| IOPS | ≈ 164 | ≈ 76 |

> **English key sentence**: *"Random I/O is dominated by seek and rotation, so its throughput is 50–90 times lower than sequential I/O."*
> (랜덤 I/O는 seek와 rotation이 지배하므로 처리량이 순차 I/O보다 50~90배 낮다.)

### 1.3 연습 문제

**Q1. (Random read)** A disk spins at **10,000 RPM**. The average seek time is **5 ms** and the maximum transfer rate is **100 MB/s**. Calculate (a) the time for one random **4 KB** read, (b) the random read bandwidth, and (c) IOPS.
*(10,000 RPM, 평균 seek 5 ms, 최대 전송률 100 MB/s. 4 KB 랜덤 읽기 1회 시간, 랜덤 읽기 bandwidth, IOPS를 구하라.)*

<details>
<summary>▶ 답</summary>

```
(a) Seek       = 5 ms
    Rotation   = ½ × 60,000 / 10,000 = 3 ms
    Transfer   = 4 KB / 100 MB/s = 4 / (100 × 1024) s ≈ 0.04 ms (39 µs)
    T_I/O      ≈ 5 + 3 + 0.04 = 8.04 ms
(b) Bandwidth  = 4 KB / 8.04 ms ≈ 497 KB/s ≈ 0.49 MB/s
(c) IOPS       = 1000 / 8.04 ≈ 124
```
Seek and rotation take 99% of the time; the transfer time is negligible.
*(seek와 rotation이 시간의 99%를 차지하고, 전송 시간은 무시할 만하다.)*
</details>

**Q2. (Sequential read)** On the same disk, a **10 MB** file is stored contiguously. Calculate the time to read the whole file and the effective bandwidth. Compare with Q1.
*(같은 디스크에서 연속으로 저장된 10 MB 파일을 읽는 시간과 실효 bandwidth를 구하고 Q1과 비교하라.)*

<details>
<summary>▶ 답</summary>

```
Seek       = 5 ms            (처음 한 번만)
Rotation   = 3 ms            (처음 한 번만)
Transfer   = 10 MB / 100 MB/s = 100 ms
Total      = 108 ms
Bandwidth  = 10 MB / 0.108 s ≈ 92.6 MB/s
```
Sequential bandwidth (≈ 92.6 MB/s) is about **190 times** higher than random 4 KB bandwidth (≈ 0.49 MB/s), because seek and rotation are paid only once.
*(seek와 rotation을 한 번만 내므로 순차 bandwidth가 랜덤보다 약 190배 높다. 파일이 클수록 max transfer rate에 가까워진다.)*
</details>

**Q3. (Write)** Is the time for a random 4 KB **write** different from a random 4 KB read in Q1? What if the disk uses write caching with immediate reporting?
*(Q1에서 4 KB 랜덤 쓰기 시간은 읽기와 다른가? 디스크가 write caching(immediate reporting)을 쓰면?)*

<details>
<summary>▶ 답</summary>

Without caching, a write also needs seek + rotation + transfer, so it takes the same **≈ 8.04 ms**. With immediate reporting, the disk sends the ACK as soon as the data is in its DRAM cache, so the **response time** the host sees is much shorter (no seek, no rotation). But the data is not on the platter yet, so it can be **lost on power failure**.
*(캐시가 없으면 쓰기도 seek+rotation+transfer라 약 8.04 ms로 같다. immediate reporting이면 디스크 DRAM에 들어가자마자 ACK를 보내므로 호스트가 보는 응답 시간은 훨씬 짧다. 하지만 아직 platter에 안 써졌으므로 정전 시 데이터가 손실될 수 있다.)*
</details>

**Q4. (Response time & scheduling)** Six requests arrive at the same time: `300001, 700001, 300002, 700002, 300003, 700003`. Assume a far jump (seek + rotation) costs **10 ms** and a request next to the previous one costs **≈ 0 ms**. Calculate the total time and the **average response time** for (a) FCFS and (b) the sorted order.
*(6개 요청이 동시에 도착. 먼 점프는 10 ms, 바로 옆 요청은 ≈0 ms로 가정. (a) FCFS, (b) 정렬된 순서의 총 시간과 평균 응답 시간을 구하라.)*

<details>
<summary>▶ 답</summary>

```
(a) FCFS: 매번 먼 점프 → 완료 시각 10, 20, 30, 40, 50, 60 ms
    Total = 60 ms,  Avg response = (10+20+30+40+50+60) / 6 = 35 ms

(b) Sorted: 300001, 300002, 300003, 700001, 700002, 700003
    점프는 2번(처음, 700001) → 완료 시각 10, 10, 10, 20, 20, 20 ms
    Total = 20 ms,  Avg response = (10×3 + 20×3) / 6 = 15 ms
```
Reordering requests by position reduces the total time by 3x. This is why disks use command queuing (TCQ/NCQ) and the OS uses I/O scheduling.
*(위치 기준으로 재정렬하면 총 시간이 3배 줄어든다. 그래서 디스크는 TCQ/NCQ, OS는 I/O 스케줄링을 쓴다.)*

> 강의 예제는 총 시간(60 ms → 20 ms)까지만 다뤘고, 평균 응답 시간은 같은 가정으로 확장한 계산입니다.
</details>

**Q5. (Transfer rate from geometry)** A track has **500 sectors** of **512 B**, and the disk spins at **7,200 RPM**. (a) What is the transfer time for one sector? (b) What is the maximum transfer rate? (c) An outer zone has **1,000 sectors** per track. What is its transfer rate?
*(track당 512 B sector 500개, 7,200 RPM. (a) sector 1개 전송 시간 (b) 최대 전송률 (c) 바깥 zone이 track당 1,000 sector면 전송률은?)*

<details>
<summary>▶ 답</summary>

```
1 rotation       = 60,000 / 7,200 ≈ 8.33 ms
(a) 1 sector     = 8.33 ms / 500 ≈ 0.0167 ms (16.7 µs)
(b) Rate         = (500 × 512 B) / 8.33 ms = 256,000 B / 0.00833 s ≈ 30.7 MB/s   (1 MB = 10⁶ B)
(c) Outer zone   = (1,000 × 512 B) / 8.33 ms ≈ 61.4 MB/s  → 2배
```
RPM is constant, so a track with more sectors passes more data under the head per second. This is why **outer zones in ZBR have a higher sequential transfer rate**.
*(RPM은 일정하므로 sector가 많은 track은 초당 더 많은 데이터가 헤드 밑을 지나간다. 그래서 ZBR에서 바깥 zone의 순차 전송률이 높다.)*
</details>

**Q6. (응용: Track skew)** Using Q5's disk (500 sectors/track, 7,200 RPM), moving the head to the next track and settling takes **1 ms**. How many sectors should the track skew be at least?
*(Q5 디스크에서 옆 track으로 이동+settle에 1 ms가 걸린다. track skew는 최소 몇 sector여야 하나?)*

<details>
<summary>▶ 답</summary>

```
1 sector = 0.0167 ms
1 ms / 0.0167 ms ≈ 60 sectors   → skew ≥ 60 sectors
```
During the 1 ms switch, about 60 sectors pass under the head. If the next track's first sector is shifted by at least 60 sectors, the head arrives just in time and does not wait a full rotation.
*(1 ms 동안 약 60 sector가 지나간다. 다음 track의 시작 sector를 60 sector 이상 밀어 두면 헤드가 제때 도착해 한 바퀴를 기다리지 않는다.)*

> 강의에서는 track skew 개념만 다뤘고, 이 숫자 계산은 개념을 확인하기 위한 응용입니다.
</details>

**Q7. (Comparison)** Using the Cheetah/Barracuda numbers, which disk is better for (a) a database with random 16 KB reads, (b) storing large video backups? Justify.
*(Cheetah/Barracuda 중 (a) 16 KB 랜덤 읽기 DB, (b) 대용량 동영상 백업에 각각 어느 디스크가 나은가?)*

<details>
<summary>▶ 답</summary>

(a) **Cheetah**: random bandwidth 2.5 MB/s vs 1.2 MB/s (about 2x), because its seek (4 ms vs 9 ms) and rotation (2 ms vs 4.1 ms) are shorter.
(b) **Barracuda**: the workload is sequential, so the sequential rates are close (125 vs 105 MB/s), and Barracuda has more capacity (1 TB vs 300 GB) at a lower cost.
*((a) seek와 rotation이 짧은 Cheetah가 랜덤에서 약 2배 빠르다. (b) 순차 워크로드라 전송률 차이는 작고, Barracuda가 용량이 크고 싸다.)*
</details>

<br/>

---

## 블록 2. HDD 내부 최적화 기법/기술 (15분) ★★

### 2.1 한 장 요약표 — "무슨 문제를 → 어떻게 해결"

| 기법 (English) | Problem (문제) | Solution (해결) |
|---|---|---|
| **Servo burst** | The head does not know its position; tracks are not perfect circles (**runout**), and density (BPI/TPI) keeps increasing. *(헤드가 자기 위치를 모름, track이 완벽한 원이 아님)* | Position info is written every 3–5 sectors; the head corrects its position when passing. *(3~5 sector마다 위치 정보 기록)* |
| **Track skew** | In a sequential read from track 15 → 16, sector 16 passes while the head settles → wait a full rotation. *(settle 중에 다음 sector를 놓침)* | Shift the starting sector of neighboring tracks so the head has **enough time to settle**. *(인접 track의 시작 위치를 어긋나게)* |
| **Zones (ZBR)** | Outer tracks are longer; same sector count wastes space. *(바깥 track이 더 긴데 sector 수가 같으면 낭비)* | Put **more sectors on outer tracks**; tracks in the same zone have the same sector count. → outer zones: higher sequential rate *(바깥 track에 sector를 더 많이)* |
| **Read-ahead (track buffer)** | The disk does not know what will be read next. *(다음에 뭘 읽을지 모름)* | During rotational delay, read the **whole track** into the disk cache. *(회전 대기 동안 track 전체를 미리 읽음)* |
| **Write caching (immediate reporting / writeback)** | Writing to the platter is slow. *(platter 쓰기는 느림)* | ACK when data is in disk DRAM. ⚠️ **Data loss on power failure → consistency broken** *(DRAM에 넣자마자 ACK, 정전 시 손실)* |
| **TCQ / NCQ** (Tagged / Native Command Queuing) | Requests processed one by one in arrival order. *(도착 순서대로 하나씩)* | Many outstanding requests; the **disk reorders** them using position info. (TCQ = SCSI/SAS, NCQ = SATA) *(디스크가 순서 재배치)* |
| **SPTF in the disk** | OS does not know rotational position. *(OS는 회전 위치를 모름)* | The disk schedules by **seek + rotation** (only the disk knows the geometry). *(디스크 내부 스케줄링)* |
| **Bad sector remapping** | Some sectors become bad. *(불량 sector 발생)* | Controller remaps to **spare sectors** inside the LBA → physical mapping; OS capacity (`df`) does not change. *(spare sector로 재매핑, OS 용량 그대로)* |
| **Multiple arms (연구 사례)** | Rotational delay was rarely optimized. *(회전 지연 자체는 잘 안 줄임)* | Two arms → average wait **½ → ¼ rotation**. (Seagate MACH.2 multi-actuator: 병렬 I/O 목적) |

**관련 개념**
- **Jitter**: a striped request must wait for the **slowest disk** → response-time variation, **tail latency** ↑ *(striping된 요청은 가장 느린 디스크를 기다림)*
- **Seek 4단계**: accelerate → coast → decelerate → **settle** (settle만 0.5~2 ms). **Short seek에는 coast가 없음**. 평균 seek 거리 ≈ 최대의 **1/3**
- **스케줄러 위치**: OS는 **LBA만**, Disk는 **geometry + 회전 위치**를 앎 → 둘 다 존재 (통합 스케줄링은 연구 주제)

| 스케줄러 | 기준 | 위치 | Starvation |
|---|---|---|---|
| FCFS | 도착 순서 | 어디든 | 없음 (비효율) |
| **SSTF** | seek 거리 최소 | **OS** | **있음** |
| **SPTF** | seek + rotation 최소 (greedy) | **Disk** | **있음** |
| SCAN (elevator) | 끝↔끝 왕복 | OS | 없음, **가운데 cylinder 유리** |
| C-SCAN | 한 방향만, 끝나면 처음으로 | OS | 없음, **더 공정 (fair)** |

### 2.2 용량 확장 기술 (HDD 신기술)

| 기술 | 원리 (English) | 장점 | 단점 / 용도 |
|---|---|---|---|
| **Helium drive** | Fill with helium instead of air → less friction | 얇은 platter → 더 많이 적층 → 용량↑, 진동↓ → 고장↓, 전력↓ | — |
| **HAMR** (Seagate) | **Laser heats** a tiny spot, then writes | 가장 높은 밀도 | 제조 난도·발열·비용 |
| **MAMR** (WD) | **Microwave** from STO helps flip magnetization | 레이저 불필요, 기존 공정 호환 | 최대 밀도 < HAMR |
| **SMR** | Tracks **overlap like shingles** | 싸고 대용량 | zone 안에서 **sequential write만** → random write 느림 → 백업·아카이브(WORM) |

- 왜 자성 입자를 무작정 작게 못 하나 → **열적 불안정성(thermal instability)**. HAMR/MAMR은 이를 우회.

### 2.3 연습 문제

**Q1.** What problem does track skew solve? Explain with an example.
*(track skew가 해결하는 문제를 예를 들어 설명하라.)*

<details>
<summary>▶ 답</summary>

When reading sector 15 (end of a track) and then sector 16 (start of the next track) sequentially, the head must move and settle. Without skew, sector 16 passes under the head during settling, so the disk waits almost a full rotation. Track skew shifts the start of the next track so that the head has enough time to settle.
*(15번 → 16번 순차 읽기 때 헤드가 옆 track으로 가서 settle하는 동안 16번이 지나가 버려 거의 한 바퀴를 기다린다. track skew는 다음 track의 시작 위치를 밀어 settle할 시간을 벌어 준다.)*
</details>

**Q2.** Why do outer zones have a higher transfer rate than inner zones?
*(왜 바깥 zone의 전송률이 더 높은가?)*

<details>
<summary>▶ 답</summary>

With ZBR, outer tracks have more sectors because they are longer. The RPM is the same, so more sectors pass under the head per second on outer tracks.
*(ZBR에서는 더 긴 바깥 track에 sector를 더 많이 둔다. RPM은 같으므로 바깥 track에서 초당 더 많은 sector가 지나간다.)*
</details>

**Q3.** Explain the risk of write caching with immediate reporting.
*(immediate reporting write caching의 위험을 설명하라.)*

<details>
<summary>▶ 답</summary>

The disk reports "write done" when the data is only in its volatile DRAM, not on the platter. If power fails, the data is lost even though the host was told it was saved. This breaks the consistency of the file system or database.
*(데이터가 휘발성 DRAM에만 있는데 "다 썼다"고 보고한다. 정전되면 저장됐다고 들은 데이터가 사라져 FS/DB의 일관성이 깨진다.)*
</details>

**Q4.** Why can the OS not implement SPTF? What does it use instead?
*(OS는 왜 SPTF를 구현하지 못하나? 대신 무엇을 쓰나?)*

<details>
<summary>▶ 답</summary>

SPTF needs the current rotational position of the head, but the OS only sees logical block addresses (LBA). Only the disk knows the geometry and rotation. So the OS uses SSTF, which only considers seek distance.
*(SPTF는 헤드의 회전 위치가 필요한데 OS는 LBA만 안다. 그건 디스크만 알기 때문에 OS는 seek 거리만 보는 SSTF를 쓴다.)*
</details>

**Q5.** What is TCQ/NCQ and why does it improve performance?
*(TCQ/NCQ는 무엇이고 왜 성능을 높이나?)*

<details>
<summary>▶ 답</summary>

TCQ (SCSI) and NCQ (SATA) let the host send multiple requests to the disk at once. The disk knows the head position, so it reorders the requests to minimize seek and rotation. Example: 60 ms → 20 ms in the lecture.
*(여러 요청을 한꺼번에 디스크에 보내면, 헤드 위치를 아는 디스크가 seek·rotation이 최소가 되도록 순서를 바꾼다. 강의 예: 60 ms → 20 ms.)*
</details>

**Q6.** Why is SMR good for archives but bad for random writes?
*(SMR이 아카이브에는 좋고 random write에는 나쁜 이유는?)*

<details>
<summary>▶ 답</summary>

SMR overlaps tracks like shingles to increase density, so writing one track overwrites part of the next track. Therefore, only sequential writes are allowed within a zone. Random writes require rewriting, which is slow. Archives (write once, read many) are mostly sequential, so SMR fits well.
*(track을 기와처럼 겹쳐서 한 track을 쓰면 옆 track 일부를 덮는다. 그래서 zone 안에서는 순차 쓰기만 가능하고 랜덤 쓰기는 재기록이 필요해 느리다. 아카이브는 대부분 순차라 잘 맞는다.)*
</details>

<br/>

---

## 블록 3. RAID — 비교 분석 (35분) ★★★

### 3.1 핵심 개념 (English + 한국어)

- **RAID** makes many inexpensive disks look like **one large, fast, reliable logical disk**. It is **transparent** (the FS does not know) and **deployable**.
  *(여러 개의 싼 디스크를 하나의 크고 빠르고 안 죽는 논리 디스크로 보이게 한다. 위 계층은 모르고, 그대로 꽂아 쓸 수 있다.)*
- Two tools: **mapping (striping)** → capacity & performance / **redundancy (mirroring, parity)** → reliability
- RAID uses **static mapping** (simple formula, easy in hardware), while the SSD FTL uses **dynamic mapping** (table). ← 블록 5와 연결
- **Fail-stop model**: a disk is either working or completely dead, and the system **knows which disk failed**. (Not covered: latent sector errors, silent data corruption → checksum, scrubbing)
- **JBOD**: one FS per disk; the application manages placement; no redundancy.

### 3.2 기호

| 기호 | 의미 |
|---|---|
| **N** | number of disks 디스크 수 |
| **C** | capacity of one disk 디스크 1개 용량 |
| **S** | sequential throughput of one disk |
| **R** | random throughput of one disk |
| **D** | latency of one small I/O |

### 3.3 최종 비교표 ★★★ (통째로)

| | Capacity | Reliability | Read lat. | Write lat. | Seq R | Seq W | Rand R | Rand W |
|---|---|---|---|---|---|---|---|---|
| **RAID-0** | N·C | **0** | D | D | N·S | N·S | N·R | N·R |
| **RAID-1** | (N/2)·C | **1** (운 좋으면 N/2) | D | D | (N/2)·S | (N/2)·S | **N·R** | (N/2)·R |
| **RAID-4** | (N−1)·C | 1 | D | **2D** | (N−1)·S | (N−1)·S | (N−1)·R | **R/2** |
| **RAID-5** | (N−1)·C | 1 | D | **2D** | (N−1)·S | (N−1)·S | **N·R** | **N·R/4** |
| **RAID-6** | (N−2)·C | **2** | | | | | | (write 1개 = 물리 I/O 6개) |

### 3.4 표를 "유도"하는 3원리 (외운 게 헷갈리면 이걸로)

1. **Count the useful disks** → read 계수. RAID-1 read는 아무 복사본 → N, RAID-4는 parity 디스크 제외 → N−1, RAID-5는 parity가 흩어져 있어 → N
2. **Count physical I/Os per logical write** → write 분모. RAID-1 = 2 (÷2), RAID-5 random write = **4** (÷4), RAID-4 = 4개 중 2개가 **parity 디스크 1개**에 몰림 → **R/2**
3. **Latency does not depend on N.** Parity update needs read → write → **2D**

- **RAID-1 seq read = (N/2)·S** (N·S 아님): 한 디스크가 0, 2, 4, 6을 읽으면 1, 3, 5, 7 자리를 **건너뛰며 회전**하므로 유효 대역폭 S/2
- **"Buying more disks improves throughput, but not latency."**

### 3.5 Small-write problem & XOR

```
P       = D0 ⊕ D1 ⊕ D2 ⊕ ...           (XOR: 같으면 0, 다르면 1)
복구     = 나머지 전부 XOR (P 포함)
P_new   = P_old ⊕ D_old ⊕ D_new        (subtractive parity)
물리 I/O = read D_old, read P_old, write D_new, write P_new  → 4개 (N과 무관)
Latency = 2D (read 2개 병렬 + write 2개 병렬)
```

- **RAID-4**: 모든 small write가 **하나뿐인 parity 디스크**를 2번(read+write) 건드림 → **bottleneck** → **R/2, N을 늘려도 그대로**
- **RAID-5**: parity를 **rotate** → 부하가 N개에 분산 → **N·R/4** → RAID-5 is **strictly better** than RAID-4
- **RAID-6**: P = **XOR**, Q = **Reed-Solomon**. 둘 다 XOR이면 같은 방정식 2개 → 미지수 2개를 못 품 → **linearly independent** 식 필요

### 3.6 비교 분석 — "어떤 상황에 무엇을?" ★

| Level | 장점 | 단점 | 적합한 워크로드 |
|---|---|---|---|
| **RAID-0** | 가장 빠름, 용량 100% | **reliability 0** — 1개만 죽어도 전부 손실 | 재생성 가능한 임시·캐시·scratch 데이터 |
| **RAID-1** | random write 최강 (RAID-5의 **2배**), 구조 단순 | 용량 **50%** | **random write가 많은 DB (OLTP)** |
| **RAID-4** | 용량 (N−1)/N | **parity 디스크 병목** → random write R/2 | 실무에서 거의 안 씀 (RAID-5가 상위 호환) |
| **RAID-5** | 용량 (N−1)/N, seq 성능 좋음 | small write 4 I/O, write latency 2D | **sequential read 위주, 용량 중요** (예: AI 학습 데이터셋) |
| **RAID-6** | **디스크 2개** 고장 허용 | 용량 (N−2)/N, write 더 비쌈 (6 I/O) | **대용량 디스크** — rebuild가 길어 그 사이 2번째 고장 위험 → 사실상 표준 |

**결론 3줄 (서술형 단골)**
1. RAID-0 is the fastest with full capacity, but has **no reliability**.
2. For **sequential** workloads, RAID-5 > RAID-1: (N−1)·S > (N/2)·S
3. For **random write** workloads, RAID-1 > RAID-5: (N/2)·R vs N·R/4 → **always 2x**, regardless of N

**용량 효율 (capacity efficiency)**: RAID-1 = 50%, RAID-5 = (N−1)/N, RAID-6 = (N−2)/N
- 예: N = 10 → RAID-5 90%, RAID-6 80% (8+2 구성, 오버헤드 20%)

**기타**
- **Rebuild**: fail detect → spare disk → 남은 데이터 + parity XOR로 복구 (**self-healing**). foreground 우선 → rebuild 느려짐 → **degraded 기간↑** (trade-off)
- **Consistent-update problem (RAID-1)**: 한쪽만 쓰고 crash → 어느 쪽이 맞는지 모름 → H/W RAID는 **NVRAM**에 로그 후 replay. S/W RAID는 NVRAM이 없음 → bitmap/journaling
- **RAID-0 매핑**: chunk 1 → `Disk = A % N`, `Offset = A / N` / chunk k → `Disk = (A/k) % N`, `Offset = (A/(k·N))·k + A%k`

### 3.7 연습 문제

공통 조건: **N = 8, C = 2 TB, S = 150 MB/s, R = 100 IOPS, D = 8 ms**

**Q1. (전체 비교)** Fill in the table for RAID-0, 1, 4, 5: capacity, reliability, write latency, sequential read, random read, random write.
*(RAID-0/1/4/5의 용량, 신뢰성, write latency, seq read, rand read, rand write를 채워라.)*

<details>
<summary>▶ 답</summary>

| | Capacity | Reliability | Write lat. | Seq Read | Rand Read | Rand Write |
|---|---|---|---|---|---|---|
| RAID-0 | 16 TB | 0 | 8 ms | 1,200 MB/s | 800 IOPS | 800 IOPS |
| RAID-1 | 8 TB | 1 (up to 4) | 8 ms | 600 MB/s | 800 IOPS | 400 IOPS |
| RAID-4 | 14 TB | 1 | 16 ms | 1,050 MB/s | 700 IOPS | **50 IOPS** |
| RAID-5 | 14 TB | 1 | 16 ms | 1,050 MB/s | 800 IOPS | **200 IOPS** |
| (RAID-6) | 12 TB | 2 | | | | |
</details>

**Q2. (OLTP)** A database performs mostly random writes. Which is better, RAID-1 or RAID-5? Justify with numbers and mention the trade-off.
*(랜덤 쓰기 위주 DB. RAID-1 vs RAID-5? 숫자로 근거를 대고 trade-off를 언급하라.)*

<details>
<summary>▶ 답</summary>

**RAID-1.** Random write: RAID-1 = (N/2)·R = 400 IOPS, RAID-5 = N·R/4 = 200 IOPS → RAID-1 is 2x faster. One logical write needs 2 physical writes in RAID-1, but 4 physical I/Os in RAID-5 (read old data, read old parity, write new data, write new parity). **Trade-off**: RAID-5 gives more capacity (14 TB vs 8 TB).
*(RAID-1이 2배 빠르다. RAID-1은 논리 쓰기 1개당 물리 쓰기 2개, RAID-5는 물리 I/O 4개. 대신 용량은 RAID-5가 크다.)*
</details>

**Q3. (AI dataset)** A GPU cluster reads a large training dataset sequentially. RAID-1 or RAID-5?
*(대용량 학습 데이터를 순차로 읽는 경우 RAID-1 vs RAID-5?)*

<details>
<summary>▶ 답</summary>

**RAID-5.** Sequential read: RAID-5 = (N−1)·S = 1,050 MB/s, RAID-1 = (N/2)·S = 600 MB/s. RAID-5 also has more capacity (14 TB vs 8 TB).
*(RAID-5가 순차 읽기에서 더 빠르고 용량도 크다.)*
</details>

**Q4. (Scaling)** We double N from 8 to 16. How does the random write throughput of RAID-4 and RAID-5 change? Why?
*(N을 8 → 16으로 늘리면 RAID-4, RAID-5의 랜덤 쓰기 처리량은? 이유는?)*

<details>
<summary>▶ 답</summary>

```
RAID-4: R/2 = 50 IOPS → 50 IOPS   (no change)
RAID-5: N·R/4 = 200 → 16 × 100 / 4 = 400 IOPS   (doubled)
```
In RAID-4, every small write reads and writes the **single parity disk**, so it is the bottleneck regardless of N. RAID-5 **rotates** parity across all disks, so the load is spread and throughput scales with N.
*(RAID-4는 모든 small write가 단일 parity 디스크를 거쳐서 N과 무관하게 병목. RAID-5는 parity를 돌려 배치해 N에 비례.)*
</details>

**Q5. (Latency vs throughput)** In RAID-5, one small write needs 4 physical I/Os. Why is the latency 2D, not 4D?
*(RAID-5 small write는 물리 I/O가 4개인데 latency가 왜 4D가 아니라 2D인가?)*

<details>
<summary>▶ 답</summary>

The two reads (old data, old parity) are on different disks, so they run **in parallel** (D). Then the two writes run in parallel (D). So latency = 2D = 16 ms. But throughput counts the total disk work: 4 I/Os per logical write, so throughput = N·R/4.
*(read 2개는 서로 다른 디스크라 병렬(D), write 2개도 병렬(D) → 2D. 처리량은 총 I/O 개수 4개로 나눔.)*
</details>

**Q6. (Mapping)** RAID-0 with **4 disks** and **chunk size 2**. Where is logical block **13**?
*(디스크 4개, chunk 2인 RAID-0에서 논리 블록 13의 위치는?)*

<details>
<summary>▶ 답</summary>

```
Disk   = (13 / 2) % 4 = 6 % 4 = 2
Offset = (13 / (2×4)) × 2 + (13 % 2) = 1 × 2 + 1 = 3
→ Disk 2, offset 3
검산: D0: 0,1 | 8,9   D1: 2,3 | 10,11   D2: 4,5 | 12,13   D3: 6,7 | 14,15  ✓
```
</details>

**Q7. (XOR)** RAID-4: D0 = 0110, D1 = 1011, D2 = 0101. (a) Compute P. (b) Disk 2 fails; recover D2. (c) D0 is updated to 1111; compute P_new with subtractive parity.
*((a) parity 계산 (b) Disk 2 복구 (c) D0이 1111로 바뀔 때 subtractive parity로 새 parity)*

<details>
<summary>▶ 답</summary>

```
(a) P     = 0110 ⊕ 1011 ⊕ 0101 = 1101 ⊕ 0101 = 1000
(b) D2    = D0 ⊕ D1 ⊕ P = 0110 ⊕ 1011 ⊕ 1000 = 1101 ⊕ 1000 = 0101  ✓
(c) P_new = P_old ⊕ D0_old ⊕ D0_new = 1000 ⊕ 0110 ⊕ 1111 = 1110 ⊕ 1111 = 0001
    검산: 1111 ⊕ 1011 ⊕ 0101 = 0100 ⊕ 0101 = 0001  ✓
```
</details>

**Q8.** Why does RAID-6 use Reed-Solomon for the second parity instead of XOR?
*(RAID-6은 왜 두 번째 parity에 XOR 대신 Reed-Solomon을 쓰나?)*

<details>
<summary>▶ 답</summary>

To recover two failed disks, we need two independent equations. If both parities use XOR, they give the same equation, so we cannot solve for two unknowns. Reed-Solomon gives a linearly independent second equation.
*(디스크 2개를 복구하려면 독립된 방정식 2개가 필요하다. 둘 다 XOR이면 같은 식이라 못 푼다.)*
</details>

**Q9.** Explain the consistent-update problem in RAID-1 and how hardware RAID solves it.
*(RAID-1의 consistent-update 문제와 H/W RAID의 해결법)*

<details>
<summary>▶ 답</summary>

If a crash happens after writing only one of the two mirror disks, the copies are different and we cannot know which is correct. Hardware RAID logs the in-progress write in **NVRAM** and replays it after reboot. Software RAID has no NVRAM.
*(한쪽 디스크만 쓰고 crash 나면 두 사본이 달라 어느 쪽이 맞는지 모른다. H/W RAID는 NVRAM에 기록해 두고 재부팅 후 replay한다.)*
</details>

<br/>

---

## 블록 4. SSD 내부 Architecture (20분) ★★

### 4.1 큰 그림 — "SSD is a small computer"

```
Host (CPU, DRAM) ── PCIe / NVMe ──┐
                                   ▼
 ┌──────────────── SSD ─────────────────────────────────────┐
 │  SSD Controller SoC (hardware)                            │
 │   ├ Host interface (PCIe / SATA·SAS / eMMC·UFS)            │
 │   ├ CPU (ARM cores)  ← Firmware 실행: HIL → FTL → FIL       │
 │   ├ DDR controller ── DRAM (mapping table, write buffer)  │
 │   ├ ECC, XOR, Encrypt engine, Power mgmt                  │
 │   └ NAND interface ─┬─ CH0 ─ [Chip][Chip]   (way = 2)      │
 │                     ├─ CH1 ─ [Chip][Chip]                  │
 │                     ├─ CH2 ─ [Chip][Chip]                  │
 │                     └─ CH3 ─ [Chip][Chip]   (channel = 4)  │
 └───────────────────────────────────────────────────────────┘
계층: Channel > Way > Chip(package) > Die > Plane > Block > Page
```

| 구성 | English | 한국어 |
|---|---|---|
| **Controller SoC** | hardware for low-level data processing | 저수준 처리 하드웨어 (호스트 인터페이스, ECC, NAND 인터페이스, CPU 등이 칩 하나에) |
| **Firmware** | software (C) running on the SSD's CPU; FTL, GC, wear leveling, bad block mgmt | SSD 내부 CPU에서 도는 소프트웨어 |
| **DRAM** | holds the mapping table and write buffer | 매핑 테이블·쓰기 버퍼 |
| **Channel** | an independent bus between the controller and NAND chips → channels transfer **at the same time** | 독립 버스, 채널끼리 동시 전송 |
| **Way** | the number of chips **sharing one channel** → while one chip programs, the controller sends data to another (**interleaving**) | 한 채널을 공유하는 chip 수 |
| **Die** | the smallest independent unit of NAND | 독립 동작 최소 단위 |
| **Flash controller = data mover** | NAND → SSD DRAM → (DMA) → host memory | 데이터를 옮기는 역할 |

**Firmware 3계층 (read path)**

| 계층 | 역할 |
|---|---|
| **HIL** (Host Interface Layer) | fetches requests from NVMe **SQ/CQ** |
| **FTL** (Flash Translation Layer) | **logical → physical address translation**, write buffering, page allocation, GC, wear leveling |
| **FIL** (Flash Interface Layer) | converts to real NAND commands |

```
App → System call → File system → Block layer → NVMe driver → [SSD] HIL → FTL → FIL → NAND
```

### 4.2 Interface vs Protocol

- **Interface** = physical/electrical connection (SATA, SAS, **PCIe**) / **Protocol** = command rules (AHCI, SCSI, **NVMe**)
- SATA·SAS = interface **and** protocol / **PCIe = interface, NVMe = protocol on top of PCIe**

| | SATA | SAS | NVMe (PCIe) |
|---|---|---|---|
| 대상 | Consumer | Enterprise | 둘 다 |
| Duplex | Half | Full | Full |
| Queue | **1 × depth 32** | ~254 | **64K × depth 64K** |

- Why many queues? → to use the SSD's **internal parallelism**; usually **one SQ/CQ pair per CPU core** → no lock contention
- **PCH**: SATA 장치는 PCH 경유 (DMI 대역폭을 LAN·USB와 공유) / NVMe는 **CPU PCIe lane 직결**
- **eMMC (parallel, half-duplex) < UFS (serial, full-duplex, multi-lane, CQ)**: parallel은 고속에서 **skew, crosstalk** 문제
- **GPUDirect Storage**: **data path**는 SSD → GPU 직접, **control path**는 여전히 CPU

**대역폭 계산**
```
SATA 3        = 6 Gbps × 8/10 ÷ 8 = 600 MB/s
PCIe          = GT/s × 128/130 × lanes ÷ 8
PCIe Gen3 x4  = 8 × 128/130 × 4 ÷ 8 ≈ 3.94 GB/s
PCIe Gen4 x4  = 16 × 128/130 × 4 ÷ 8 ≈ 7.88 GB/s
Memory BW     = per-channel BW × channels (예: 50 GB/s × 12 = 600 GB/s)
```

### 4.3 NAND 기초

| 동작 | 방법 | 결과 | 단위 | 지연 |
|---|---|---|---|---|
| **Read** | sense whether current flows | — | **Page** | 수십 µs (가장 빠름) |
| **Program** | high voltage on control gate → electrons tunnel into floating gate | Vth↑ → **0** | **Page** | 수백 µs |
| **Erase** | high voltage on substrate → electrons removed | Vth↓ → **1** | **Block** | **수 ms** (HDD 수준) |

- **Asymmetry ★**: **1 → 0 (program) per page, selectively** / **0 → 1 (erase) only per whole block**
- 판단법: **0→1로 바뀌는 비트가 하나라도 있으면 erase 필요** (F→5 가능, 5→F 불가)
- **Erase-before-write**: a written page cannot be overwritten; the whole block must be erased first.
- Page 16 KB, Block = 256 pages = **4 MB** / DRAM은 **byte-addressable**, SSD는 아님
- **SLC → QLC** (1→4 bit/cell, 2→16 states): capacity↑ cost↓ / **speed↓, errors↑, P/E cycles↓** (margin between states gets narrow)
- **P/E 수명이 있는 이유**: electrons damage the **tunnel oxide** each time (aging)
- **Floating gate**: non-volatile. DRAM은 capacitor라 **64 ms마다 refresh**

| | SLC | MLC | TLC | QLC |
|---|---|---|---|---|
| Page read | 25–50 µs | 50–100 µs | 100–150 µs | |
| Page program | 200–300 µs | 600–800 µs | 800–1200 µs | |
| Block erase | 1.5–2 ms | 2–3 ms | 3–4 ms | |
| P/E (6주차) | ~100,000 | ~3,000 | ~1,000 | ~100–300 |

> 4주차 슬라이드는 P/E를 100K / 10K / 3K / 1K로 제시 → 숫자는 "approximately"를 붙이고, 핵심은 **"bits per cell ↑ → endurance ↓"**

### 4.4 연습 문제

**Q1.** Explain channel and way. How do they create internal parallelism?
*(channel과 way를 설명하고, 내부 병렬성을 어떻게 만드는지 설명하라.)*

<details>
<summary>▶ 답</summary>

A channel is an independent bus between the flash controller and NAND chips, so different channels transfer data at the same time. A way is the number of chips sharing one channel; while one chip is busy programming or reading internally, the controller uses the bus for another chip (interleaving). With 4 channels × 2 ways, 8 chips can work at the same time.
*(channel은 독립 버스라 동시에 전송, way는 한 채널을 공유하는 chip 수로 한 chip이 내부 작업 중일 때 다른 chip에 전송. 4 × 2면 8개 chip이 동시에 일함.)*
</details>

**Q2. (응용 계산)** Each chip programs a 16 KB page in 400 µs. Ignoring bus limits, what is the write bandwidth of (a) one chip, (b) 4 channels × 2 ways?
*(chip 하나가 16 KB page를 400 µs에 program. 버스 한계를 무시하면 (a) chip 1개 (b) 4 channel × 2 way의 쓰기 대역폭은?)*

<details>
<summary>▶ 답</summary>

```
(a) 16 KB / 400 µs = 40 KB/ms = 40 MB/s   (1 MB = 1000 KB 기준)
(b) 8 chips × 40 MB/s = 320 MB/s
```
One NAND chip is slow, but parallelism across channels and ways multiplies the bandwidth.
*(chip 하나는 느리지만 channel × way 병렬로 대역폭이 곱해진다.)*

> 강의는 "병렬성으로 대역폭이 커진다"는 개념까지만 다뤘고, 이 계산은 개념 확인용입니다.
</details>

**Q3.** Name the three firmware layers of an SSD and their roles.
*(SSD 펌웨어 3계층과 역할)*

<details>
<summary>▶ 답</summary>

HIL (Host Interface Layer) fetches requests from the NVMe submission/completion queues. FTL (Flash Translation Layer) translates logical addresses to physical addresses and does write buffering, page allocation, garbage collection, and wear leveling. FIL (Flash Interface Layer) converts them into real NAND commands.
</details>

**Q4.** Why did SSDs move from SATA to NVMe over PCIe?
*(SSD가 SATA에서 PCIe 기반 NVMe로 넘어간 이유)*

<details>
<summary>▶ 답</summary>

The internal bandwidth of an SSD (many NAND dies in parallel) exceeds the SATA limit of 600 MB/s. Also, SATA (AHCI) has only one queue with depth 32, which cannot use the internal parallelism. NVMe over PCIe has many lanes and up to 64K queues.
*(내부 대역폭이 SATA 600 MB/s를 넘고, AHCI는 queue 1개 × 32라 병렬성을 못 씀.)*
</details>

**Q5.** Can a page storing 0xC be changed to 0x8 without erase? What about 0x9 → 0xB?
*(0xC → 0x8은 erase 없이 가능? 0x9 → 0xB는?)*

<details>
<summary>▶ 답</summary>

```
C = 1100 → 8 = 1000 : only 1→0 → program only, no erase
9 = 1001 → B = 1011 : one bit 0→1  → erase needed
```
</details>

**Q6.** Why does an SSD read go through the SSD's internal DRAM?
*(SSD 읽기는 왜 내부 DRAM을 거치나?)*

<details>
<summary>▶ 답</summary>

The flash controller is a data mover: it reads a page from a NAND die into the SSD's internal DRAM first, and then transfers it to host memory by DMA over PCIe/NVMe. (HDDs also use their internal DRAM buffer in the same way.)
*(flash controller가 NAND page를 내부 DRAM에 올린 뒤 DMA로 호스트 메모리에 보낸다.)*
</details>

<br/>

---

## 블록 5. FTL — 주소 변환 "제대로 이해하기" (45분) ★★★★

> 교수님 강조 포인트. 이 블록은 **개념 → 동작 규칙 → 손으로 trace → 계산 → 영어 서술** 순서로 구성했습니다. **5.5와 5.6 trace는 반드시 손으로 직접** 따라가세요.

### 5.1 왜 주소 변환이 필요한가 — 3단 논리 ★

```
① Mismatch    FS는 read sector / write sector(덮어쓰기)만 앎  ↔  Flash는 read / program / erase, 덮어쓰기 없음
② Naive (RMW) 그대로 덮어쓰면 block 전체 read → erase → program  → 느림 + write amplification
③ Solution    Copy-on-Write(out-of-place)로 빈 page에 쓰고, mapping table로 logical → physical 변환 = FTL
```

> **English key sentences**
> 1. *"The file system assumes in-place overwrite, but flash cannot overwrite a page without erasing the whole block."*
>    (FS는 제자리 덮어쓰기를 가정하지만 flash는 block 전체를 지우지 않고는 page를 덮어쓸 수 없다.)
> 2. *"The FTL writes new data to a free page (out-of-place update) and updates the mapping table from the logical address to the new physical address."*
>    (FTL은 새 데이터를 빈 page에 쓰고, mapping table에서 논리 주소가 새 물리 주소를 가리키도록 갱신한다.)
> 3. *"Because of the mapping table, the SSD looks like a normal disk to the file system."*
>    (mapping table 덕분에 FS 입장에서 SSD는 그냥 디스크처럼 보인다.)

**왜 FS에 새 주소를 알려주지 않나?** → 디바이스가 FS의 파일 관리에 끼어들게 되어 **계층 분리(layering)가 깨짐**. 그래서 SSD **내부**에 mapping table을 둔다.

### 5.2 Naive 방식: Read-Modify-Write (RMW) 계산

Page 1개 수정, Block = 4 pages, MLC (read 100 µs, program 800 µs, erase 3 ms):

```
1. Read    4 pages = 4 × 100 µs = 0.4 ms
2. Modify  in DRAM ≈ 0
3. Erase   1 block = 3 ms
4. Program 4 pages = 4 × 800 µs = 3.2 ms
Total = 6.6 ms   ← HDD 랜덤 쓰기 수준. SSD 장점이 사라짐
WAF   = 4 pages written / 1 page requested = 4
```

- 실제 block은 수백 page → **16 KB page 하나 쓰려다 4 MB block 전체**를 read + erase + program

```
WAF (Write Amplification Factor) = data written to NAND / data written by host
```
- WAF ↑ → **slower + P/E cycles consumed faster (shorter lifetime)**. 원인: RMW, **GC의 valid page 복사**

### 5.3 용어: LPN / PPN / Mapping table

| 용어 | 뜻 |
|---|---|
| **Logical page number (LPN)** / logical address | FS·호스트가 보는 주소 (강의 예: 100, 101, 2000, 2001) |
| **Physical page number (PPN)** / physical address | NAND의 실제 page 위치 (강의 예: 00 ~ 11) |
| **Mapping table** | LPN → PPN 표. SSD 내부 **DRAM/SRAM**에 있음. **잃어버리면 데이터 위치를 모름** |
| **Write pointer (다음 빈 page)** | 새 쓰기가 들어갈 다음 free page |

**Static vs Dynamic mapping** (3주차 RAID와 연결)

| | Static mapping | Dynamic mapping |
|---|---|---|
| 방식 | 수식 계산 (`A % N`) | 자료구조 (table) |
| 예 | **RAID** | **SSD FTL**, page table |
| 장점 | 빠름, 하드웨어 구현 쉬움 | **유연** — 데이터를 아무 곳에나 둘 수 있음 |
| 단점 | 위치가 고정됨 | **메모리·CPU 소모** |

> FTL이 dynamic이어야 하는 이유: COW는 **같은 논리 주소의 물리 위치가 쓸 때마다 바뀌기** 때문에 수식으로는 표현할 수 없다.

### 5.4 FTL 동작 규칙 (이 규칙대로 trace 문제를 풉니다)

```
READ(LPN):
    PPN = table[LPN]
    return flash_read(PPN)

WRITE(LPN, data):
    new = next free page (write pointer)          # 빈 page에 순서대로
    flash_program(new, data)                      # 1→0 only, erase 불필요
    if LPN in table: state[table[LPN]] = INVALID  # 옛 page는 쓰레기
    table[LPN] = new; state[new] = VALID

TRIM(LPN):
    state[table[LPN]] = INVALID; delete table[LPN]

GC (free block 부족 시):
    victim = pick block (Greedy / Cost-Benefit)
    for each VALID page p in victim:
        copy p to next free page; update table   # 추가 NAND 쓰기 = write amplification
    erase(victim) → all pages FREE
```

**Page 상태 전이**

```
          program
  free ───────────▶ valid
   ▲                  │
   │ erase (BLOCK)    │ overwrite elsewhere (relocate) / TRIM
   │                  ▼
   └────────────── invalid
```
- **invalid → free는 block 단위 erase로만** (page 단위 불가) ← T/F 단골

### 5.5 강의 예제 Trace ★★ — "Writes on an SSD" + GC

조건: Page 4 KiB, **Block = 4 pages**, Block 0~2 (PPN 00~11). 처음엔 Block 0만 erase된 상태.

**Step 1.** `Write(100)=a1, Write(101)=a2, Write(2000)=b1, Write(2001)=b2`

```
Table:   100→00   101→01   2000→02   2001→03
Block:   |---- Block 0 ----|---- Block 1 ----|---- Block 2 ----|
PPN:      00  01  02  03    04  05  06  07    08  09  10  11
Content:  a1  a2  b1  b2
State:    V   V   V   V     -   -   -   -     -   -   -   -     (- = 아직 erase 안 된 block)
```
- 논리 번호가 100이든 2000이든 **물리적으로는 빈 page에 순서대로** → **random write가 sequential physical write로 바뀜**

**Step 2.** `Write(100)=c1, Write(101)=c2` (업데이트) — Block 1 erase 후 사용

```
Table:   100→04   101→05   2000→02   2001→03
PPN:      00  01  02  03    04  05  06  07
Content:  a1  a2  b1  b2    c1  c2
State:    I   I   V   V     V   V   E   E
          └garbage┘
```
- 00, 01은 **아무도 가리키지 않음 → invalid (garbage)**. 덮어쓴 게 아니라 **새 곳에 쓰고 표만 바꿈**

**Step 3.** GC — victim = Block 0 (valid 2개: b1, b2)

```
① Victim 선택: Block 0
② Valid page 읽기: b1(02), b2(03)
③ 빈 page에 쓰기: b1 → 06, b2 → 07     Table: 2000→06, 2001→07
④ Block 0 erase → 00~03 = free

Table:   100→04   101→05   2000→06   2001→07
PPN:      00  01  02  03    04  05  06  07
Content:                    c1  c2  b1  b2
State:    E   E   E   E     V   V   V   V
```

**이 예제의 WAF (응용 계산)**: host가 쓴 page = 6 (a1, a2, b1, b2, c1, c2), NAND에 쓴 page = 6 + GC 복사 2 = 8 → **WAF = 8/6 ≈ 1.33**

### 5.6 직접 해보는 Trace 문제 ★★★

**Q1.** An SSD has **3 blocks** (Block 0, 1, 2), **4 pages per block** (PPN 0–11). All blocks are erased. The FTL uses **page-level mapping** and writes to the next free page in order (PPN 0, 1, 2, ...). The host sends:
*(블록 3개, block당 4 page, 모두 erase 상태. page 단위 매핑, 빈 page에 순서대로 쓴다. 호스트 요청:)*

```
W(0)=A,  W(1)=B,  W(2)=C,  W(0)=A',  W(3)=D,  W(1)=B',  W(4)=E,  W(0)=A''
```

(a) Show the final mapping table. *(최종 mapping table)*
(b) Show the state (Valid / Invalid / Free) of each physical page. *(각 물리 page 상태)*
(c) GC runs now with the **Greedy** policy. Which block is the victim? Show the result. *(Greedy GC 결과)*
(d) Calculate the WAF including GC. *(GC 포함 WAF)*
(e) If the host had sent **TRIM(2)** before GC, what changes? *(GC 전에 TRIM(2)가 왔다면?)*

<details>
<summary>▶ 답</summary>

**진행 과정**

| 요청 | 쓰는 PPN | Table 변화 | Invalid 되는 PPN |
|---|---|---|---|
| W(0)=A | 0 | 0→0 | — |
| W(1)=B | 1 | 1→1 | — |
| W(2)=C | 2 | 2→2 | — |
| W(0)=A' | 3 | 0→3 | **0** (A) |
| W(3)=D | 4 | 3→4 | — |
| W(1)=B' | 5 | 1→5 | **1** (B) |
| W(4)=E | 6 | 4→6 | — |
| W(0)=A'' | 7 | 0→7 | **3** (A') |

**(a) Final mapping table**
```
LPN:  0   1   2   3   4
PPN:  7   5   2   4   6
```

**(b) Page states**
```
           |------ Block 0 ------|------ Block 1 ------|------ Block 2 ------|
PPN:          0    1    2    3      4    5    6    7      8    9   10   11
Content:      A    B    C    A'     D    B'   E    A''
State:        I    I    V    I      V    V    V    V      F    F    F    F
```
Block 0: valid 1 / Block 1: valid 4 / Block 2: free

**(c) Greedy GC** → victim = **Block 0** (fewest valid pages: 1)
```
① Victim = Block 0
② Read valid page: C (PPN 2)
③ Write C to PPN 8 → table: 2→8
④ Erase Block 0 → PPN 0–3 free

Table:  0→7  1→5  2→8  3→4  4→6
State:  Block 0 = F F F F | Block 1 = V V V V | Block 2 = V F F F
```

**(d) WAF**
```
Host writes = 8 pages
NAND writes = 8 + 1 (GC copy of C) = 9 pages
WAF = 9 / 8 = 1.125
```

**(e) TRIM(2) before GC**: PPN 2 becomes **invalid**, so Block 0 has **0 valid pages**. GC only needs to **erase** Block 0 without copying → NAND writes = 8, **WAF = 1.0**. TRIM avoids copying useless data.
*(TRIM(2)가 오면 PPN 2가 invalid가 되어 Block 0에 valid page가 0개. 복사 없이 erase만 하면 되므로 WAF = 1.0. TRIM은 쓸모없는 데이터 복사를 막는다.)*
</details>

**Q2.** In Q1, after (c), the host sends `R(2)`. Which physical page is read? Why does the FS not need to know?
*(Q1 (c) 이후 R(2)가 오면 어느 물리 page를 읽나? FS는 왜 몰라도 되나?)*

<details>
<summary>▶ 답</summary>

The FTL looks up the mapping table: LPN 2 → **PPN 8**, and reads PPN 8. The FS still uses logical address 2; only the FTL knows that the physical location moved from PPN 2 to PPN 8 during GC. This keeps the layers separated.
*(mapping table에서 LPN 2 → PPN 8을 찾아 읽는다. FS는 여전히 논리 주소 2만 쓰고, GC 때 물리 위치가 바뀐 건 FTL만 안다.)*
</details>

**Q3.** Why must at least one free block always be kept for GC?
*(왜 GC를 위해 빈 block이 최소 하나는 항상 있어야 하나?)*

<details>
<summary>▶ 답</summary>

GC must copy the valid pages of the victim block to free pages **before** erasing the victim. If there is no free block, there is nowhere to copy the valid data, so GC cannot run.
*(GC는 victim을 지우기 전에 valid page를 빈 곳에 복사해야 한다. 빈 block이 없으면 복사할 곳이 없어 GC를 못 한다.)*
</details>

### 5.7 Mapping table 크기 & 매핑 단위 ★

**Page-level mapping 계산**
```
Entries = SSD capacity / page size
Size    = entries × entry size

1 TB, 4 KB page, 4 B entry:  2⁴⁰ / 2¹² = 2²⁸ entries × 4 B = 2³⁰ B = 1 GB
→ "SSD 1 TB당 DRAM 1 GB" 경험칙
```

**Q4.** A **4 TB** SSD uses page-level mapping with **16 KB** pages and **4 B** entries. How much DRAM is needed?
*(4 TB SSD, 16 KB page, 4 B entry. 필요한 DRAM은?)*

<details>
<summary>▶ 답</summary>

```
Entries = 4 TB / 16 KB = 2⁴² / 2¹⁴ = 2²⁸ ≈ 268 million
Size    = 2²⁸ × 4 B = 2³⁰ B = 1 GB
```
Larger pages reduce the number of entries and thus the table size. (4 KB page라면 2³⁰ entries × 4 B = 4 GB)
*(page가 클수록 엔트리 수가 줄어 표가 작아진다.)*
</details>

**표를 줄이는 방법** — 강의에서는 이름만 언급 (Block / Hybrid / DFTL). 아래는 개념 이해용 보충입니다.

| 방식 | 아이디어 | 장점 | 단점 |
|---|---|---|---|
| **Page-level** | page마다 엔트리 1개 | 아무 page에나 쓸 수 있음 → 유연, WAF 낮음 | **표가 큼** (1 TB당 ~1 GB) |
| **Block-level** | block마다 엔트리 1개, block 안의 page 위치(offset)는 고정 | 표가 매우 작음 (1 TB / 4 MB = 2¹⁸ entries × 4 B = 1 MB) | page 하나만 바꿔도 같은 offset을 맞추려고 **block을 통째로 옮겨야** 함 → RMW와 비슷한 비용 |
| **Hybrid** | 대부분은 block mapping, 일부 로그용 block만 page mapping | 둘의 절충 | 구현 복잡 |
| **DFTL** | 전체 표는 flash에 두고, **자주 쓰는 매핑만 DRAM에 캐싱** | DRAM 절약 | 캐시 miss 시 flash에서 매핑을 읽어야 함 |

- 관련: **UFS는 DRAM-less** → 매핑 테이블 DRAM이 없어 생기는 손실을 **HPB (Host Performance Booster)** 로 호스트(AP)의 DRAM을 빌려 보완 (4주차)

### 5.8 COW의 대가 3가지 & TRIM

COW avoids RMW, but creates new costs:
1. **Garbage** pages are created → **garbage collection** is needed *(쓰레기 → GC 필요)*
2. **Page states** must be managed (which pages are invalid) *(상태 관리)*
3. The **mapping table** must be kept in DRAM and **never lost** *(매핑 테이블 관리)*

**TRIM**: When a file is deleted, the FS only updates its metadata, so the SSD still thinks the pages are **valid**. TRIM tells the SSD which logical addresses are no longer used → pages become **invalid** → GC does not copy them. **HDDs do not need TRIM** because they can overwrite in place.
*(파일을 지워도 FS 메타데이터만 바뀌어 SSD는 여전히 valid로 안다. TRIM이 이를 알려 GC가 쓸데없이 복사하지 않게 한다. HDD는 덮어쓰기가 되니 필요 없다.)*

### 5.9 Garbage Collection ★★

**GC cost = amount of valid data to copy.** All invalid → just one erase (best).

```
GC time (victim with k valid pages) = k × (read + program) + erase
예) MLC, k = 1:  1 × (100 + 800) µs + 3 ms = 3.9 ms
    MLC, k = 0:  3 ms (erase only)
```

| 정책 | 기준 | 특징 |
|---|---|---|
| **Greedy** | **fewest valid pages** (most invalid) | 당장 복사 비용 최소. 단점: 곧 바뀔 **hot** data를 복사할 수 있음 |
| **Cost-Benefit** | highest `(1 − u) × age / 2u` | **age**를 고려 → 오래된 **cold** block 우선 |

```
score = benefit / cost = (1 − u) × age / 2u
u = valid ratio (0~1),  1 − u = reclaimed free space,  2u = read u + write u,  age = time since last modification
```

| 줄이는 방법 | 설명 |
|---|---|
| **Over-provisioning** | NAND를 보이는 용량보다 더 탑재 (예: 1 TB NAND, 960 GB 노출) → 더 오래 기다릴 수 있어 victim의 valid page↓ → GC 비용↓, WAF↓ |
| **Background GC** | idle 때 실행 → 사용자 I/O 영향↓ |
| **Reactive GC** | free block이 threshold 아래로 떨어지면 실행 → 사용자 요청 중이면 **latency spike** |
| **Proactive GC** | idle을 **예측**해 미리 실행. independent variables (inter-arrival time, free blocks, write pattern) → dependent variable (when to GC). ML 적용 가능 |

**Q5. (Cost-Benefit)** Block X: u = 0.2, age = 10. Block Y: u = 0.5, age = 50. Which does Greedy pick? Which does Cost-Benefit pick?
*(Greedy와 Cost-Benefit은 각각 어느 block을 고르나?)*

<details>
<summary>▶ 답</summary>

```
Greedy:       fewest valid → X (u = 0.2)
Cost-Benefit: X = (1 − 0.2) × 10 / (2 × 0.2) = 8 / 0.4 = 20
              Y = (1 − 0.5) × 50 / (2 × 0.5) = 25 / 1.0 = 25
              → Y (higher score)
```
Y has more valid data, but it is old (cold), so its data will probably not change. X is young (hot); if we wait, more of its pages may become invalid for free.
*(Y는 valid가 많지만 오래돼서(cold) 앞으로도 안 바뀔 가능성이 크다. X는 최근에 쓴 hot block이라 기다리면 공짜로 더 invalid가 된다.)*
</details>

**Q6. (GC cost)** MLC NAND: read 100 µs, program 800 µs, erase 3 ms, 4 pages per block. Compare the GC time of a victim with 3 valid pages and a victim with 0 valid pages.
*(valid 3개인 victim과 0개인 victim의 GC 시간 비교)*

<details>
<summary>▶ 답</summary>

```
3 valid: 3 × (100 + 800) µs + 3 ms = 2.7 + 3 = 5.7 ms   (and 3 extra NAND writes → WAF↑)
0 valid: 3 ms (erase only)
```
This is why GC should wait until a block is mostly invalid, and why over-provisioning and TRIM help.
</details>

### 5.10 Wear Leveling · Bad Block · Read Disturb

| 기법 | English | 한국어 |
|---|---|---|
| **Dynamic WL** | place new writes on **less-worn free blocks** | 새 쓰기를 덜 닳은 빈 block에 |
| **Static WL** | occasionally **move cold data** so its less-worn block joins the write rotation | 안 바뀌는 cold data를 옮겨 그 block도 쓰게 함 |
| **Bad block mgmt** | factory + runtime bad blocks → mark in **OOB area**, redirect to **spare blocks** | OOB에 표시, spare block으로 대체 |
| **Read disturb** | **reading** a block many times disturbs nearby cells → errors | 읽기만 해도 에러 |
| **Data refresh** | periodically rewrite weak blocks to new blocks | 주기적으로 새 block에 다시 씀 |

- **FTL 3대 기능**: **address translation, garbage collection, wear leveling** (+ bad block management, data refresh)

### 5.11 영어 서술 연습

**Q7.** Explain how the FTL avoids read-modify-write. What are the costs?
*(FTL이 RMW를 피하는 방법과 그 대가)*

<details>
<summary>▶ 답</summary>

The FTL uses copy-on-write (out-of-place update). It writes new data to a free page and updates the mapping table so that the logical address points to the new physical page. The old page becomes invalid. Costs: (1) garbage is created, so GC is needed; (2) page states must be managed; (3) the mapping table needs DRAM and must never be lost.
*(새 데이터를 빈 page에 쓰고 mapping table을 갱신, 옛 page는 invalid. 대가: GC 필요, 상태 관리, 매핑 테이블 DRAM 필요·유실 불가.)*
</details>

**Q8.** Why does the FTL use dynamic mapping while RAID uses static mapping?
*(FTL은 dynamic, RAID는 static mapping을 쓰는 이유)*

<details>
<summary>▶ 답</summary>

In RAID, a logical block always stays at the same physical place, so a simple formula (A % N) is enough and is fast in hardware. In an SSD, out-of-place updates move the physical location of a logical page on every write, so the FTL must remember it in a table (dynamic mapping).
*(RAID는 논리 블록의 물리 위치가 고정이라 수식으로 충분. SSD는 쓸 때마다 위치가 바뀌어 표로 기억해야 한다.)*
</details>

**Q9.** How does a page-mapped FTL turn random writes into sequential writes?
*(page 매핑 FTL은 어떻게 랜덤 쓰기를 순차 쓰기로 바꾸나?)*

<details>
<summary>▶ 답</summary>

No matter what the logical address is (e.g., 100 or 2000), the FTL writes the data to the next free page in order and only updates the mapping table. So random logical writes become sequential physical writes.
*(논리 주소와 상관없이 다음 빈 page에 순서대로 쓰고 표만 갱신하므로, 논리적 랜덤 쓰기가 물리적 순차 쓰기가 된다.)*
</details>

**Q10.** What is write amplification, and what are its two main causes?
*(write amplification의 정의와 두 가지 주요 원인)*

<details>
<summary>▶ 답</summary>

Write amplification means the SSD writes more data to NAND than the host requested; WAF = NAND writes / host writes. Main causes: (1) read-modify-write (rewriting a whole block to update one page), (2) copying valid pages during garbage collection. It reduces performance and shortens the SSD lifetime.
</details>

<br/>

---

## 블록 6. 시험 직전 5분 — 백지 체크

| # | 질문 | 답 |
|---|---|---|
| 1 | Avg rotational delay? | ½ × 60,000 / RPM (ms) — 7,200 → 4.2, 10,000 → 3, 15,000 → 2 |
| 2 | T_I/O? / Bandwidth? | seek + rotation + transfer / size ÷ T_I/O |
| 3 | Avg seek distance? | ≈ 1/3 of max |
| 4 | Track skew / ZBR 해결 문제? | settle 중 sector 놓침 / 바깥 track 공간 낭비 |
| 5 | OS가 SPTF 못 하는 이유? | 회전 위치를 모름 → SSTF |
| 6 | RAID-4 / RAID-5 rand write? | R/2 / N·R/4 |
| 7 | RAID-1 rand read / write? | N·R / (N/2)·R |
| 8 | RAID-5 write latency? | 2D (I/O는 4개) |
| 9 | Subtractive parity? | P_new = P_old ⊕ D_old ⊕ D_new |
| 10 | Interface vs Protocol? | PCIe = interface, NVMe = protocol |
| 11 | Program / Erase? | 1→0 per page / 0→1 per block |
| 12 | WAF? | NAND writes / host writes |
| 13 | FTL 3대 기능? | address translation, GC, wear leveling |
| 14 | invalid → free? | block erase로만 |
| 15 | Mapping table 크기? | capacity / page × entry (1 TB당 ~1 GB) |
| 16 | Cost-Benefit? | (1 − u) × age / 2u |

<br/>

---

## 블록 7. True / False 50문항 (25분) ★★

> 시험 형식 그대로 영어 문장입니다. 각 문장을 보고 **T/F + 틀린 단어**를 먼저 말해 본 뒤 펼치세요. ★ 표시는 특히 나오기 쉬운 문항입니다.

### 7.1 HDD (1~17)

| # | Statement | 해석 |
|---|---|---|
| 1 ★ | The average rotational delay of a 7,200 RPM disk is about 8.3 ms. | 7,200 RPM 평균 회전 지연은 약 8.3 ms다. |
| 2 ★ | For random I/O on an HDD, transfer time usually dominates the total I/O time. | HDD 랜덤 I/O에서는 보통 전송 시간이 지배한다. |
| 3 | The average seek distance is about one third of the maximum seek distance. | 평균 seek 거리는 최대의 약 1/3이다. |
| 4 | A short seek to a neighboring track includes a coast phase. | 옆 track으로의 short seek에는 coast 구간이 있다. |
| 5 | The settle phase alone can take 0.5–2 ms. | settle 단계만 0.5~2 ms 걸릴 수 있다. |
| 6 | A disk provides read, write, and delete operations on sectors. | 디스크는 sector에 대해 read, write, delete를 제공한다. |
| 7 ★ | Track skew gives the head enough time to settle when sequential reads move to the next track. | track skew는 순차 읽기가 다음 track으로 넘어갈 때 settle할 시간을 준다. |
| 8 ★ | In zoned bit recording, inner tracks have more sectors than outer tracks. | ZBR에서 안쪽 track이 바깥 track보다 sector가 많다. |
| 9 | With ZBR, outer zones have a higher sequential transfer rate. | ZBR에서 바깥 zone의 순차 전송률이 더 높다. |
| 10 ★ | With immediate reporting, data can be lost on power failure even after the host receives an ACK. | immediate reporting에서는 ACK를 받은 후에도 정전 시 데이터가 손실될 수 있다. |
| 11 ★ | The OS can implement SPTF because it knows the logical block addresses. | OS는 LBA를 알기 때문에 SPTF를 구현할 수 있다. |
| 12 | Both SSTF and SPTF can cause starvation. | SSTF와 SPTF 모두 starvation을 일으킬 수 있다. |
| 13 | SCAN serves middle cylinders more often than edge cylinders. | SCAN은 가운데 cylinder를 가장자리보다 자주 서비스한다. |
| 14 | C-SCAN sweeps in both directions. | C-SCAN은 양방향으로 sweep한다. |
| 15 | TCQ/NCQ allows the disk to reorder multiple outstanding requests. | TCQ/NCQ는 디스크가 여러 대기 요청의 순서를 바꾸게 해 준다. |
| 16 | SMR drives provide fast random writes. | SMR 드라이브는 빠른 랜덤 쓰기를 제공한다. |
| 17 | When bad sectors are remapped to spare sectors, the capacity shown by `df` decreases. | bad sector를 spare로 재매핑하면 `df` 용량이 줄어든다. |

<details>
<summary>▶ 답 (1~17)</summary>

| # | 답 | 이유 |
|---|---|---|
| 1 | **F** | 8.3 ms is one full rotation; the average is half: **≈ 4.2 ms** |
| 2 | **F** | **Seek and rotation** dominate; transfer is µs |
| 3 | **T** | |
| 4 | **F** | Only long seeks have a coast phase |
| 5 | **T** | |
| 6 | **F** | Only **read and write**; no delete |
| 7 | **T** | |
| 8 | **F** | **Outer** tracks have more sectors |
| 9 | **T** | |
| 10 | **T** | |
| 11 | **F** | The OS does not know the **rotational position** → uses SSTF |
| 12 | **T** | |
| 13 | **T** | |
| 14 | **F** | C-SCAN sweeps in **one direction** only |
| 15 | **T** | |
| 16 | **F** | SMR allows only **sequential** writes within a zone |
| 17 | **F** | Remapping happens inside the disk; the `df` size **does not change** |
</details>

### 7.2 RAID (18~29)

| # | Statement | 해석 |
|---|---|---|
| 18 ★ | Adding more disks to RAID-0 reduces the latency of a single request. | RAID-0에 디스크를 추가하면 요청 하나의 latency가 줄어든다. |
| 19 | RAID-0 can tolerate one disk failure. | RAID-0은 디스크 1개 고장을 견딘다. |
| 20 | The random read throughput of RAID-1 is N·R. | RAID-1 랜덤 읽기 처리량은 N·R이다. |
| 21 ★ | The random write throughput of RAID-4 increases as N increases. | RAID-4 랜덤 쓰기 처리량은 N이 늘면 증가한다. |
| 22 | The random write throughput of RAID-5 is N·R/4. | RAID-5 랜덤 쓰기 처리량은 N·R/4다. |
| 23 ★ | The latency of a small write in RAID-5 is 4D because it needs four I/Os. | RAID-5 small write는 I/O 4개가 필요하므로 latency가 4D다. |
| 24 ★ | RAID-5 is better than RAID-1 for random-write-heavy workloads. | 랜덤 쓰기 위주 워크로드에서 RAID-5가 RAID-1보다 낫다. |
| 25 | RAID-6 uses XOR for both of its parities. | RAID-6은 두 parity 모두 XOR을 쓴다. |
| 26 ★ | RAID uses static mapping, while the SSD FTL uses dynamic mapping. | RAID는 static, SSD FTL은 dynamic mapping을 쓴다. |
| 27 | The fail-stop model can detect silent data corruption. | fail-stop 모델은 silent data corruption을 감지할 수 있다. |
| 28 | Software RAID solves the consistent-update problem with NVRAM. | S/W RAID는 NVRAM으로 consistent-update 문제를 해결한다. |
| 29 | Subtractive parity needs four I/Os regardless of N. | subtractive parity는 N과 무관하게 I/O 4개가 필요하다. |

<details>
<summary>▶ 답 (18~29)</summary>

| # | 답 | 이유 |
|---|---|---|
| 18 | **F** | More disks improve **throughput, not latency** (still D) |
| 19 | **F** | RAID-0 tolerates **0** failures |
| 20 | **T** | Any copy can serve a read |
| 21 | **F** | Fixed at **R/2** because of the single parity disk |
| 22 | **T** | |
| 23 | **F** | Latency is **2D** (two parallel reads, then two parallel writes) |
| 24 | **F** | **RAID-1** is 2x better: (N/2)·R vs N·R/4 |
| 25 | **F** | P = XOR, Q = **Reed-Solomon** |
| 26 | **T** | |
| 27 | **F** | Fail-stop only covers whole-disk failures; silent corruption needs **checksums** |
| 28 | **F** | **Hardware** RAID uses NVRAM; software RAID has none |
| 29 | **T** | read D_old, read P_old, write D_new, write P_new |
</details>

### 7.3 SSD Architecture (30~41)

| # | Statement | 해석 |
|---|---|---|
| 30 ★ | NVMe is an interface, and PCIe is the protocol that runs on it. | NVMe는 interface이고 PCIe는 그 위의 protocol이다. |
| 31 | SATA (AHCI) supports up to 64K queues. | SATA(AHCI)는 최대 64K개 queue를 지원한다. |
| 32 | The effective bandwidth of SATA 3 is 600 MB/s because of 8b/10b encoding. | SATA 3 실효 대역폭은 8b/10b 인코딩 때문에 600 MB/s다. |
| 33 | eMMC is faster than UFS because it uses a parallel bus. | eMMC는 parallel bus라서 UFS보다 빠르다. |
| 34 ★ | Programming a NAND cell changes its bit from 0 to 1. | NAND cell을 program하면 비트가 0 → 1로 바뀐다. |
| 35 ★ | Erase is performed in page units. | erase는 page 단위로 수행된다. |
| 36 | Changing 0xA (1010) to 0x8 (1000) requires an erase. | 0xA → 0x8 변경에는 erase가 필요하다. |
| 37 | Among read, program, and erase, erase is the slowest. | read/program/erase 중 erase가 가장 느리다. |
| 38 ★ | As the number of bits per cell increases, the P/E cycle limit increases. | cell당 bit 수가 늘면 P/E cycle 한도가 늘어난다. |
| 39 | A way is the number of chips sharing one channel. | way는 한 channel을 공유하는 chip 수다. |
| 40 | An SSD is byte-addressable like DRAM. | SSD는 DRAM처럼 byte-addressable이다. |
| 41 | With GPUDirect Storage, both the data path and the control path bypass the CPU. | GPUDirect Storage에서는 data path와 control path 모두 CPU를 거치지 않는다. |

<details>
<summary>▶ 답 (30~41)</summary>

| # | 답 | 이유 |
|---|---|---|
| 30 | **F** | Reversed: **PCIe = interface, NVMe = protocol** |
| 31 | **F** | AHCI has **1 queue × depth 32**; NVMe has 64K queues |
| 32 | **T** | 6 Gbps × 8/10 ÷ 8 = 600 MB/s |
| 33 | **F** | UFS (serial) is faster; parallel buses suffer from skew and crosstalk |
| 34 | **F** | Program = **1 → 0**; erase = 0 → 1 |
| 35 | **F** | Erase is per **block** |
| 36 | **F** | Only one bit changes 1 → 0, so **program only** |
| 37 | **T** | ms vs µs |
| 38 | **F** | P/E cycles **decrease** (SLC ~100K → QLC ~100–1K) |
| 39 | **T** | |
| 40 | **F** | SSD is accessed in **pages** |
| 41 | **F** | Only the **data path** is direct; the CPU still issues commands (control path) |
</details>

### 7.4 FTL (42~50)

| # | Statement | 해석 |
|---|---|---|
| 42 | The FTL performs out-of-place updates. | FTL은 out-of-place update를 한다. |
| 43 ★ | An invalid page can be erased individually and become free. | invalid page는 개별적으로 erase되어 free가 될 수 있다. |
| 44 | TRIM is needed for HDDs as well as SSDs. | TRIM은 SSD뿐 아니라 HDD에도 필요하다. |
| 45 ★ | The Greedy GC policy selects the block with the most valid pages. | Greedy GC는 valid page가 가장 많은 block을 고른다. |
| 46 | Over-provisioning increases garbage collection cost. | over-provisioning은 GC 비용을 높인다. |
| 47 ★ | With copy-on-write, the FTL notifies the file system of the new physical address. | COW에서 FTL은 FS에 새 물리 주소를 알려 준다. |
| 48 | GC requires at least one free block to copy valid pages into. | GC는 valid page를 복사할 빈 block이 최소 하나 필요하다. |
| 49 | Read disturb can cause errors even if the block is never written. | read disturb는 block에 쓰기가 없어도 에러를 일으킬 수 있다. |
| 50 ★ | A page-level mapping table for a 1 TB SSD with 4 KB pages and 4 B entries needs about 1 GB of DRAM. | 1 TB, 4 KB page, 4 B entry의 page 매핑 테이블은 약 1 GB DRAM이 필요하다. |

<details>
<summary>▶ 답 (42~50)</summary>

| # | 답 | 이유 |
|---|---|---|
| 42 | **T** | |
| 43 | **F** | invalid → free only by **block** erase |
| 44 | **F** | HDDs can overwrite in place, so TRIM is not needed |
| 45 | **F** | Greedy picks the **fewest** valid pages |
| 46 | **F** | It **reduces** GC cost (more invalid pages per victim) |
| 47 | **F** | The FTL hides it with the **mapping table**; the FS only sees logical addresses |
| 48 | **T** | |
| 49 | **T** | → data refresh |
| 50 | **T** | 2²⁸ × 4 B = 1 GB |
</details>

<br/>

---

> ⚠️ **참고 사항**
> - **"응용"·"보충"으로 표시한 부분**(HDD 평균 응답 시간, track skew sector 수, channel×way 대역폭, Block/Hybrid/DFTL 설명, trace 예제의 WAF)은 강의 공식·개념을 그대로 확장한 연습이며, 슬라이드에 같은 숫자가 있는 것은 아닙니다.
> - P/E cycle과 NAND 지연 숫자는 주차마다 슬라이드 값이 조금씩 다릅니다. **문제에 숫자가 주어지면 그 숫자를 쓰세요.**
> - 단위 가정(1 MB = 1000 KB 또는 1024 KB)은 답안에 한 줄 적어 두면 감점 위험이 줄어듭니다.
