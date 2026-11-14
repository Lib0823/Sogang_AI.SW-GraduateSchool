# AI 데이터 시스템 및 인프라 — File System Implementation & Database Storage

> AI 데이터 시스템 및 인프라 (김영재 교수) · 2026.11.14
> 강의자료: `5. File System (File System Implementation)`, `6. Database Storage (DB Data Storage Structure and Indexing)`
> 참고 교재: OSTEP Ch.40 File System Implementation / Ch.42 Crash Consistency, Silberschatz *Database System Concepts* Ch.13~14

---

## 0. 전체 흐름

```
[스토리지 HW: HDD/SSD]  ── 블록 단위 ──▶  [File System]  ── 파일(블록 집합) ──▶  [DBMS]  ── 레코드 단위 ──▶  [App / SQL]
```

- 지금까지 HDD → SSD/FTL 순으로 **디바이스**를 봤고, 이번 주는 그 위 계층인 **파일 시스템**과 **DB 스토리지**를 다룸
- 파일 시스템은 "블록 → 파일"이라는 추상화를, DBMS는 "파일 → 레코드"라는 추상화를 제공함
- 두 계층 모두 핵심 고민은 같음: **원하는 데이터를 최소한의 디스크 접근으로 찾고(인덱싱), 장애가 나도 일관성을 유지하는 것(consistency)**

---

# Part 1. File System — On-Disk Structures

## 1.1 File System이란

- 스토리지 디바이스에 데이터가 **어떻게 저장되고 접근되는지를 관리하는 소프트웨어 계층**임
- 제공하는 기능
  - **Naming**: 파일·디렉터리 이름
  - **Organization**: 계층 구조(hierarchy)
  - **Storage mapping**: 논리 주소(파일 offset) → 물리 블록
  - **Access control**: read / write / permission
- 필요한 이유
  - 애플리케이션은 raw disk(섹터, 블록, offset)가 아니라 **파일**을 다룸 → HW 세부사항을 숨김
  - 데이터 영속성(persistence), 프로세스·사용자 간 공유, 보호와 신뢰성 제공
- 예: NTFS(Windows), ext4(Linux), XFS, APFS(macOS), FAT32

### File System의 두 가지 관심사

| 관심사 | 내용 |
|---|---|
| **On-Disk Structure** | 데이터와 메타데이터가 디스크에 어떻게 영속적으로 배치되는가 (block, inode, directory, journal) |
| **Software Management Layer** | OS가 스토리지를 어떻게 관리하고 사용자/앱과 상호작용하는가. 목표는 **장애가 나도 데이터 손실이 없는 것** |

## 1.2 File

- 파일 = **Data + Metadata**
  - Data: 파일 내용
  - Metadata: 크기, 소유자, 타임스탬프, 권한, 블록 포인터 등
- 파일 타입을 **누가 해석하느냐**에 따라 두 가지로 나뉨
  1. **File-System-Level Type**: 파일 시스템이 직접 해석 — Regular file, **Directory**, Symbolic link, Device file
  2. **OS / Runtime-Level Type**: OS나 런타임 라이브러리가 해석 — 실행 파일, Shared library(.dll/.so), 소스코드, 텍스트/미디어 파일
- 즉 `.mp4`, `.so` 같은 구분은 파일 시스템 입장에서는 전부 그냥 regular file임

## 1.3 파일 시스템 설계 시 고민거리 (Design Challenges)

| 이슈 | 핵심 질문 | 주요 해법 |
|---|---|---|
| **Data Placement** | 파일 데이터를 어디에 둘까? | 디스크를 고정 크기 블록(0…N)으로 나눔. 핵심은 **file offset → physical block** 매핑 |
| **Index Structure** | 파일의 블록들을 어떻게 찾을까? | 연속 할당, 연결 리스트, 인덱스 구조 → **inode, FAT, extent** |
| **Index Granularity** | 블록 크기를 얼마로? | 섹터 크기의 배수. 작으면 내부 단편화↓, 크면 처리량↑·메타데이터 조회↓ |
| **Free Space Mgmt** | 빈 블록을 어떻게 찾을까? | **Bitmap**(일반적), Free list, Extent 기반 추적 |
| **Locality** | 공간 지역성을 어떻게 유지할까? | 관련 블록을 가까이 배치. 단편화(fragmentation)는 곧 성능 저하 |
| **Reliability** | 작업 도중 크래시 나면? | 원자적 업데이트, crash-consistency 기법 → **Journaling, Copy-on-Write, Log-Structured FS** |

## 1.4 On-Disk 구조 한눈에 보기 (VSFS: Very Simple File System 예시)

강의에서 쓰는 예시 디스크: **블록 64개, 블록 크기 4KB (총 256KB)**

```
 블록:   0    1    2    3~7            8 ~ 63
       [ S ][ i ][ d ][ I I I I I ][ D D D D ... D D D ]
        │    │    │     │              │
        │    │    │     │              └ Data Region (56블록)
        │    │    │     └ Inode Table (5블록)
        │    │    └ Data Bitmap
        │    └ Inode Bitmap
        └ Superblock
```

| 구분 | 구조 | 역할 |
|---|---|---|
| Data | **Data blocks** | 실제 파일 내용 저장 (디렉터리 내용, indirect 블록도 여기에 저장됨) |
| Indexing | **Inode table** | 파일별 메타데이터 + 데이터 블록 포인터 |
| | **Indirect blocks** | direct 포인터로 부족할 때 파일 크기 확장용 |
| Namespace | **Directories** | 파일 이름 → inode 번호 매핑 |
| Allocation Metadata | **Data bitmap** | 데이터 블록 사용 여부 추적 |
| | **Inode bitmap** | inode 사용 여부 추적 |
| Global Metadata | **Superblock** | FS 설정(블록 크기, inode 개수, inode table 시작 위치 등). 가장 중요한 메타데이터 |

## 1.5 Inode

### Inode 크기와 Inode Block

- inode 하나는 보통 **256바이트**(FS에 따라 128바이트)임
- inode에 들어가는 정보는 많지 않으므로 4KB를 통째로 쓸 필요가 없음 → **4KB 블록 하나에 inode 16개**(4096 / 256 = 16)가 들어감
- inode 번호는 0번부터 시작해서 inode table 블록에 **16개씩 순서대로** 채워짐
  - 블록 3: inode 0~15, 블록 4: inode 16~31, 블록 5: inode 32~47 …
