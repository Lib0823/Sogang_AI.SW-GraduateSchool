# AIDS 6주차 — NAND Flash Management: Flash Translation Layer (FTL)

> AI 데이터 시스템 및 인프라 (김영재 교수) · 2026.10.17
> 키워드: SSD Firmware, FTL, Read-Modify-Write, Write Amplification, Copy-on-Write, Address Mapping, Page State, TRIM, Garbage Collection, Cost-Benefit, Over-provisioning, Wear Leveling, Bad Block Management, Read Disturb, Data Refresh

---

## 0. 지난 시간 복습 (Recap)

### 0.1 SSD Controller SoC 구조

- **SSD Controller SoC (System-on-Chip)**: 저수준 데이터 처리를 담당하는 **하드웨어**
  - Host interface(PCIe / SAS·SATA / eMMC·UFS), Encrypt/Decrypt Engine, XOR Engine, ECC, NAND Memory Interface(ONFI/Toggle), DDR Controller, Power Management, CPU/RISC Processor Complex 등이 칩 하나에 들어가 있음
- **Firmware (System FW)**: SSD의 로직·정책·동작을 제어하는 **소프트웨어**
  - C로 작성되어 SoC 안의 CPU 위에서 구동됨. 코드는 NOR Flash에 저장
  - FTL, Bad Block Management, Wear Leveling, Garbage Collection이 펌웨어 기능 → **오늘 강의 범위**
- 즉 SSD 내부는 **CPU + DRAM + 저장장치 + 소프트웨어**로 구성된, 호스트 컴퓨터와 거의 같은 구조를 가진 작은 컴퓨터임
  - 차이점: 호스트처럼 범용 OS가 돌아가는 게 아니라 펌웨어가 메모리 관리까지 직접 처리함

### 0.2 NAND Flash 구성

- 계층: **Channel > Way > (Chip) > Die > Plane > Block > Page**
- **Page**: 읽기/쓰기 단위 (예: 16KB)
- **Block**: 여러 Page가 모인 단위 (예: 4MB). 지우기 단위
- NAND 연산 3가지

| 연산 | 단위 | 설명 |
|---|---|---|
| Read | Page | 데이터 읽기 |
| Program | Page | 데이터 쓰기 (지워진 Page에만 가능) |
| Erase | Block | Block 전체를 지움 |

- **Erase-before-write 제약**: 이미 쓰인 Page는 덮어쓸 수 없음. 다시 쓰려면 그 Page가 속한 **Block 전체를 먼저 Erase**해야 함

| Type | SLC | MLC | TLC |
|---|---|---|---|
| Page Read | 25–50 µs | 50–100 µs | 100–150 µs |
| Page Program | 200–300 µs | 600–800 µs | 800–1200 µs |
| Block Erase | 1.5–2 ms | 2–3 ms | 3–4 ms |

- 참고 스펙: 96-layer QLC NAND → Page 64KB, Block 16~18MB
- 경향: Read < Program < Erase 순으로 느림. 셀당 비트 수가 늘어날수록(SLC→TLC) 전부 느려짐

### 0.3 SSD Firmware 3계층

| 계층 | 역할 |
|---|---|
| **HIL** (Host Interface Layer) | 호스트 요청 수신. NVMe의 Submission Queue(SQ)/Completion Queue(CQ)에서 요청을 가져옴(fetch) |
| **FTL** (Flash Translation Layer) | Write Buffering, Page Allocation, Garbage Collection (오늘 핵심) |
| **FIL** (Flash Interface Layer) | FTL의 상위 연산을 실제 NAND 연산으로 바꿔 NAND에 직접 접근 |

- Write Buffer: 컨트롤러 내부의 DRAM/SRAM

### 0.4 Read 요청의 소프트웨어 경로

```
[App]  Application
[OS]   System Call → File System → Block Layer → NVMe Device Driver
[SSD]  HIL → FTL → FIL → NAND
```

1. Application/OS가 I/O 요청 제출
2. 요청이 SSD로 전달 (HIL)
3. FTL 처리 (논리 주소 → 물리 주소 변환)
4. Flash command가 칩으로 전달
5. Flash read 실행 — NAND Die에서 읽어 SSD 내부 DRAM에 Page를 올림
6. 데이터 전송
7. 완료 통지(Post request completion)
8. 호스트가 완료 처리