- 예시 FS의 inode table은 5블록 → 최대 inode 80개 = **최대 파일 80개**

### Inode에 들어있는 정보

| 필드 | 의미 |
|---|---|
| type | regular file인지 directory인지 등 |
| uid | 소유자 |
| rwx | 권한 |
| size | 파일 크기(바이트) |
| blocks | 할당된 블록 수 |
| time / ctime | 접근 시간 / 변경 시간 |
| links_count | 이 inode를 가리키는 경로(hard link) 수. 0이 되면 삭제 가능 |
| addrs[N] | 데이터 블록 포인터 N개 |

- **inode에는 파일 이름이 없음**. 이름은 부모 디렉터리의 디렉터리 엔트리에 저장됨 → 어떤 디렉터리의 이름을 알려면 **부모 디렉터리**의 데이터를 봐야 함
- 반대로 디렉터리 안의 `..` 엔트리에 부모의 inode 번호가 있으므로 inode 번호로 부모 디렉터리를 찾아갈 수 있음

### 📝 Quiz — 최대 파일 크기 (single level)

> 가정: single level(inode가 데이터 블록만 직접 가리킴), 256바이트 inode 전체를 포인터로 사용, 주소 4바이트, 블록 4KB

- 포인터 개수 = 256 / 4 = **64개**
- 최대 파일 크기 = 64 × 4KB = **256KB**
- 하지만 예시 FS의 데이터 블록은 **56개뿐** → 실제 최대 파일 크기 = 56 × 4KB = **224KB**
- 포인트: 이론상 한계(포인터 수)와 **실제 디스크 용량 한계** 중 작은 값이 답임

## 1.6 Inode의 블록 포인터 구조 (Multi-level Index)

### Indirect 블록이 필요한 이유

- inode가 모든 데이터 블록을 직접 가리키면 포인터 개수(=inode 크기)에 한계가 있음
- 그래서 inode는 **indirect 블록**을 가리키고, indirect 블록이 실제 데이터 블록들을 가리키게 함
- **indirect 블록도 일반 데이터 블록에 저장됨** (데이터 영역의 블록을 포인터 저장용으로 쓰는 것)

```
inode ─▶ indirect ─▶ data, data, data, ... (4KB/4B = 1024개)
      ─▶ indirect ─▶ data, data, ...
```

### 작은 파일 최적화: Direct + Indirect 혼합

- 모든 접근이 indirect를 거치면 **작은 파일은 불필요한 디스크 접근이 한 번 더 생김** (낭비)
- 실제 파일은 대부분 작음 → inode에 **direct 포인터 몇 개 + indirect 포인터**를 섞어 둠
  - 작은 파일: direct 포인터로 바로 데이터 블록 접근
  - 큰 파일: indirect를 통해 여러 데이터 블록을 가리킴

### Indexed Allocation (UNIX/ext2·ext3 방식)

```
inode
 ├ mode, owners, timestamps, size, block count
 ├ direct blocks (12개)        ──▶ Data
 ├ single indirect             ──▶ [포인터 블록] ──▶ Data
 ├ double indirect             ──▶ [포인터 블록] ──▶ [포인터 블록] ──▶ Data
 └ triple indirect             ──▶ [포인터] ──▶ [포인터] ──▶ [포인터] ──▶ Data
```

- 작은 파일은 별도 index block이 필요 없음
- single indirect: 데이터 블록 주소를 담은 블록
- double indirect: "데이터 블록 주소를 담은 블록"의 주소를 담은 블록

**최대 파일 크기 계산 (보충, 블록 4KB · 포인터 4B 가정)**

- 블록 하나에 들어가는 포인터 수 = 4096 / 4 = 1024개
- direct: 12 × 4KB = 48KB
- single: 1024 × 4KB = 4MB
- double: 1024² × 4KB = 4GB
- triple: 1024³ × 4KB = 4TB
- 합계 ≈ **약 4TB**

### 미디어 파일 예시 — 왜 뒤로 갈수록 느린가

- 영상 앞부분 프레임은 **direct 포인터** 범위에 있으므로 inode만 읽으면 바로 데이터 블록에 접근 가능
- 영상 맨 뒤쪽으로 스크롤하면 해당 데이터 블록이 **double/triple indirect** 범위에 있음 → indirect 블록들을 거쳐야 해서 논리적으로 디스크를 터치하는 횟수가 늘어남 → 느려짐
- 그래서 ext4는 블록 포인터 대신 **extent**(시작 블록 + 길이) 방식을 써서 큰 연속 파일의 메타데이터 접근을 줄임

## 1.7 Inode 위치 계산 (시험 계산 유형)

### 원리

- 각 파일은 **inode 번호**로 식별됨
- inode 번호만 알면 inode의 디스크 위치를 바로 **계산**할 수 있음 (검색 불필요)

```
inode 주소 = inodeStartAddr + (inode 번호 × sizeof(inode))
블록 번호   = inode 주소 / blockSize
섹터 번호   = inode 주소 / sectorSize (512B)
```

- inodeStartAddr(inode table 시작 위치)는 **superblock**에 저장되어 있음
- 디스크는 바이트 단위로 읽을 수 없고 섹터/블록 단위로 읽으므로, 실제로는 그 inode가 포함된 블록(또는 섹터)을 통째로 읽음

### 예시 FS 레이아웃

| 영역 | 주소 |
|---|---|
| Superblock | 0KB ~ 4KB |
| Inode bitmap | 4KB ~ 8KB |
| Data bitmap | 8KB ~ 12KB |
| Inode table | **12KB** ~ 32KB (iblock 0~4) |

### 📝 계산 문제 (256B inode, 블록당 16개)

| inode 번호 | 오프셋 계산 | 바이트 주소 | 블록 번호 | 섹터 번호 |
|---|---|---|---|---|
| 0 | 12KB + 0 × 256 | **12KB (12288)** | 3 | 24 |
| 4 | 12KB + 4 × 256 = 12KB + 1KB | **13KB (13312)** | 3 | 26 |
| 32 | 12KB + 32 × 256 = 12KB + 8KB | **20KB (20480)** | 5 | 40 |
| 40 | 12KB + 40 × 256 = 12KB + 10KB | **22KB (22528)** | 5 | 44 |

- 검산: inode 32는 블록 3(0~15), 블록 4(16~31)를 지나 블록 5의 첫 번째 inode → 12KB + 2 × 4KB = 20KB ✔

## 1.8 Free Space 관리 — Bitmap

- 핵심 질문: 빈 데이터 블록이나 빈 inode를 어떻게 빠르게 찾을까?
- 방법: **Free List**(빈 블록을 연결 리스트로 관리), **Bitmap**(가장 일반적)
- **Inode bitmap**: 어떤 inode가 사용 중인지 inode 하나당 **1bit(0/1)**로 매핑
- **Data bitmap**: 어떤 데이터 블록이 사용 중인지 블록 하나당 **1bit(0/1)**로 매핑
- 4KB bitmap 블록 하나로 32K(4096 × 8 = 32,768)개의 객체를 추적할 수 있음 → 예시 FS에는 과하지만 단순성을 위해 블록 하나씩 할당함

### 불일치 가능성과 fsck

- 메타데이터 업데이트 도중 크래시/정전이 나면 **불일치(inconsistency)**가 생길 수 있음
  - 예: 어떤 데이터 블록이 bitmap에서는 "사용 중"인데 어떤 inode도 가리키지 않음
- 원인: 파일 하나를 쓰려 해도 **inode, data bitmap(또는 inode bitmap), data block** 등 여러 구조를 따로따로 업데이트해야 하는데, 그 사이에 크래시가 나면 일부만 반영된 상태로 남음
- **fsck (file system checker)**
  - 파일 시스템 메타데이터 전체를 스캔
  - 이중 할당(double allocation), 잃어버린 블록(lost block) 등 불일치 탐지
  - 일관된 상태로 복구
  - 단점: 디스크 전체를 스캔하므로 **매우 느림** (디스크가 클수록 더 심해짐) → 그래서 저널링이 등장함

## 1.9 Superblock

- 파일 시스템의 기본 설정 메타데이터를 저장
  - 블록 크기, inode 개수, 데이터 블록 개수
  - **inode table 시작 위치**
  - 기타 FS 파라미터 (FS 타입 식별 magic number 등)
- **마운트(mount)할 때 OS는 superblock부터 읽음** → 이걸로 내부 자료구조를 초기화함
- **superblock이 망가지면 파일 시스템을 마운트할 수 없음** → 그래서 실제 FS(ext 계열)는 superblock 사본을 여러 블록 그룹에 백업해 둠

> **Quick Format**은 superblock(과 bitmap 등 메타데이터)만 새로 쓰는 것임. 데이터 블록은 그대로 남아 있지만 이를 찾아갈 메타데이터가 없어지므로 사실상 데이터에 접근할 수 없게 됨. 복구 프로그램은 데이터가 살아 있다는 점을 이용해 블록들을 여러 조합으로 읽어 보며 파일을 재구성함.

## 1.10 Directory

### 디렉터리 = 특별한 파일

- 디렉터리도 **파일**임. 다만 내용(data)이 일반 데이터가 아니라 **(이름, inode 번호) 테이블**임
- inode의 **type 필드**로 regular file과 directory를 구분함
- 디렉터리 엔트리는 데이터 블록에 저장되며, 큰 디렉터리는 여러 데이터 블록에 걸침

**디렉터리 데이터 예시**

| valid | name | inode |
|---|---|---|
| 1 | `.` | 134 |
| 1 | `..` | 35 |
| 1 | foo | 80 |
| 1 | bar | 23 |

- `.`은 자기 자신, `..`은 부모 디렉터리의 inode 번호
- `unlink("foo")` 하면 foo 엔트리를 삭제(valid=0 등으로 표시)하고, inode 80의 links_count를 감소시킴. links_count가 0이 되면 inode와 데이터 블록이 해제됨

### 디렉터리 엔트리 구성 방식

| 방식 | 특징 | 탐색 비용 |
|---|---|---|
| **Linear list** | 단순한 (inode, name) 쌍 나열, 순차 탐색. 작은 디렉터리에 효율적 | O(n) |
| **Tree 기반 (B-tree 등)** | 큰 디렉터리에서도 확장성 좋음 | O(log n) |

- **ext4 사례**
  - 작은 디렉터리: linear list로 저장 (오버헤드 최소)
  - 큰 디렉터리: **HTree**(해시 기반 B-tree 유사 구조) — 파일 이름을 해시해서 index block으로 찾아감 → 낮은 메타데이터 오버헤드로 빠른 조회

### 디렉터리 연산

| 연산 | 의미 |
|---|---|
| Search | 이름으로 디렉터리 엔트리 조회 |
| Create | 새 엔트리 삽입 |
| Delete | 엔트리 제거 |
| List | 모든 엔트리 나열 (`ls`) |
| Rename | 엔트리 이름 변경 |
| Traverse | 디렉터리 구조 전체를 체계적으로 순회 (백업 시 유용) |

### Key Insight — Metadata-Intensive

- 디렉터리 연산은 **metadata-intensive**함
  - 디렉터리 내용 자체는 "이름 + inode 번호"뿐이라 크기가 작음 → data-intensive라고 하지 않음
  - 대신 inode, bitmap, 디렉터리 블록 등 메타데이터를 여러 번 건드림
- 대규모 시스템(HPC, 분산 파일 시스템 등)에서는 **메타데이터 연산 횟수가 데이터 I/O보다 훨씬 많고**, 전체 성능을 좌우하는 경우가 많음
- 특히 여러 프로세스/노드가 **동시에(parallel)** 같은 디렉터리에 파일을 생성하는 상황에서는, 디렉터리를 일관되게 갱신해야 하므로 경합(lock contention)이 생겨 디렉터리 연산이 병목이 됨
  - 기존 파일 시스템·OS는 이런 대규모 병렬 메타데이터 접근을 크게 고려하지 않고 설계됨
  - 그래서 Lustre 같은 분산 FS는 메타데이터 서버(MDS)를 따로 둠

---

# Part 2. File System — Access Methods

## 2.1 핵심 파일 연산 (POSIX)