---

## 1. 계층별 역할 정리

### 1.1 응용 → 파일 → 블록

- 응용(데이터베이스, VectorDB 등)도 결국 **파일** 위에서 동작함
  - DB = 테이블 = 레코드의 집합. DB는 파일 안의 **레코드 단위**로 데이터를 관리하는 것임
- **File System**: 파일이 **어떤 Block들로 구성돼 있는지** 정보를 갖고 있음
- **Device Driver**: 그 Block을 실제 디바이스로 보내는 역할. 하드웨어와 직접 통신함
  - 새 하드웨어가 나오면 드라이버도 새로 배포해야 디바이스를 쓸 수 있음
  - NVMe SSD는 리눅스 커널에 NVMe 드라이버가 기본 탑재되어 있음

### 1.2 전통적 인터페이스와 Flash의 불일치

- File System은 저장장치를 HDD처럼 본다 — 전통 API는 단 두 개
  - `read sector`
  - `write sector` (같은 자리에 덮어쓰기 가능하다고 가정)
- 그런데 Flash 내부 연산은 **Read / Program / Erase**이고, 덮어쓰기(overwrite)가 없음
- → 호스트의 **Read/Write**를 디바이스 안에서 **Read/Program/Erase**로 변환해 주는 계층이 필요함 = **FTL**
  - Read 요청 → 그대로 Flash Read로 매핑
  - Write 요청 → Write라는 연산이 없으므로 Program + (필요하면) Erase로 매핑

---

## 2. 순진한 방식: Read-Modify-Write (RMW)

### 2.1 전통 API를 Flash에 그대로 얹으면

```python
def read(addr):
    return flash_read(addr)

def write(addr, data):
    block_copy = flash_read(get_block(addr))     # 1. Block 전체를 읽어서
    block_copy = modify(block_copy, data)        # 2. 메모리에서 수정하고
    flash_erase(get_block(addr))                 # 3. Block을 지운 뒤
    flash_program(get_block(addr), block_copy)   # 4. Block 전체를 다시 씀
```

### 2.2 예시: Page 하나(0000 → 0001) 수정하기

상황: 사용자가 문서를 편집하고 Save를 누름 → FS가 Block 0의 첫 Page(`0000`)를 `0001`로 바꾸라고 요청함. Block 하나 = Page 4개.

1. **Read**: Block 0의 Page 4개를 모두 DRAM으로 읽어옴
2. **Modify**: DRAM에서 해당 Page만 `0001`로 수정
3. **Erase**: Flash의 Block 0 전체를 지움 (모든 비트가 1이 됨)
4. **Program**: DRAM의 Page 4개를 Block 0에 다시 씀

### 2.3 지연시간 계산 (보수적인 MLC 기준)

| 단계 | 계산 | 시간 |
|---|---|---|
| 4 Page Read | 4 × 100 µs | 400 µs |
| DRAM에서 수정 | DRAM은 NAND보다 압도적으로 빠름 | ≈ 0 (무시) |
| 1 Block Erase | | 3 ms |
| 4 Page Program | 4 × 800 µs | 3.2 ms |
| **합계** | 0.4 + 3 + 3.2 | **6.6 ms** |

- Page 하나 바꾸는 데 6.6ms → HDD 랜덤 쓰기와 비슷하거나 오히려 더 느릴 수 있음. SSD의 장점이 사라짐

### 2.4 Write Amplification (쓰기 증폭)

- 실제 Block은 Page 4개가 아니라 수백 개임
- **16KB Page 하나 쓰려다가 4MB Block 전체를 read + erase + program** 하게 됨 → 랜덤 쓰기가 극도로 비쌈
- **Write Amplification**: 호스트가 요청한 쓰기 양보다 NAND에 실제로 쓰는 양이 더 커지는 현상

$$
\text{WAF (Write Amplification Factor)} = \frac{\text{NAND에 실제로 쓴 데이터 양}}{\text{호스트가 쓰라고 요청한 데이터 양}}
$$

- 위 예시: 1 Page 요청 → 4 Page 씀 → WAF = 4
- 쓰기가 늘면 → 느려지고 + 셀 수명(P/E cycle)도 그만큼 빨리 소모됨