- `create`, `open`, `read`, `write`, `close`
- 단순한 API지만 내부적으로는 복잡한 메타데이터·데이터 경로 연산을 유발함

| 연산 | 내부 동작 | 지배적 비용 |
|---|---|---|
| **create()** | 새 inode 할당 → inode 초기화(type, 권한, 타임스탬프) → 디렉터리 엔트리 삽입(이름→inode) → 디렉터리·inode 메타데이터를 디스크에 갱신 | 메타데이터 + 디렉터리 갱신 |
| **open()** | 경로 탐색(directory lookup → inode lookup) → 권한 검사 → 커널에서 **file descriptor** 할당 | 디렉터리 lookup (큰 디렉터리면 메타데이터 병목) |
| **read()** | page cache 확인(hit → 메모리 복사, miss → 디스크 I/O) → file offset → 데이터 블록 변환 | 데이터 I/O (메타데이터 비용은 open에서 이미 치름) |
| **write()** | (파일 확장 시) 데이터 블록 할당 → inode의 size·타임스탬프 갱신 → dirty page 표시 → 모드에 따라 지연/즉시 반영 | 데이터 + 메타데이터 |
| **close()** | fd 해제, 참조 카운트 감소. 실제 디스크 I/O는 나중에(write-back은 비동기) | 거의 없음 |

- **close()는 저렴하지만 durability를 보장하지 않음** → 디스크 반영을 보장하려면 `fsync()`를 호출해야 함

### File Descriptor

- 파일을 이름(경로)으로 매번 찾으면 비효율적이므로, open 시점에 경로 탐색을 한 번 하고 **fd(정수 번호)**를 돌려줌
- 이후 read/write는 fd로 접근 → 파일을 가리키는 또 하나의 "이름" 역할을 함 (inode 번호도 파일을 가리키는 이름의 한 형태임)
- 프로세스별 fd 테이블 → open file table(현재 offset 등) → inode 순으로 연결됨
- 읽기/쓰기가 끝나면 반드시 `close()`로 fd를 반환해야 함

## 2.2 Access Timeline (OSTEP Figure 40.3·40.4) — 디스크 I/O 횟수 세기

> 가정: 캐시가 비어 있음, 각 칸은 블록 단위 디스크 I/O

### `open("/foo/bar")` — 읽기 5회

1. **root inode** read — root의 inode 번호는 미리 정해진 고정 번호(well-known)임. ext2/3/4에서는 **2번**이고, 강의 예시 같은 단순화된 FS에서는 0번처럼 고정값으로 둠. 고정이어야 경로 탐색의 출발점을 알 수 있음
2. **root data** read — root 디렉터리 엔트리에서 `foo`의 inode 번호를 찾음
3. **foo inode** read
4. **foo data** read — foo 디렉터리 엔트리에서 `bar`의 inode 번호를 찾음
5. **bar inode** read — 권한 검사 후 fd 할당

- 경로 깊이가 깊을수록 I/O가 늘어남 (디렉터리 하나당 inode + data 2번)

### `create("/foo/bar")` — 총 10회 (read 6 + write 4)

| 순서 | 대상 | 동작 | 이유 |
|---|---|---|---|
| 1 | root inode | read | 경로 탐색 시작 |
| 2 | root data | read | `foo` 찾기 |
| 3 | foo inode | read | |
| 4 | foo data | read | `bar`가 이미 있는지 확인 (디렉터리 엔트리를 봐야 존재 여부를 알 수 있음) |
| 5 | inode bitmap | read | 빈 inode 찾기 |
| 6 | inode bitmap | **write** | 할당한 inode 비트를 1로 표시 |
| 7 | foo data | **write** | 디렉터리에 `(bar, inode 번호)` 엔트리 추가 |
| 8 | bar inode | read | inode 블록을 읽어서 |
| 9 | bar inode | **write** | bar inode 초기화 후 다시 씀 |
| 10 | foo inode | **write** | 디렉터리의 수정 시간(mtime) 등 갱신 |

- **8~9번이 read-modify-write인 이유**: 디스크는 256바이트(또는 128바이트) inode 하나만 따로 쓸 수 없고 블록(4KB) 단위로 씀 → inode가 들어 있는 블록 전체를 읽고, 해당 inode 부분만 고친 뒤, 블록 전체를 다시 써야 함
- **10번 foo inode write**: 디렉터리에 새 파일이 생겼다는 시간 정보를 남겨야 함 (디렉터리가 커져서 새 블록이 필요하면 data bitmap과 새 데이터 블록 I/O도 추가됨)
- 파일 하나 생성하는 데 디스크 접근이 **10번** → 레거시 시스템에서는 매우 비효율적임

### `write()` — 블록 하나 추가 시 5회 (파일이 이미 열려 있다고 가정)

| 순서 | 대상 | 동작 |
|---|---|---|
| 1 | bar inode | read (어느 블록에 쓸지 확인) |
| 2 | data bitmap | read (빈 블록 찾기) |
| 3 | data bitmap | write (할당 표시) |
| 4 | bar data | write (실제 데이터) |
| 5 | bar inode | write (새 블록 포인터, size, mtime 갱신) |

- 핵심은 **빈 공간을 찾고(bitmap) → 쓰기**임
- 기존 블록을 덮어쓰는 경우라면 bitmap I/O 없이 data write + inode 갱신만 필요함

### `read()` — 3회

1. bar inode read (데이터 블록 위치 확인)
2. bar data read
3. bar inode write (**접근 시간 atime 갱신**)

- 실제로는 atime 갱신 비용 때문에 Linux는 `relatime`/`noatime` 마운트 옵션을 사용함

### `close()` — 디스크 작업 없음

- fd만 정리하면 됨. **nothing to do on disk!**

### 정리 — 파일 시스템 구조가 주는 교훈

- 파일 시스템 입장에서만 보면 **모든 파일을 루트(바탕화면) 하나에 넣는 게 제일 유리함** → 디렉터리 하나만 읽으면 끝이니까
- 디렉터리 깊이가 깊어질수록 디스크를 더 많이 터치하므로 비효율적임
- 그래서 현대 시스템은 필요한 자료구조를 **메모리에 캐싱**함

## 2.3 Efficiency — Caching & Buffering