---

## 3. 해결책: Copy-on-Write + 주소 변환 = FTL

### 3.1 아이디어

- FS와 Flash 사이에 **Copy-on-Write (COW)** 계층을 둠 → RMW 사이클을 피함
- **논리 주소(logical address) → 물리 주소(physical address)** 변환을 수행함
- 이 계층이 **FTL (Flash Translation Layer)**

### 3.2 In-place vs Out-of-place update

| 방식 | 동작 | 사용처 |
|---|---|---|
| **In-place update** | 그 자리에서 값을 덮어씀 | HDD |
| **Out-of-place update** | 비어 있는 다른 자리에 새로 쓰고, 주소를 바꿈 | Flash (COW) |

- 예: A=12, B=5 저장 상태에서 `Write(A, 10)`, `Write(B, 7)`
  - 기존 자리(12, 5)를 지우지 않고, 빈 자리에 10, 7을 새로 씀
  - A, B가 새 위치를 가리키게 바꿈. 옛 데이터(12, 5)는 버려짐 → "Write New, Discard Old"

### 3.3 왜 Mapping Table이 필요한가

- COW로 데이터 위치가 바뀌었는데 FS에 "주소 바뀌었어"라고 알려주면, 디바이스가 FS의 파일 관리에 거꾸로 관여하게 됨 (계층 분리가 깨짐)
- 그래서 디바이스 내부에 **주소 Mapping Table**을 둠
  - FS는 기존과 똑같은 논리 주소만 알고 있음
  - FTL이 Mapping Table을 보고 실제 물리 주소로 변환해 줌
  - → SSD는 바깥에서 보면 **그냥 디스크처럼 보임** ("SSD: looks like disk")

### 3.4 주소 변환 예시

```
Logical:   0     1     2     3    4  5  6  7
           |     |      \     \
Physical: 0001  0010  0011  0000  1001  1111 1111 1111
```

- 논리 1번에 `1101`을 쓰라는 요청이 옴
- 원래 물리 Page(`0010`)는 그대로 두고, 빈 물리 Page에 `1101`을 씀
- Mapping Table에서 논리 1번이 새 물리 Page를 가리키도록 갱신
- 옛 물리 Page(`0010`)는 **나중에 Garbage Collection으로 회수해야 함**
- 주소 변환 정보(Mapping)는 따로 관리되어야 함

### 3.5 COW의 대가 (부가 비용)

COW로 RMW는 피했지만 새로운 일이 생김:

1. **Garbage(쓰레기) 발생** → 누군가 나중에 수거(Garbage Collection)해야 함
2. **상태 관리 추가** → 어느 Page가 쓰레기인지 표시(indicate)해야 함
3. **Mapping Table 관리** → 디바이스 내부 DRAM에서 자료구조가 돌아감. 이걸 잃어버리면 데이터 위치를 알 수 없게 되므로 절대 잃으면 안 됨

### 3.6 Mapping Table은 어디에? → SSD 내부 SRAM / DRAM

- Mapping Table은 SSD 내부 DRAM(또는 SRAM)에 상주하고, FTL은 SSD 내부 CPU 위에서 동작함
- Mapping Table이 커질수록 DRAM도 커져야 함 → 그래서 최적화가 필요함
- 규모 감각 (Page 단위 매핑 기준):
  - 1TB SSD, Page 4KB → 엔트리 수 = 1TB / 4KB ≈ 2.7억 개 (2^28)
  - 엔트리당 4B → 약 **1GB DRAM** 필요 → 흔히 말하는 "SSD 용량 1TB당 DRAM 1GB" 경험칙
- 이를 줄이는 방식으로 Block 단위 매핑, Hybrid 매핑, 자주 쓰는 매핑만 DRAM에 캐싱하는 방식(DFTL 등)이 있음

---

## 4. FTL의 3대 기능과 Page 상태

### 4.1 FTL 기능 (SSD 펌웨어에 구현)

1. **Address Translation** — 논리 → 물리 주소 변환
2. **Garbage Collection** — 쓰레기 Page 회수
3. **Wear-Leveling** — 셀 마모를 고르게 분산

### 4.2 물리 Page의 3가지 상태

```
          program
  free ───────────▶ valid
   ▲                  │
   │ erase            │ relocate or TRIM
   │                  ▼
   └────────────── invalid
```

| 상태 | 의미 | 전이 |
|---|---|---|
| **free** (clean, erased) | 지워져서 쓸 수 있는 상태 | program → valid |
| **valid** | 현재 유효한 데이터가 들어 있음 | 같은 논리 주소에 새 데이터를 다른 곳에 쓰거나(relocate), TRIM을 받으면 → invalid |
| **invalid** | 옛 데이터, 쓰레기 | Block 단위 erase → free |

- invalid → free는 Page 단위가 아니라 **Block 단위 Erase**로만 가능하다는 점이 핵심임

### 4.3 TRIM

- 파일을 삭제해도 FS는 자기 메타데이터만 "비어 있음"으로 바꿀 뿐, SSD는 그 Page가 쓸모없어졌는지 모름 → SSD 입장에선 여전히 valid
- **TRIM**: OS가 SSD에게 "이 논리 주소들은 더 이상 안 쓴다"고 알려주는 명령 → 해당 Page를 invalid로 바꿀 수 있음
- TRIM이 없으면 쓸모없는 데이터까지 GC 때 valid로 취급해 계속 복사하게 됨 → 쓰기 증폭 증가
- HDD는 덮어쓰기가 가능하므로 내용을 미리 지울 필요가 없음. TRIM은 Flash라서 필요한 것임

### 4.4 USB 메모리 이야기

- USB 메모리는 매우 싸게 만든 제품이라 TRIM을 지원하지 않는 경우가 많음
- 빠른 포맷(quick format)은 32GB를 전부 0으로 지우는 게 아니라 FS 메타데이터만 초기화한 것 → 실제 데이터는 그대로 남아 있음 (복구 도구로 살릴 수 있는 이유)
- 저가 제품은 매핑 정보를 안전하게 보존하는 장치도 부족해서, 갑자기 뽑으면 데이터가 날아갈 위험이 있음

---

## 5. 예시: SSD에 쓰기 (Writes on an SSD)

가정: Page = 4KiB, Block = Page 4개. 초기 상태는 모든 Page가 `INVALID(i)`.

요청:
1. Write(100) — 내용 a1
2. Write(101) — 내용 a2
3. Write(2000) — 내용 b1
4. Write(2001) — 내용 b2

※ 100, 101, 2000, 2001은 **논리 Page 번호**, 00~11은 **물리 Page 번호**임

**① Block 0 Erase** → Page 00~03 상태가 E(Erased, 쓰기 가능)

**② 순서대로 Program하고 Mapping 갱신**

```
Table:  100→0                                  (Memory)
Block:  |    0     |    1     |    2      |
Page:   00 01 02 03 04 05 06 07 08 09 10 11    (Flash)
Content: a1
State:  V  E  E  E  i  i  i  i  i  i  i  i
```

**③ 4번 쓰기 후**

```
Table:  100→0  101→1  2000→2  2001→3
Content: a1 a2 b1 b2
State:   V  V  V  V  i  i  i  i  i  i  i  i
```

- 논리 번호가 100이든 2000이든 상관없이 물리적으로는 **빈 Page에 순서대로** 씀 → 랜덤 쓰기가 순차 쓰기로 바뀌는 효과

---

## 6. Garbage Collection (GC)

### 6.1 Garbage가 생기는 과정

- 논리 Page 100, 101을 새 내용 c1, c2로 업데이트
- COW이므로 Block 1의 빈 Page 04, 05에 c1, c2를 씀 → Mapping: 100→4, 101→5

```
Table:  100→4  101→5  2000→2  2001→3
Page:    00 01 02 03 04 05 06 07 08 ...
Content: a1 a2 b1 b2 c1 c2
State:   ✗  ✗  V  V  V  V  E  E  i  ...
         └Garbage┘
```

- Block 0의 Page 00, 01(a1, a2)은 옛 버전 → **Garbage**. 새 쓰기를 위해 회수해야 함
- (슬라이드 그림에 V로 표시돼 있어도 Mapping Table에서 아무도 가리키지 않으면 사실상 쓰레기임)

### 6.2 GC 절차 (4단계)