- 핵심 질문: 기본 연산의 과도한 I/O를 어떻게 피할까? → **캐싱**
- 최근 시스템은 **S(Superblock), I(Inode/bitmap), D(Directory/Data)** 같은 자주 쓰는 구조를 메모리에 캐싱해 두고 디스크 접근을 줄임
- 메모리는 한정되어 있으므로 전부 캐시하지 않고 **읽은 것 위주로 캐시**함

### Read Caching

- 자주 접근하는 데이터를 캐시해서 반복적인 디스크 읽기를 최소화
- 예: 같은 디렉터리의 파일을 연달아 열면 디렉터리 inode·data는 두 번째부터 캐시 hit

### Write Buffering (Write-back)

- 쓰기를 메모리에 잠시 버퍼링해 두었다가 모아서 내려씀
- 장점
  - **I/O 병합(coalescing)**: 같은 bitmap을 여러 번 갱신해도 한 번만 씀
  - **I/O 스케줄링**: 모아 둔 쓰기를 정렬해서 효율적으로 내려씀
  - **쓰기 회피**: 파일을 만들었다가 금방 지우면 아예 디스크에 쓸 필요가 없음
  - write amplification 감소
- 단점: **정전되면 버퍼의 데이터를 잃어버림** (메모리는 휘발성)
- 그래서 **디스크와 주기적으로 동기화(flush)**함. 방법은 크게 두 가지
  1. **주기적 write-back**: 커널 flusher 스레드가 일정 주기(보통 5~30초)마다 dirty page를 디스크로 내림
  2. **명시적 동기화**: 애플리케이션이 `fsync()`/`fdatasync()`를 호출해 즉시 디스크 반영을 강제함 (DBMS가 커밋 시 사용)

### Page Cache (Unified Page Cache)

- 예전에는 가상 메모리용 페이지와 파일 블록용 buffer cache가 따로 있었음 → 이를 **하나로 합친 것**이 page cache
- 물리 페이지 프레임 하나가 **프로세스 주소 공간의 페이지**일 수도, **파일 블록**일 수도 있음
  - 프로세스: page table로 가상 페이지 → 페이지 프레임 매핑
  - 파일 I/O: Linux의 `address_space`로 파일 블록 → 물리 페이지 프레임 매핑
- **Dynamic partitioning**: 가상 메모리와 파일 캐시가 메모리를 고정 비율이 아니라 필요에 따라 동적으로 나눠 씀

## 2.4 Crash Consistency와 쓰기 순서(Ordering)

- 캐싱과 효율을 위한 기법이 들어가면서 파일 시스템은 더 복잡해짐 → 효율과 **consistency**를 동시에 지키는 기법(저널링 등)이 많이 적용됨
- 파일 시스템에서 읽기/쓰기 시 **쓰기 순서(ordering)**가 매우 중요함. 파일 시스템이 정의한 규칙에 따라 일관성을 유지해야 함

### 크래시 시나리오 (블록 하나 append: Data, Inode, Bitmap 3개를 써야 함)

| 디스크에 반영된 것 | 결과 | 문제 |
|---|---|---|
| Data만 | 아무도 가리키지 않음 → 쓰기가 없었던 것과 같음 | 없음 (데이터만 유실) |
| Inode만 | inode가 가리키는 블록에 쓰레기 데이터 | **garbage read** + bitmap 불일치 |
| Bitmap만 | 블록은 사용 중인데 아무도 안 가리킴 | **space leak** (공간 누수) |
| Inode + Bitmap | 메타데이터끼리는 일관적 | 데이터 블록에 **쓰레기**가 들어 있음 |
| Inode + Data | 데이터는 정상 | bitmap과 불일치 → 나중에 이중 할당 위험 |
| Bitmap + Data | | 어느 파일 블록인지 알 수 없음, 공간 누수 |

### 데이터를 먼저 쓸까, 메타데이터(bitmap)를 먼저 쓸까?

- 수업 중 질문: "bitmap을 먼저 쓰는 게 효율적이지 않나?"
- 답: 파일 시스템이 **선택**할 수 있지만, 일반적으로 **데이터를 먼저 쓰고 → 메타데이터를 씀**
  - 데이터 먼저 쓰고 크래시 → 그 데이터를 가리키는 메타데이터가 없으므로 그냥 없던 일이 됨 (일관성 유지)
  - 메타데이터 먼저 쓰고 크래시 → inode가 "200번 블록에 썼다"고 가리키는데 실제로 가 보면 데이터가 없음 → **쓰레기 데이터가 노출**됨 (다른 사용자의 옛날 데이터가 보일 수 있어 보안 문제도 됨)

### Metadata Consistency vs Data Consistency

- **Metadata consistency**: 메타데이터끼리만 일관되면 OK. 데이터는 유실되어도 괜찮다는 관점
  - 위 표에서 "Inode + Bitmap" 경우도 메타데이터 관점에서는 consistent함 (쓰레기 데이터가 들어 있어도)
- **Data consistency**까지 보장하려면 모든 데이터를 두 번 써야 하는 등 **파일 시스템이 너무 느려짐**
- 그래서 실제 파일 시스템은 보통 **메타데이터까지만 consistent하게 보장**하고, 쓰기 순서(데이터 먼저)를 지켜서 데이터 손실 확률을 극히 낮게 만듦

### Journaling 모드 (ext3/ext4, 보충)

| 모드 | 저널에 기록하는 것 | 특징 |
|---|---|---|
| `data=journal` | 데이터 + 메타데이터 | 가장 안전, 데이터를 두 번 쓰므로 가장 느림 |
| `data=ordered` (기본) | 메타데이터만, 단 **데이터를 먼저 디스크에 쓴 뒤** 메타데이터 커밋 | 쓰레기 노출 방지, 성능·안전 균형 |
| `data=writeback` | 메타데이터만, 데이터 순서 보장 없음 | 가장 빠름, 크래시 후 쓰레기 데이터가 보일 수 있음 |

- 저널링 상세(WAL, checkpoint, recovery)는 이후 주차에서 다룸

---

# Part 3. Database Storage — Data Storage Structure

## 3.1 File System 관점 vs Database 관점

| | File System | Database |
|---|---|---|
| 접근 단위 | **블록**(또는 파일) | **레코드** |
| 크기 관계 | | 보통 **record < block** |