1. Garbage Page가 하나 이상 있는 **Block을 고름** (Victim Block)
2. 그 Block에서 **살아 있는(valid) Page를 읽음**
3. 살아 있는 Page를 **다른 빈 Page에 씀**
4. **Block 전체를 Erase**해서 향후 쓰기용으로 회수함

위 예시에 적용:
- Victim = Block 0 (00, 01은 쓰레기, 02, 03은 valid)
- b1, b2를 Block 1의 빈 Page 06, 07로 복사 → Mapping: 2000→6, 2001→7
- Block 0 Erase → Page 00~03이 free가 됨

### 6.3 GC 과정 그림 요약

1. 기존 데이터 업데이트 요청
2. 빈 Page를 찾아 새 데이터 저장, 옛 Page는 Invalid
3. 이런 일이 반복되면 Block A, B에 Invalid가 쌓이고 빈 Block이 부족해짐
4. A, B의 Valid Page만 모아서 빈 Block C로 복사
5. Map table 갱신 후 A, B를 Erase → A, B가 다시 빈 Block이 됨

- GC를 하려면 복사 받을 **빈 Block이 최소 하나는 항상 남아 있어야 함** (예: Block 3개 중 하나는 비워둬야 나머지 2개를 정리할 수 있음)

### 6.4 GC는 비싸다

- 살아 있는 데이터를 **읽고 다시 써야** 함 → 이것도 쓰기 증폭 (호스트는 안 쓴 데이터를 SSD가 혼자 다시 씀)
- **이상적인 경우**: Victim Block의 Page가 **전부 invalid** → 복사할 게 없으니 Erase 한 번(약 3ms)으로 끝
- 반대로 valid Page가 많으면 → 그 수만큼 Read + Program 비용(Page당 800µs 등)이 추가됨
- 그래서 **쓰레기를 충분히 쌓아두었다가** 거의 전부 쓰레기가 된 Block을 지우는 게 유리함 → 어떤 Block을 고를지 알고리즘이 필요한 이유

### 6.5 GC 비용과 완화 방법

- 비용은 **옮겨야 할 valid 데이터 양**에 따라 결정됨
- 완화 방법
  - **Over-provisioning**: 사용자에게 보이는 용량보다 Flash를 더 많이 탑재함 (예: 실제 NAND 1TB인데 960GB만 노출). 여유 공간이 많을수록 Victim Block에 쓰레기가 많이 쌓일 때까지 기다릴 수 있어서 GC 비용이 줄어듦
  - **Background GC**: 포그라운드(사용자 I/O) 성능에 영향이 적도록 한가할 때 뒤에서 수행

### 6.6 Victim Block 선택 알고리즘

**Greedy**
- valid Page가 가장 적은(= invalid가 가장 많은) Block을 고름
- 당장 복사 비용이 가장 적음
- 단점: 최근에 쓴 데이터(곧 또 바뀔 hot data)가 있는 Block을 골라버리면, 조금만 기다렸으면 공짜로 쓰레기가 됐을 데이터를 굳이 복사하게 됨

**Cost-Benefit**
- **비용(cost) 대비 이득(benefit)** 을 점수로 계산해서 점수가 가장 좋은 Block을 고름
- 기호: u = Block의 유효 데이터 비율(utilization, 0~1), age = 그 Block이 마지막으로 수정된 뒤 지난 시간

$$
\text{score} = \frac{\text{benefit}}{\text{cost}} = \frac{(1-u)\times \text{age}}{2u}
$$

- 분자 (1−u): 회수할 수 있는 빈 공간 → 클수록 이득
- 분자 age: 오래 안 바뀐 Block(cold)은 남은 valid 데이터도 앞으로 잘 안 바뀔 가능성이 높으니 지금 정리해도 손해가 적음
- 분모 2u: valid 데이터를 읽고(u) 다시 쓰는(u) 비용
- 숫자 예시 (age 동일하게 10이라 가정)
  - Block X: u = 0.2 → (0.8 × 10) / 0.4 = **20**
  - Block Y: u = 0.5 → (0.5 × 10) / 1.0 = **5**
  - → X를 Victim으로 선택

### 6.7 GC는 언제 돌리나