- DB는 결국 비휘발성 스토리지(HDD/SSD) 위의 **파일들의 집합**으로 저장됨
- 구조: **Database → 여러 File → 각 File은 Record의 나열 → 각 Record는 Field의 나열**
- 테이블 하나(relation)가 파일 하나에 대응하고, 테이블의 각 **행(row)이 레코드**임
- SQL 질의는 결국 이 테이블 포맷의 DB 파일에 대해 수행됨
- **DBMS의 기본 역할**: 파일이라는 "블록들의 집합" 추상화 위에서 **레코드들을 관리**하는 것 (어디에 넣고, 어떻게 찾고, 삭제 후 빈 공간을 어떻게 관리할지)

## 3.2 File Organization — 가장 단순한 가정

- 레코드 크기가 **고정**
- 파일 하나에는 **한 종류의 레코드만** 저장
- 관계(relation)마다 다른 파일 사용
- 레코드는 **디스크 블록보다 작음**
- (이후 가변 길이 레코드로 확장)

## 3.3 Fixed-Length Records

### 저장 방식

- 레코드 크기가 n바이트일 때, 레코드 i는 **n × (i − 1)** 바이트 위치부터 저장 (i는 1부터)
- 접근은 단순하지만 **레코드가 블록 경계를 넘어갈 수 있음**
  - 레코드 하나를 읽는 데 블록 두 개를 읽어야 함
  - 해결: **레코드가 블록 경계를 넘지 않도록 함** (블록 끝에 남는 자투리는 비워 둠)

### 삭제 처리 — 3가지 방법

레코드 i(예: 3번)를 삭제할 때

| 방법 | 동작 | 장단점 |
|---|---|---|
| ① 뒤쪽 레코드를 전부 당김 | 레코드 i+1, …, n을 i, …, n−1로 이동 | 빈틈은 없지만 **이동 비용이 큼** |
| ② 마지막 레코드를 빈자리로 | 레코드 n을 i 위치로 이동 (예: 3번 자리에 11번) | 이동은 1번이지만 **레코드 순서가 깨짐** |
| ③ 이동하지 않고 Free List | 삭제된 자리를 연결 리스트로 관리 | 이동 없음. 가장 실용적 |

**Free List 구조**

- 파일 맨 앞 **header**에 첫 번째 빈 레코드 주소를 저장
- 각 빈 레코드에는 다음 빈 레코드 주소를 저장 → 빈 자리들이 연결 리스트로 이어짐
- 삽입 시 free list의 첫 자리를 재사용, 비어 있으면 파일 끝에 추가
- 예: 레코드 0~3이 삭제되면 4~7 같은 남은 레코드와 빈자리(0~3)를 DBMS가 함께 관리해야 함

## 3.4 Variable-Length Records

### 발생 원인

- 한 파일에 **여러 타입의 레코드**를 저장하는 경우
- **가변 길이 필드**를 허용하는 경우 (예: `VARCHAR`)

### 레코드 내부 구조

```
[ (offset,len) (offset,len) | 고정 길이 속성들 | null bitmap | 가변 길이 데이터 ... ]
```

- 속성은 순서대로 저장
- 가변 길이 속성은 **고정 크기 (offset, length) 쌍**으로 표현하고, 실제 데이터는 **모든 고정 길이 속성 뒤**에 저장
  - 이렇게 하면 레코드 앞부분은 항상 고정 크기 → 원하는 속성 위치를 바로 계산 가능
- **Null 값은 null-value bitmap으로 표현** (속성마다 1비트, 1이면 NULL → 데이터 공간 차지 안 함)

### Slotted Page Structure

```
 ┌─────────────────────────────────────────────────────┐
 │ Header: #entries | free space end | (loc,size)(loc,size)... │ → 앞에서부터 자람
 │                                                     │
 │                   Free Space                        │
 │                                                     │
 │               ... Record3 | Record2 | Record1 │ ← 뒤에서부터 자람
 └─────────────────────────────────────────────────────┘
```

- **Slotted page header**에 저장하는 것
  - 레코드 엔트리 개수
  - 블록 내 free space의 끝 위치
  - 각 레코드의 **위치와 크기** (slot 배열)
- 레코드는 블록 끝에서부터, 헤더의 slot 배열은 앞에서부터 채워지고, 가운데가 free space임
- 레코드 삭제 시 페이지 안에서 레코드를 이동시켜 **빈틈 없이 연속적으로 유지**할 수 있음 → 이동하면 헤더의 해당 엔트리만 갱신
- **포인터는 레코드를 직접 가리키면 안 됨** → 헤더의 **slot 엔트리**를 가리키고, slot이 실제 레코드를 가리킴 (간접 참조)
  - 그래야 페이지 내에서 레코드가 이동해도 외부 포인터(인덱스 등)를 수정할 필요가 없음

> **PostgreSQL 연결 (보충)**: PostgreSQL의 heap page(8KB)가 바로 slotted page 구조임. 페이지 헤더 뒤의 line pointer(ItemId) 배열이 slot이고, 튜플은 페이지 끝에서부터 채워짐. 튜플 주소인 `ctid = (블록 번호, slot 번호)`가 레코드를 직접 가리키지 않고 slot을 가리키는 포인터임. 튜플 헤더에는 null bitmap도 있음.

---

# Part 4. Indexing

## 4.1 디스크 구조 복습

- 디스크는 **블록(섹터, 예: 512B) 단위**로 읽음
- 블록 내 특정 위치는 offset으로 표현 (예: offset = 100)
- DB 성능은 결국 **레코드 하나를 찾기 위해 몇 개의 블록에 접근하느냐**로 결정됨

## 4.2 📝 인덱스 계산 예제 (시험 계산 유형)

### 조건 — Employee 테이블

| 필드 | 크기 |
|---|---|
| eid | 10B |
| name | 50B |
| dept | 10B |
| section | 8B |
| add | 50B |
| **레코드 크기** | **128B** |

- 레코드 100개, 블록 크기 512B(섹터)

### Step 1. 데이터 블록 수

- 블록당 레코드 수 = 512 / 128 = **4개**
- 레코드 100개에 필요한 블록 수 = 100 / 4 = **25블록**
- 인덱스 없이 레코드를 찾으면 최악의 경우 **25블록**을 전부 읽어야 함 (full scan)