- 기본 원칙: OS의 파일 I/O가 끝나서 **더 이상 Read/Write가 없을 때(idle)** 수행
- **Reactive GC**: 임계치(threshold) 기반 — 빈 Block 수가 일정 이하로 떨어지면 수행. 포그라운드 요청 처리 중에 걸리면 지연이 튐
- **Proactive GC**: 앞으로 idle이 올 것을 예측해서 미리 수행

예측 모델 관점 (Independent / Dependent Variable):
- **Dependent variable (종속 변수)**: 결정하고 싶은 것 → "지금 GC를 할 것인가 / 언제 할 것인가"
- **Independent variable (독립 변수)**: 그 판단에 쓰는 입력 → 요청 간 도착 시간 간격(inter-arrival time), 빈 Block 수, 쓰기 패턴 등
- 독립 변수들을 함수(모델)의 파라미터로 넣어 "지금은 idle 구간인 것 같다"를 예측하고, 그 결과로 종속 변수(GC 시점)를 결정함 → 여기에 ML/AI를 적용할 수 있음

---

## 7. Wear Leveling

### 7.1 NAND Endurance (내구성)

- **Endurance**: NAND 셀이 신뢰성을 잃기 전까지 견딜 수 있는 **Program/Erase 횟수 (P/E cycles)**
- P/E를 할 때마다 셀의 산화막(oxide layer)이 조금씩 손상됨 → 결국 비트 에러나 read disturb 문제로 이어짐

| SLC | MLC | TLC | QLC |
|---|---|---|---|
| ~100,000 | ~3,000 | ~1,000 | ~100–300 |

- 셀당 비트 수가 많아질수록 수명이 급격히 줄어듦
- 특정 Block만 계속 쓰면 그 Block만 먼저 죽음 → 그만큼 용량이 줄고, 심하면 디바이스가 못 쓰게 됨

### 7.2 Wear Leveling

- P/E cycle을 **모든 Block에 고르게** 분산시켜 일부 Block이 조기에 닳지 않게 함
- **Dynamic**: 자주 쓰이는 데이터를 쓸 때, 덜 닳은 빈 Block에 배치함
- **Static**: 거의 안 바뀌는 cold data가 오래 차지하고 있는 Block(덜 닳은 Block)에서 그 데이터를 가끔 다른 곳으로 옮겨줌 → 그 Block도 쓰기에 참여하게 만듦
- 결과: 어떤 Block도 혼자 먼저 수명 한계에 도달하지 않게 됨 (P/E 횟수 분포가 들쭉날쭉 X → 평평하게 O)

---

## 8. Bad Block Management & Data Refresh

### 8.1 Bad Block Management

- 일부 NAND Block은 **제조 시점부터 불량**임
- 다른 Block은 쓰다가 고장남 (**runtime bad block**)
- 컨트롤러가 하는 일
  - Bad Block을 감지하고 **OOB (Out-of-Band) 영역**에 표시함 — OOB는 각 Page에 붙은 메타데이터용 여분 공간 (ECC 등도 여기 저장)
  - 데이터를 **예비(spare) Block**으로 돌림

### 8.2 Read Disturb & Data Refresh

- **Read Disturb**: 한 Block을 반복해서 읽으면 근처 셀에 전압 간섭이 쌓여 에러가 생길 수 있음
  - 쓰지 않고 읽기만 해도 데이터가 망가질 수 있다는 점이 포인트
- **해결: Data Refresh**
  - 취약해진 Block의 데이터를 주기적으로 새 Block에 다시 씀 → 에러가 누적되기 전에 옮김
  - 즉 사용자가 읽기만 한 데이터(예: 사진)도 SSD가 내부적으로 가끔 다른 곳으로 옮김
- 연구 예 (Liao et al., 2022): 읽기 빈도(Hot / Tepid / Cold read)에 따라 데이터를 다른 Block으로 재배치해서 Read Refresh 횟수를 줄이고 read latency를 개선함

### 8.3 정리

- SSD 내부에서는 펌웨어가 **주소 변환, Garbage Collection, Wear Leveling, Bad Block Management, Data Refresh**를 수행하면서 이런 문제들이 최소한으로 일어나도록 각자의 알고리즘으로 동작함

---

## 9. 핵심 흐름 한 줄 요약

> Flash는 덮어쓰기가 안 됨(erase-before-write) → 그대로 쓰면 RMW로 6.6ms + 쓰기 증폭 → COW로 빈 곳에 쓰고 Mapping Table로 주소 변환(FTL) → 그 대가로 쓰레기가 생김 → GC로 회수(Victim 선택: Greedy / Cost-Benefit, 시점: Reactive / Proactive, Over-provisioning으로 비용 완화) → P/E 수명 한계 때문에 Wear Leveling → 불량·간섭 대응으로 Bad Block Management, Data Refresh

---

## 10. 용어 정리

| 용어 | 뜻 |
|---|---|
| FTL | Flash Translation Layer. 논리→물리 주소 변환 + GC + Wear Leveling을 수행하는 SSD 펌웨어 계층 |
| HIL / FIL | Host Interface Layer / Flash Interface Layer |
| RMW | Read-Modify-Write. Block 읽기→수정→Erase→다시 쓰기 |
| Write Amplification | 요청한 쓰기보다 실제 NAND 쓰기가 많아지는 현상 |
| COW | Copy-on-Write. 새 위치에 쓰고 옛 데이터는 버림 (Out-of-place update) |
| Mapping Table | 논리 주소→물리 주소 매핑. SSD 내부 DRAM/SRAM에 상주 |
| free / valid / invalid | 물리 Page 상태 |
| TRIM | OS가 SSD에 더 이상 안 쓰는 논리 주소를 알려주는 명령 |
| GC | Garbage Collection. valid Page를 옮기고 Block을 Erase해 회수 |
| Victim Block | GC 대상으로 선택된 Block |
| Cost-Benefit | (1−u)·age / 2u 점수로 Victim을 고르는 정책 |
| Over-provisioning | 노출 용량보다 Flash를 더 탑재해 GC 여유 확보 |
| P/E cycle | Program/Erase 횟수. 셀 수명 단위 |
| Wear Leveling | P/E를 전체 Block에 고르게 분산 (Dynamic / Static) |
| OOB | Out-of-Band. Page별 메타데이터 여분 영역 |
| Read Disturb | 반복 읽기로 인근 셀에 에러가 생기는 현상 |
| Data Refresh | 취약 Block의 데이터를 주기적으로 새 Block에 다시 쓰기 |

---

## 11. 셀프 체크리스트

- [ ] NAND 3대 연산과 각각의 단위(Page / Block)를 말할 수 있다
- [ ] erase-before-write 제약이 무엇인지 설명할 수 있다
- [ ] 전통 API(read/write sector)와 Flash 연산(read/program/erase)이 왜 안 맞는지 설명할 수 있다
- [ ] RMW 방식으로 Page 하나 수정할 때의 지연시간(400µs + 3ms + 3.2ms = 6.6ms)을 계산할 수 있다
- [ ] Write Amplification과 WAF를 정의할 수 있다
- [ ] In-place vs Out-of-place update를 구분할 수 있다
- [ ] Mapping Table이 왜 필요하고, 어디에 저장되며, 왜 크기가 문제인지 설명할 수 있다 (1TB당 약 1GB)
- [ ] Page 상태 전이도(free → valid → invalid → free)를 그리고 각 전이 조건을 말할 수 있다
- [ ] TRIM이 왜 필요한지 설명할 수 있다
- [ ] "Writes on an SSD" 예시에서 Mapping Table과 Page 상태 변화를 따라 그릴 수 있다
- [ ] GC 4단계를 순서대로 말하고, 예시에 적용할 수 있다
- [ ] GC 비용이 무엇에 좌우되는지, Over-provisioning이 왜 도움이 되는지 설명할 수 있다
- [ ] Greedy와 Cost-Benefit의 차이를 설명하고 점수를 계산할 수 있다
- [ ] Reactive / Proactive GC의 차이와, 독립·종속 변수 관점의 예측을 설명할 수 있다
- [ ] SLC/MLC/TLC/QLC의 대략적인 P/E cycle을 말할 수 있다
- [ ] Dynamic / Static Wear Leveling을 구분할 수 있다
- [ ] Bad Block Management(OOB, spare block)와 Read Disturb / Data Refresh를 설명할 수 있다

> 시험 관련: 교수님이 시험 하루 이틀 전에 문제 유형 힌트를 주겠다고 함