### Step 2. 단일 레벨 인덱스

- 인덱스 엔트리 = (eid 10B, 포인터 6B) = **16B**
- 블록당 인덱스 엔트리 수 = 512 / 16 = **32개**
- 인덱스 100개에 필요한 블록 수 = 100 / 32 = 3.125 → 올림해서 **4블록**
- 접근 블록 수 = 인덱스 4블록 + 데이터 1블록 = **5블록**
- 인덱스 엔트리가 레코드보다 훨씬 작으므로(16B vs 128B) 한 블록에 더 많이 들어감 → 접근 블록 수가 줄어듦

### Step 3. Multi-level Index

- 인덱스 4블록에 대해 다시 인덱스를 만듦 (인덱스의 인덱스)
- 바깥(outer) 인덱스: 안쪽 인덱스 블록마다 엔트리 1개 → 4개 엔트리 (예: eid 1, 33, 65, 97 → 각 inner 블록을 가리킴) → **1블록**이면 충분
- 접근 블록 수 = outer 1 + inner 1 + data 1 = **3블록**

| 방식 | 접근 블록 수 |
|---|---|
| 인덱스 없음 | 25 |
| 단일 레벨 인덱스 | 4 + 1 = 5 |
| Multi-level 인덱스 | 1 + 1 + 1 = 3 |

- **Multi-level index는 검색(search) 시간을 최소화**함
- 레벨이 하나 늘 때마다 대상 블록 수가 약 1/32로 줄어듦 → 레코드가 많아질수록 효과가 커짐 (블록 접근 수 ≈ log₃₂ N)

### Dense Index vs Sparse Index

| 구분 | 의미 | 예시에서 |
|---|---|---|
| **Dense Index** | 모든 search key(레코드)마다 인덱스 엔트리가 있음 | inner 인덱스 (eid 1, 2, 3, …, 100) |
| **Sparse Index** | 일부 key(블록마다 하나 등)만 엔트리가 있음. 데이터가 key 순으로 정렬되어 있어야 함 | outer 인덱스 (eid 1, 33, …) |

- Sparse index는 공간이 적게 들고, 찾은 엔트리 이후로 순차 탐색하면 됨

### Primary(Clustering) Index vs Secondary Index

- 인덱스는 레코드를 찾아가기 위한 별도 구조임 → 레코드가 100개면 **원본 테이블 + 그에 대한 인덱스 엔트리 100개**가 추가로 필요
- **Primary key**로 찾으려면 primary key 인덱스가, **secondary key**(예: name, dept)로 찾으려면 그 key에 대한 인덱스가 따로 있어야 함
- Secondary index는 데이터가 그 key 순서로 정렬되어 있지 않으므로 **반드시 dense**여야 함

### 인덱스를 90도 돌려 보면 → 트리

- Multi-level index를 오른쪽으로 90도 회전하면 루트(outer) → 내부(inner) → 리프(데이터)로 이어지는 **트리 구조**가 됨
- 이게 B-tree / B+ tree의 출발점임

## 4.3 Index Data Structures — B-tree & B+ tree

### 발전 흐름

```
Binary Search Tree  ──(자식 2개 → M개)──▶  M-way Search Tree  ──(균형 유지)──▶  B-tree  ──▶  B+ tree (순차 정렬)
```

- **Binary Search Tree**: 노드당 key 1개, 자식 2개. 디스크에서는 높이가 너무 높아 블록 접근이 많음
- **M-way Search Tree**: 노드 하나(=디스크 블록 하나)에 key를 여러 개(M−1개) 넣고 자식을 M개로 → 높이가 낮아짐
- **B-tree (Balanced tree)**: M-way search tree에 **균형 조건**을 추가 → 모든 리프의 깊이가 같음 → 탐색·삽입·삭제 모두 **O(log N)** 보장
- **B+ tree**
  - 실제 데이터(또는 레코드 포인터)는 **리프 노드에만** 저장, 내부 노드는 길 안내용 key만 가짐 → 내부 노드에 key를 더 많이 넣을 수 있어 트리가 더 낮아짐
  - 리프 노드들이 **정렬된 순서로 연결(linked list)**되어 있음 → **범위 검색(range scan)과 순차 접근**에 유리
  - 대부분의 DBMS 인덱스(PostgreSQL B-tree 인덱스, MySQL InnoDB 등)가 B+ tree 계열임

### B+ tree의 단점 — SMO

- 균형을 유지하기 위해 삽입/삭제 시 내부적으로 **SMO(Structure Modification Operation)**를 수행함
  - 노드가 꽉 차면 **split**, 너무 비면 **merge/redistribute**, 이게 부모 노드로 연쇄 전파될 수 있음
- 삽입 시 SMO 때문에 **연산 시간이 길어지고**, 여러 노드를 **제자리 갱신(in-place update)**하면서 **랜덤 쓰기**가 많이 발생함
- 동시성 측면에서도 SMO 중에는 여러 노드에 lock이 필요해 병목이 됨
- → **쓰기가 많은 워크로드에는 불리**함

## 4.4 LSM-tree 계열 — LevelDB / RocksDB (예고)

### 등장 배경: 빅데이터 시대

- 빅데이터 처리는 **수집 → 정제 → 처리** 순인데, 일단 **수집(저장)**이 중요함
- "인사이트를 뽑기 전에 일단 쌓아 두자" → **쓰기 성능**이 핵심이 됨
- 쓰기가 많은 상황에서 B+ tree는 SMO와 랜덤 쓰기 때문에 불리함

### LevelDB / RocksDB

- **LevelDB**: Google이 만든 **Key-Value 저장 엔진**으로 오픈소스로 공개됨. 인덱스 자료구조로 **LSM-tree(Log-Structured Merge-tree)**를 사용
  - 일단 저장부터 하자는 철학 → key-value 형태면 어떤 데이터든 그냥 넣으면 됨
- **RocksDB**: Facebook(Meta)이 LevelDB를 포크해 멀티코어·SSD 환경에 맞게 개선한 엔진
  - ByteDance(TikTok) 같은 대규모 서비스에서 인스턴스를 수천 개 띄우고 **DB sharding**으로 분산해 사용함
  - 백엔드 스토리지 엔진으로 많이 쓰임 (예: TiKV, MyRocks, Kafka Streams 상태 저장소 등) → 상위 시스템이 RocksDB를 호출해서 씀

### LSM-tree가 쓰기에 빠른 이유 (개요)

```
Write ─▶ WAL(log) append + MemTable(메모리, 정렬)
              │ 가득 차면
              ▼
        SSTable(L0) flush ─▶ Compaction ─▶ L1 ─▶ L2 ...   (디스크, 정렬된 불변 파일)
```

- 쓰기를 **로그처럼 순차적으로 append**만 함 → 제자리 갱신·SMO 없음 → 쓰기가 매우 빠름
- 정렬과 병합은 백그라운드 **compaction**이 나중에 처리
- 대신 읽기는 여러 레벨을 확인해야 해서 B+ tree보다 느릴 수 있음 (Bloom filter 등으로 보완)
- 상세 내용은 이후 주차(LSM-tree)에서 다룸

| | B+ tree | LSM-tree |
|---|---|---|
| 갱신 방식 | In-place update | Out-of-place, append |
| 쓰기 | 랜덤 쓰기 + SMO → 느림 | 순차 쓰기 → 빠름 |
| 읽기 | O(log N), 빠름 | 여러 레벨 확인 → 상대적으로 느림 |
| 대표 | PostgreSQL, MySQL InnoDB | LevelDB, RocksDB, Cassandra |

> SSD/FTL 주차와 연결: LSM-tree의 "out-of-place + 나중에 compaction"은 FTL의 "out-of-place write + GC"와 같은 발상임.

---

## Summary

### File System

- 파일 시스템은 **Naming & hierarchy, Storage mapping(논리 offset → 물리 블록), Access control, Persistence & reliability**를 제공함
- 파일 = **data + metadata** (크기, 소유자, 권한, 타임스탬프, 블록 포인터)
- On-disk 구조: **Superblock, Inode bitmap, Data bitmap, Inode table, Data blocks(디렉터리·indirect 포함)**
- 핵심 설계 이슈: 블록 할당과 인덱싱, free space 관리, locality와 fragmentation, crash consistency
- 기본 연산도 다수의 메타데이터 I/O를 유발함 (create 10회 등) → 성능은 **캐싱과 버퍼링(page cache)**에 크게 의존함
- 쓰기 순서와 consistency 수준(metadata vs data)은 성능과 안전성의 트레이드오프임

### Database Storage

- DB는 블록 기반 스토리지 위에 저장되지만 애플리케이션에는 **레코드 단위 추상화**를 제공함
- 레코드 구성
  - 고정 길이: 접근이 단순하지만 유연성 부족 (삭제는 free list로 관리)
  - 가변 길이: **slotted page**로 효율적으로 관리
- **인덱싱은 full scan을 피하는 핵심**: 단일/다단계 인덱스로 블록 접근 수를 줄임 (25 → 5 → 3)
- **B-tree / B+ tree**가 표준 디스크 친화적 인덱스, 쓰기 위주 환경에서는 **LSM-tree**
- DB는 캐싱, 버퍼링, 구조화된 레코드 레이아웃, 인덱싱으로 **디스크 I/O를 최소화**해 효율을 얻음

---

## ✅ 셀프 체크리스트

**File System**

- [ ] 파일 시스템이 제공하는 4가지 기능(naming, organization, storage mapping, access control)을 말할 수 있다
- [ ] VSFS 예시 디스크 레이아웃(S, i, d, I, D)과 각 구조의 역할을 설명할 수 있다
- [ ] inode가 256B일 때 4KB 블록에 몇 개 들어가는지, 왜 그렇게 하는지 설명할 수 있다
- [ ] inode에 파일 이름이 없는 이유와 이름이 어디에 저장되는지 안다
- [ ] single-level 가정에서 최대 파일 크기(256KB → 실제 224KB)를 계산할 수 있다
- [ ] direct/indirect 포인터를 섞는 이유(작은 파일 최적화)를 설명할 수 있다
- [ ] inode 번호로 바이트 주소·블록 번호·섹터 번호를 계산할 수 있다 (inode 0, 4, 32, 40)
- [ ] inode bitmap과 data bitmap의 역할, fsck가 하는 일과 한계를 안다
- [ ] superblock에 무엇이 들어 있고, 마운트 시 왜 먼저 읽는지 안다
- [ ] 디렉터리가 "특별한 파일"인 이유와 linear list vs HTree 차이를 안다
- [ ] 디렉터리 연산이 metadata-intensive하다는 의미를 설명할 수 있다
- [ ] `open /foo/bar`(5회), `create /foo/bar`(10회), `write`(5회), `read`(3회), `close`(0회)의 I/O 순서를 그릴 수 있다
- [ ] inode 쓰기가 read-modify-write인 이유를 안다
- [ ] page cache와 write buffering의 장단점, 주기적 flush와 fsync의 차이를 안다
- [ ] 크래시 시나리오별 결과(garbage, space leak 등)와 "데이터 먼저, 메타데이터 나중" 순서의 이유를 설명할 수 있다
- [ ] metadata consistency와 data consistency의 차이, ext4 저널링 모드 3가지를 안다

**Database Storage**

- [ ] FS 관점(블록)과 DB 관점(레코드)의 접근 단위 차이를 설명할 수 있다
- [ ] 고정 길이 레코드에서 삭제 처리 3가지 방법과 free list 구조를 안다
- [ ] 가변 길이 레코드의 (offset, length) 표현과 null bitmap을 안다
- [ ] slotted page 구조와 포인터가 slot을 가리켜야 하는 이유를 설명할 수 있다
- [ ] Employee 예제에서 25 → 5 → 3 블록 접근 수를 직접 계산할 수 있다
- [ ] dense index와 sparse index, primary index와 secondary index를 구분할 수 있다
- [ ] BST → M-way → B-tree → B+ tree 흐름과 B+ tree의 장점(리프 연결, 범위 검색)을 안다
- [ ] B+ tree의 SMO가 무엇이고 왜 쓰기에 불리한지 설명할 수 있다
- [ ] LSM-tree(LevelDB/RocksDB)가 쓰기에 빠른 이유를 B+ tree와 비교해 설명할 수 있다