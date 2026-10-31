# AI 데이터 시스템 및 인프라 — 8주차: File System Implementation

> 2026.10.31 (토) · 김영재 교수
> 참고: OSTEP (Operating Systems: Three Easy Pieces) Ch.40 *File System Implementation*
> 범위: Part 1 On-Disk Structures (수업 진행분) + Part 2 Access Methods (슬라이드 기반 예습 정리)

---

## 0. 한눈에 보기

| 구분 | 핵심 |
|---|---|
| File System 정의 | 스토리지 디바이스에 데이터가 **어떻게 저장되고 접근되는지** 관리하는 소프트웨어 계층 |
| 두 가지 관심사 | **On-Disk Structure**(디스크에 어떻게 놓이나) + **Software Management Layer**(OS가 어떻게 안전하게 관리하나) |
| 파일 = | **Data**(내용) + **Metadata**(크기, 소유자, 시간, 권한, 블록 포인터 …) |
| On-disk 구성요소 | Superblock, Inode bitmap, Data bitmap, Inode table, Data blocks (+ Directories, Indirect blocks) |
| 시험 포인트 | **max file size 계산**, **inode byte offset 계산**, **최대 파일 개수**, indirect 구조, superblock 역할 |

---

## Part 1. On-Disk Structures

### 1. File System이란?

**File System**: 스토리지 디바이스에서 데이터가 어떻게 저장(stored)되고 접근(accessed)되는지 관리하는 **소프트웨어 계층**임. 애플리케이션과 물리 스토리지 사이를 이어주는(bridge) 역할임.

#### 1.1 File System이 제공하는 것

| 기능 | 설명 |
|---|---|
| **Naming** | 파일·디렉터리에 이름을 붙여 접근하게 해줌 (블록 번호가 아니라 `/home/a.txt`로 접근) |
| **Organization (hierarchy)** | 디렉터리 트리 형태의 계층 구조 제공 |
| **Storage mapping** | **logical → physical block** 매핑. 파일의 offset이 디스크의 몇 번 블록인지 변환 |
| **Access control** | read / write / permission 관리 |

#### 1.2 왜 File System이 필요한가

- 애플리케이션은 raw disk가 아니라 **파일 단위로 동작**함
- sector, block, offset 같은 **하드웨어 세부사항을 숨겨줌** (추상화)
- 다음을 가능하게 함
  - **Data persistence**: 사라지면 안 되는 데이터를 파일로 영구 저장
  - **Sharing**: 프로세스·사용자 간 파일을 통해 정보 공유
  - **Protection & reliability**

> 예: NTFS(Windows), **Ext4**(Linux), XFS, APFS(macOS), FAT32

#### 1.3 File System Mission — 두 가지 근본 관심사

File System은 **2차 저장장치(secondary storage)에 대한 추상화**를 구현함. 사용자는 raw 블록이 아니라 파일로 작업함.

1. **On-Disk Structure**
   - data와 metadata가 스토리지(persistent media)에 **어떻게 영구 저장되는가**
   - 예: blocks, inodes, directories, journals
2. **Software Management Layer**
   - OS가 스토리지를 관리하고 사용자/애플리케이션과 상호작용하는 방식
   - 데이터가 올바르게(correct) 저장되고, 읽을 때 항상 올바르게 retrieve되는 것을 보장
   - **목표: 장애(failure)가 발생해도 데이터 손실이 없어야 함**

> 결론: File System은 **디스크 위 데이터 배치 방식**과 **그 데이터를 안전하게 관리하는 소프트웨어**를 모두 정의함.

이 단원의 목적은 파일이 **어디에, 어떻게 저장되고(persist), 어떻게 접근되는지** 내부(internal)를 이해하는 것임.

---

### 2. Files

#### 2.1 파일이란?

**파일 = 데이터 + 연관된 메타데이터**
- **Data**: 파일 내용
- **Metadata**: size, owner, timestamps, permissions, 데이터 블록 위치 …

파일은 무조건 metadata와 실제 data를 함께 가짐. **metadata가 있어야 content(데이터)를 찾을 수 있음.**

#### 2.2 File Type — 누가 해석하는가?

| 레벨 | 종류 |
|---|---|
| **File-System-Level** (FS가 직접 해석) | Regular file, **Directory**, Symbolic link, Device file |
| **OS / Runtime-Level** (OS·런타임이 해석) | Executable, Shared library(.dll/.so), Source code, Text/media |

- FS 입장에서는 실행파일이든 mp4든 그냥 regular file임. "실행 가능"이라는 의미는 OS loader가 해석함
- 디렉터리는 FS가 직접 구조를 이해해야 하는 특수 파일임

---

### 3. File System 설계 과제 (Design Challenges)

| 과제 | 질문 | 내용 |
|---|---|---|
| **Data Placement** | 파일 데이터를 어디에 저장? | 고정 크기 **block(cluster)** 단위 저장. 디스크는 0…N 번 블록으로 나뉨. 핵심: **file offset → physical block 매핑** |
| **Index Structure** | 파일의 블록을 어떻게 찾나? | 블록 번호를 참조로 사용 → index 구조 필요. contiguous allocation, linked list, indexed → **inode, FAT, extent** 로 발전 |
| **Index Granularity** | 블록 크기는? | 보통 sector 크기의 배수 (아래 표) |
| **Free Space Management** | 빈 블록을 어떻게 찾나? | 주로 **bitmap**. 대안: free list, grouped/extent 기반. 할당 속도·단편화에 영향 |
| **Locality** | 공간 지역성 유지? | 관련 블록을 가까이 배치. **fragmentation은 성능을 직접 떨어뜨림** |
| **Reliability** | 작업 도중 crash 나면? | 부분 갱신이 metadata를 망가뜨릴 수 있음 → atomic update, crash-consistency 필요 → **journaling, copy-on-write, log-structured FS** |

#### 3.1 블록 크기(Block Size) 트레이드오프

- 포맷할 때 블록 크기를 설정할 수 있음. Linux FS(ext4) **기본값은 4KB**

| | 작은 블록 | 큰 블록 |
|---|---|---|
| Internal fragmentation (블록 안 낭비) | **적음** | 많음 (1B 파일도 블록 하나 통째로 사용) |
| 파일이 쪼개지는 정도 | 많은 블록으로 쪼개짐 → 흩어지기 쉬움 | 적은 블록 → **파일 단편화(흩어짐)가 덜 생김** |
| Throughput / metadata lookup | 블록 수 많음 → 포인터·lookup 많음 | **throughput 좋음, metadata lookup 적음** |

#### 3.2 Contiguous 배치와 단편화 (수업 예시)

- 가장 단순한 방식은 **연속 배치**: 어떤 파일이 블록 6개를 쓴다면 4,5,6,7,8,9번처럼 연속으로 할당
- 이 경우 파일의 metadata는 "실제 데이터는 4~9번 블록에 있다"를 기술(describe)하면 됨
- 하지만 파일 생성·삭제가 반복되면 빈 공간이 조각나서 **fragmentation**이 생김 → 그래서 **On-disk 자료 구조 설계가 중요**함
- SSD의 경우 FS가 보는 logical block → 실제 NAND 위치 매핑은 **SSD 내부 firmware(FTL)** 가 관리함 (6주차 FTL 참고). FS는 logical block 수준까지만 관리함

---

### 4. On-Disk Structures 구성요소

| 분류 | 구조 | 역할 |
|---|---|---|
| **Data** | Data blocks | 파일 내용 저장 |
| **Indexing** | **Inode table** | 파일별 metadata + data block 포인터 |
| | **Indirect blocks** | direct 포인터 한계를 넘어 파일 크기 확장 (일반 data block에 저장됨) |
| **Namespace** | **Directories** | **파일 이름 → inode 번호** 매핑 |
| **Allocation Metadata** | **Data bitmap** | data block 사용 여부(free/used) 추적 |
| | **Inode bitmap** | inode 사용 여부 추적 |
| **Global Metadata** | **Superblock** | FS 설정·크기·레이아웃·상태. **반드시 안정적으로 저장돼야 하는 critical metadata** |

---

### 5. 예제 File System (Very Simple File System, VSFS)

수업은 **가장 단순한 예제 FS**로 설명함. FS마다 저장 방식은 다르고 자유롭게 정의할 수 있지만, 기본 원리는 동일함.

#### 5.1 디스크 레이아웃

- 디스크 블록 **64개** (0~63), **블록 크기 4KB** → 전체 256KB

```
블록번호:  0   1   2   3   4   5   6   7   8 ......................... 63
         [S] [i] [d] [I] [I] [I] [I] [I] [D][D][D] ............... [D]
          │   │   │   └──── Inode Table ──┘ └──── Data Region (56개) ──┘
          │   │   └ Data bitmap
          │   └ Inode bitmap
          └ Superblock
```

| 영역 | 블록 | 개수 |
|---|---|---|
| Superblock (S) | 0 | 1 |
| Inode bitmap (i) | 1 | 1 |
| Data bitmap (d) | 2 | 1 |
| Inode table (I) | 3~7 | **5** |
| Data region (D) | 8~63 | **56** |

> 슬라이드 구성 순서: 처음엔 전부 D → 3~7을 inode block으로 → 1·2를 bitmap으로 → 0을 superblock으로 채워가며 설명함.

#### 5.2 One Inode Block

- inode 하나는 보통 **256 bytes** (FS에 따라 128 bytes)
- 4KB 블록 하나에 들어가는 inode 수: 4096 / 256 = **16개**
- inode block 5개 → 총 inode 수 = 5 × 16 = **80개**

```
inode block 0 (블록 3): inode 0 ~ 15
inode block 1 (블록 4): inode 16 ~ 31
inode block 2 (블록 5): inode 32 ~ 47
inode block 3 (블록 6): inode 48 ~ 63
inode block 4 (블록 7): inode 64 ~ 79
```

---

### 6. Inode

**inode(index node) = 파일의 metadata**. 파일 하나당 inode 하나이며, 각 파일은 **inode number**로 식별됨.

| 필드 | 의미 |
|---|---|
| `type` | 파일인지 디렉터리인지 (regular / dir / symlink …) |
| `uid` | 소유자 |
| `rwx` | 권한(read / write / execute) |
| `size` | 파일 크기(bytes) |
| `blocks` | 할당된 블록 수 |
| `time` | 접근 시간(access) |
| `ctime` | 생성/변경 시간 |
| `links_count` | 이 inode를 가리키는 **경로(이름) 수** — 하드링크로 여러 이름이 같은 inode를 가리킬 수 있음 |
| `addrs[N]` | **N개의 data block 주소(포인터)** |

- `links_count`가 0이 되면(그리고 열려 있는 곳도 없으면) inode와 data block이 해제됨
- **inode에는 파일 이름이 없음.** 이름은 디렉터리 엔트리에 있음

#### 6.1 Quiz ① — Single-level 최대 파일 크기 ★계산 시험

**가정**
- single level (inode의 포인터가 바로 data block을 가리킴)
- 256-byte inode, **전부 포인터로 사용**한다고 가정
- 주소(포인터) 크기 4 bytes, 블록 4KB

**풀이**
1. inode 하나에 넣을 수 있는 포인터 수 = 256 B / 4 B = **64개**
2. 이론적 최대 크기 = 64 × 4KB = **256KB**
3. 하지만 이 FS의 data block은 **56개뿐** → 실제 최대 = 56 × 4KB = **224KB**

> 핵심: 파일 최대 크기는 **inode 자료구조(포인터 개수)** 로 제한될 수도 있고, **디스크 자체 크기(데이터 블록 수)** 로 제한될 수도 있음. 둘 중 작은 값이 실제 한계임.
>
> 256KB짜리 파일밖에 못 만든다면 실사용 불가 → 그래서 indirect 구조가 필요함.

---

### 7. Inode Data Structure — Multi-level Index

#### 7.1 Direct pointer만 사용 (single level)

```
inode ─┬─> data
       ├─> data
       ├─> data
       └─> data
```
- 단순하지만 inode 크기만큼만 포인터를 둘 수 있어 파일 크기 제한이 큼

#### 7.2 Indirect pointer 사용

```
inode ─┬─> indirect ─┬─> data ... (1024개)
       ├─> indirect ─┼─> data ...
       ├─> indirect ─┼─> data ...
       └─> indirect ─┴─> data ...
```
- **indirect block**: data block 주소들만 담고 있는 블록
- **indirect block은 일반 data block 영역에 저장됨** (별도 영역이 아님)
- 4KB indirect block 하나에 들어가는 포인터 = 4096 / 4 = **1024개**
- indirect block 하나가 커버하는 데이터 = 1024 × 4KB = **4MB**

**예: inode가 indirect pointer 4개를 가진 경우 (수업 그림)**
- 4 × 1024 × 4KB = 4 × 4MB = **16MB**
- 단점: 파일이 커질수록 데이터 하나를 읽기 위해 **디스크를 여러 번 접근**해야 함 (inode → indirect → data)

#### 7.3 Hybrid (Direct + Indirect) — 작은 파일 최적화

> "What if we want to optimize for small files?"

```
inode ─┬─> data      ┐
       ├─> data      ├ direct: 작은 파일은 여기서 끝 (Better for small files)
       ├─> data      ┘
       └─> indirect ─┬─> data ... → 큰 파일(BIG)일 때만 사용
                     └─> data ...
```
- 대부분의 파일은 작음 → **direct pointer로 바로 접근** (추가 I/O 없음)
- 큰 파일만 indirect를 거침 → 큰 파일도 지원
- 실제 FS(ext2/ext3)가 쓰는 방식임

#### 7.4 Indexed Allocation (UNIX inode 구조)

```
inode
 ├ mode, owners, timestamps, size, block count
 ├ direct blocks ×12 ──────────────> Data
 ├ single indirect ──> [ptr] ──────> Data
 ├ double indirect ──> [ptr] ─> [ptr] ─> Data
 └ triple indirect ──> [ptr] ─> [ptr] ─> [ptr] ─> Data
```
- 작은 파일은 별도 index block이 필요 없음 (direct만 사용)
- single indirect: 데이터 블록 주소를 담은 블록을 가리킴
- double indirect: "주소 블록들의 주소"를 담은 블록을 가리킴
- triple indirect: 한 단계 더

**보충 계산 (블록 4KB, 포인터 4B → 블록당 포인터 1024개, ext2 기준 direct 12개)**

| 단계 | 블록 수 | 커버 용량 |
|---|---|---|
| Direct 12개 | 12 | 48KB |
| Single indirect | 1024 | 4MB |
| Double indirect | 1024² ≈ 100만 | 4GB |
| Triple indirect | 1024³ ≈ 10억 | 4TB |
| **합계** | | **≈ 4TB** |

---

### 8. Inode 위치 계산 (Byte Offset) ★계산 시험

inode number만 알면 **inode의 디스크 위치를 바로 계산**할 수 있음.

```
inode 주소 = inode table 시작 주소 + (inode number × inode 크기)
```

예제 FS: inode table 시작 = 블록 3 = 3 × 4KB = **12KB (12288 B)**, inode 크기 256B

| inode # | offset (table 내) | 디스크 byte 주소 | 위치 |
|---|---|---|---|
| **0** | 0 × 256 = 0 | 12KB = **12288** | 블록 3 (iblock 0) 맨 앞 |
| **4** | 4 × 256 = 1024 (1KB) | 12KB + 1KB = **13KB = 13312** | 블록 3 (iblock 0) |
| **32** | 32 × 256 = 8192 (8KB) | 12KB + 8KB = **20KB = 20480** | 블록 5 (iblock 2) 맨 앞 |
| **40** | 40 × 256 = 10240 (10KB) | 12KB + 10KB = **22KB = 22528** | 블록 5 (iblock 2) |

**블록 번호까지 구하기**
- inode block 번호 = ⌊inode# / 16⌋ → inode table 내 블록
- 디스크 블록 = 3 + ⌊inode# / 16⌋
- 예: inode 40 → ⌊40/16⌋ = 2 → 디스크 블록 5, 블록 안에서 (40 mod 16) × 256 = 8 × 256 = 2048B 위치

> HDD는 sector(512B) 단위로 읽으므로 실제로는 sector 번호 = (블록 주소) / 512 로 계산해서 해당 sector를 읽음.

---

### 9. Free Space 관리 — Bitmap

**질문**: 빈 data block이나 빈 inode를 어떻게 찾나? → 할당/해제를 빠르게 하려면 미사용 자원을 효율적으로 추적해야 함

| 방식 | 설명 |
|---|---|
| Free List | 빈 블록들을 linked list로 연결 |
| **Bitmap** | 객체 하나당 1 bit (0 = free, 1 = used) |

- **Inode bitmap (블록 1)**: 각 inode의 사용 여부를 0/1 bit로 표시
- **Data bitmap (블록 2)**: 각 data block의 사용 여부를 0/1 bit로 표시
- 예제 FS에서는 inode 80개, data 56개뿐이라 4KB(=32,768 bit) bitmap 블록은 충분하고도 남음

#### 9.1 최대 파일 개수 ★

- 파일 하나당 inode 하나 필요 → inode 개수 = **80개** → 최대 80개
- 그런데 파일 하나가 **최소 data block 1개**를 쓴다고 하면 data block은 **56개** → 실제 최대 **56개**
- 즉 최대 파일 수 = min(inode 수, data block 수) = **56개** (0-byte 파일만 있다면 inode 한계인 80개까지 가능)
- 루프를 돌며 파일을 계속 create하면 어느 순간 FS가 "더 이상 파일을 만들 수 없음(No space left)" 에러를 냄 — **data block이 남아 있어도 inode가 소진되면** 파일을 못 만듦 (`df -i`로 확인)

---

### 10. Inconsistency와 fsck

**문제**: 파일 하나를 만들거나 쓸 때 여러 metadata 구조(inode, data bitmap, inode bitmap)를 **모두** 갱신해야 함. 그 사이에 crash/정전이 나면 **일부만 반영된 상태**가 됨.

**예시**
- data bitmap에는 "사용 중"인데, 어떤 inode도 그 블록을 가리키지 않음 → **lost block (공간 누수)**
- inode는 블록을 가리키는데 bitmap은 "free" → 다른 파일에 **이중 할당(double allocation)** 될 위험

**fsck (file system checker)의 역할**
1. FS metadata 전체를 스캔
2. 불일치 탐지 (double allocation, lost blocks 등)
3. 일관된(consistent) 상태로 복구

> 한계: 디스크 전체를 스캔해야 해서 느림 → 이후 journaling 등으로 발전 (Reliability 과제)

---

### 11. Superblock

FS가 동작하려면 기본 설정 정보가 필요함.

**Superblock에 저장되는 것**
- **Block size** (몇 KB로 포맷했는지)
- **inode 개수** (예제에서는 80개)
- **inode table 시작 위치** (예제에서는 블록 3부터)
- data block 개수, data region 시작 위치, 기타 FS 파라미터

**Mount 과정**
- OS는 FS를 mount할 때 **superblock을 가장 먼저 읽음**
- superblock 정보로 메모리 내 FS 자료구조를 초기화함
- **유효한 superblock이 없으면 mount 자체가 불가능**함

#### 11.1 Superblock의 중요성

- superblock(0번 블록)이 깨지면 그 뒤 구조(bitmap, inode table)가 **어디 있는지 알 수 없음** → 데이터가 멀쩡해도 접근 불가
- **Quick Format**: 데이터는 그대로 두고 **superblock(과 bitmap 등 metadata)만 새로 씀** → 그래서 빠름
  - 데이터 블록은 남아 있으므로, 복구 프로그램이 블록들을 스캔하며 inode table 위치 등을 **추측·조합(reverse engineering)** 해서 복구에 성공하기도 함
- 이렇게 중요하기 때문에 실제 FS(ext2/3/4)는 **superblock 사본(backup superblock)** 을 여러 block group에 나눠 저장함 → 원본이 깨지면 사본으로 복구 (`e2fsck -b <backup 위치>`)

---

### 12. Directories

#### 12.1 기본 원리

- **디렉터리도 특수한 의미를 가진 파일**임 → 디렉터리도 inode를 가짐
- 디렉터리의 내용(content) = **디렉터리 엔트리 목록** = (이름, inode 번호) 쌍
- 디렉터리 엔트리는 **data block에 저장**됨. 큰 디렉터리는 여러 data block에 걸침
- inode의 **type 비트**로 디렉터리와 일반 파일을 구분함

디렉터리 하나를 위해 FS가 저장해야 하는 것: **① 디렉터리 metadata(inode) ② inode 번호 ③ 디렉터리 콘텐츠(엔트리들)**

**파일 찾는 순서**: 디렉터리 inode → 디렉터리 data(엔트리) → 파일 이름으로 inode 번호 획득 → 파일 inode → 파일 data
→ 디렉터리를 거쳐야 항상 파일을 찾을 수 있음

#### 12.2 예시: 디렉터리 엔트리

| valid | name | inode |
|---|---|---|
| 1 | `.` | 134 (자기 자신) |
| 1 | `..` | 35 (부모) |
| 1 | `foo` | 80 |
| 1 | `bar` | 23 |

- `unlink("foo")` → 해당 엔트리를 무효화(valid = 0), inode 80의 `links_count` 감소

#### 12.3 Directory Entry 조직 방식

| 방식 | 특징 | 탐색 |
|---|---|---|
| **Linear list** | 단순 (inode, name) 쌍 나열. 오버헤드 작음 | 순차 탐색 O(n) — 작은 디렉터리에 효율적 |
| **Tree (B-tree 등)** | 큰 디렉터리 확장성 개선 | O(log n) |

**ext4 구현**
- 작은 디렉터리: **linear list** 로 저장 (오버헤드 최소)
- 큰 디렉터리: **HTree** (hash 기반 B-tree 유사 구조) — 파일명을 hash해서 index block으로 찾아감 → 적은 metadata로 빠른 lookup

#### 12.4 ext4 디렉터리 엔트리 구조 예시

| offset | inode | rec_len | name_len | file_type | name |
|---|---|---|---|---|---|
| 0 | 21 | 12 | 1 | 2 | `.` |
| 12 | 22 | 12 | 2 | 2 | `..` |
| 24 | 53 | 16 | 5 | 2 | `home1` |
| 40 | 67 | **28** | 3 | 2 | `usr` |
| 52 | **0** | 16 | 7 | 1 | `oldfile` |
| 68 | 34 | 12 | 4 | 2 | `sbin` |

- `rec_len`: 이 엔트리의 길이(= 다음 엔트리까지 거리). 이름은 4바이트 단위로 `\0` 패딩
- `name_len`: 실제 이름 길이, `file_type`: 1 = regular file, 2 = directory
- **삭제 처리**: `oldfile`이 삭제되면 inode를 **0**으로 표시하고, 앞 엔트리 `usr`의 rec_len을 12 → **28**(12+16)로 늘려 삭제된 엔트리를 건너뛰게 함 → 40 + 28 = 68에서 다음 엔트리(`sbin`)가 시작됨

#### 12.5 디렉터리 연산 (UNIX)

| 연산 | 내용 |
|---|---|
| Search | 이름으로 엔트리 lookup |
| Create | 새 엔트리 삽입 |
| Delete | 엔트리 제거 |
| List | 모든 엔트리 나열 |
| Rename | 엔트리 이름 변경 |
| Traverse | 전체 디렉터리 구조 순회 (백업에 유용) |

> **Key Insight**: 디렉터리 연산은 **metadata-intensive** 하며, 대규모 시스템에서는 metadata 연산 수가 data I/O보다 훨씬 많아 **성능을 좌우**함. (AI 학습 데이터처럼 작은 파일이 수백만 개인 경우 특히 문제)

---

### 13. On-Disk Structures 정리

```
Super Block ── FS 전체 설정 (블록 크기, inode 수, 각 영역 시작 위치)
Inode Bitmap ─ inode 사용 여부
Data Bitmap ── data block 사용 여부
Inode Table ── 파일별 metadata + 블록 포인터
Data Block ─── 파일 내용 / 디렉터리 엔트리 / indirect block
```

---

## Part 2. Access Methods (슬라이드 기반 예습)

### 14. 파일 연산 (POSIX)

`create`, `open`, `read`, `write`, `close` — 단순한 API지만 내부적으로 복잡한 metadata/data 경로를 발생시킴.

| 연산 | 하는 일 | 주요 비용 |
|---|---|---|
| **create()** | 새 inode 할당 → metadata 초기화(type, 권한, 시간) → 디렉터리에 (이름 → inode#) 엔트리 삽입 → 디렉터리·inode metadata 디스크 갱신 | **Metadata + 디렉터리 갱신** |
| **open()** | path traversal (디렉터리 lookup → inode lookup) → 권한 검사 → 커널에 file descriptor 할당. 큰 디렉터리는 metadata 병목 | **Directory lookup** |
| **read()** | page cache 확인 (hit → 메모리 복사, miss → 디스크 I/O) → file offset → data block 변환. metadata 비용은 open()에서 이미 치름 | **Data I/O** |
| **write()** | (파일이 커지면) data block 할당 → inode size·timestamp 갱신 → dirty page 표시 → 모드에 따라 즉시/지연 영속화 | **Data + metadata** |
| **close()** | fd 해제, reference count 감소. 실제 디스크 I/O는 나중(비동기 write-back). **close()는 durability를 보장하지 않음** | **Minimal** |

> durability가 필요하면 `fsync()`를 호출해야 함.

### 15. 연산별 디스크 I/O 타임라인 (`/foo/bar`)

#### 15.1 open("/foo/bar")
| 순서 | 대상 | 이유 |
|---|---|---|
| 1 | root inode **read** | 루트 디렉터리 위치 확인 (root inode 번호는 보통 2로 고정) |
| 2 | root data **read** | `foo`의 inode 번호 찾기 |
| 3 | foo inode **read** | |
| 4 | foo data **read** | `bar`의 inode 번호 찾기 |
| 5 | bar inode **read** | 권한 확인, 메모리에 올림 |

→ 경로 깊이만큼 I/O가 늘어남. 데이터 블록(bar data)은 읽지 않음

#### 15.2 create("/foo/bar")
| 순서 | 대상 |
|---|---|
| 1~4 | root inode read → root data read → foo inode read → foo data read (경로 탐색) |
| 5 | **inode bitmap read** (빈 inode 찾기) |
| 6 | **inode bitmap write** (할당 표시) |
| 7 | **foo data write** (`bar` 엔트리 추가) |
| 8 | bar inode read |
| 9 | **bar inode write** (초기화) |
| 10 | **foo inode write** (디렉터리 크기·시간 갱신) |

→ 파일 하나 만드는 데 I/O 10번. create가 비싼 이유임

#### 15.3 write("/foo/bar") — 이미 open된 상태, 새 블록 할당
| 순서 | 대상 |
|---|---|
| 1 | bar inode read |
| 2 | **data bitmap read** |
| 3 | **data bitmap write** |
| 4 | **bar data write** |
| 5 | **bar inode write** (포인터·크기 갱신) |

→ 블록 하나 쓰는 데 I/O 5번 (read 2 + write 3)

#### 15.4 read("/foo/bar") — 이미 open된 상태
| 순서 | 대상 |
|---|---|
| 1 | bar inode read (블록 위치 확인) |
| 2 | bar data read |
| 3 | bar inode **write** (access time 갱신) |

#### 15.5 close("/foo/bar")
- **디스크에서 할 일 없음** (nothing to do on disk!)

### 16. Efficiency — Caching & Buffering

**질문**: 기본 연산마다 I/O가 이렇게 많은데 어떻게 줄이나? → **Caching**

| 기법 | 내용 |
|---|---|
| **Read caching** | 자주 접근하는 데이터(inode, 디렉터리, 데이터)를 메모리에 캐시해 반복 디스크 read 최소화 |
| **Write buffering** | write를 메모리에 잠시 모았다가 한 번에 내려씀 → I/O 병합(coalesce), 스케줄링 최적화, 쓰다가 지운 파일은 아예 안 써도 됨 |

#### 16.1 Page Cache (Linux)

- **가상 메모리와 buffer cache를 통합(merge)** 함
- 물리 page frame 하나가 **프로세스 주소 공간의 page** 또는 **파일 블록** 어느 쪽이든 담을 수 있음
  - 프로세스는 **page table**로 virtual page → page frame 매핑
  - 파일 I/O는 **`address_space`** 구조체로 file block → physical page frame 매핑
- **Dynamic partitioning**: 메모리를 프로세스용/파일 캐시용으로 고정 분할하지 않고 상황에 따라 동적으로 나눠 씀
- 트레이드오프: write buffering을 오래 할수록 성능은 좋지만 crash 시 손실 위험 증가 (보통 5~30초 후 write-back)

---

## 17. 전체 요약

- File System은 **naming & hierarchy, storage mapping(logical offset → physical block), access control, persistence & reliability** 를 제공함
- 파일 = **data + metadata** (size, owner, permissions, timestamps, block pointers)
- On-disk 구조: **Superblock, Inode/Data bitmap, Inode table, Data blocks, Directories**
- 핵심 설계 과제: **블록 할당과 인덱싱, free space 관리, locality와 fragmentation, reliability**
- 성능은 **caching & buffering** 에 크게 좌우됨. page cache가 파일 I/O와 가상 메모리를 연결함

---

## 18. 계산 문제 공식 모음

| 구하는 것 | 공식 | 예제 FS 값 |
|---|---|---|
| 블록당 inode 수 | 블록 크기 / inode 크기 | 4096 / 256 = 16 |
| 전체 inode 수 | inode block 수 × 블록당 inode 수 | 5 × 16 = 80 |
| inode당 포인터 수 (전부 포인터 가정) | inode 크기 / 주소 크기 | 256 / 4 = 64 |
| single-level 최대 파일 크기 | min(포인터 수, data block 수) × 블록 크기 | min(64, 56) × 4KB = 224KB |
| indirect block당 포인터 수 | 블록 크기 / 주소 크기 | 4096 / 4 = 1024 |
| indirect 1개 커버 용량 | 1024 × 4KB | 4MB |
| inode byte 주소 | inode table 시작 + inode# × inode 크기 | inode 32 → 12KB + 8KB = 20KB |
| inode가 들어있는 블록 | table 시작 블록 + ⌊inode# / 16⌋ | inode 40 → 3 + 2 = 블록 5 |
| 최대 파일 개수 | min(inode 수, data block 수) (파일당 최소 1블록 가정) | min(80, 56) = 56 |

---

## 19. 셀프 체크리스트

- [ ] File System이 제공하는 4가지(Naming, Organization, Storage mapping, Access control)를 말할 수 있다
- [ ] On-Disk Structure와 Software Management Layer의 차이를 설명할 수 있다
- [ ] 블록 크기가 클 때/작을 때의 장단점(internal fragmentation, throughput)을 설명할 수 있다
- [ ] 예제 FS의 64블록 레이아웃(S, i, d, I×5, D×56)을 그릴 수 있다
- [ ] inode 필드(type, uid, rwx, size, blocks, time, ctime, links_count, addrs[N])를 나열할 수 있다
- [ ] single-level 최대 파일 크기가 256KB가 아니라 224KB인 이유를 설명할 수 있다
- [ ] indirect pointer 4개일 때 최대 16MB가 되는 계산을 할 수 있다
- [ ] Hybrid(direct + indirect)가 작은 파일에 유리한 이유를 설명할 수 있다
- [ ] inode 번호 0, 4, 32, 40의 byte offset을 계산할 수 있다
- [ ] 최대 파일 개수가 80이 아니라 56인 이유를 설명할 수 있다
- [ ] inode bitmap과 data bitmap의 역할, 그리고 crash 시 불일치와 fsck의 역할을 설명할 수 있다
- [ ] superblock에 저장되는 정보와, superblock이 깨지면 왜 mount가 불가능한지 설명할 수 있다
- [ ] Quick Format 후 데이터 복구가 가능한 이유와 backup superblock의 존재 이유를 설명할 수 있다
- [ ] ext4 디렉터리 엔트리에서 삭제가 rec_len 확장으로 처리되는 방식을 설명할 수 있다
- [ ] create / open / write / read / close 각각의 디스크 I/O 순서를 말할 수 있다
- [ ] close()가 durability를 보장하지 않는 이유와 page cache의 역할을 설명할 수 있다

---

## 용어 정리

| 용어 | 뜻 |
|---|---|
| inode (index node) | 파일 metadata + 데이터 블록 포인터를 담는 구조체 |
| inode number | inode table 내 인덱스. 파일의 실제 식별자 |
| direct / indirect pointer | 데이터 블록을 직접 / 주소 블록을 거쳐 가리키는 포인터 |
| superblock | FS 전체 설정 정보 블록. mount 시 가장 먼저 읽음 |
| bitmap | 객체별 사용 여부를 1bit로 표시하는 할당 구조 |
| directory entry (dentry) | (이름, inode 번호) 쌍 |
| links_count | inode를 가리키는 하드링크(이름) 개수 |
| fsck | FS consistency 검사·복구 도구 |
| internal fragmentation | 블록 내부의 남는 공간 낭비 |
| HTree | ext4 대형 디렉터리용 hash 기반 트리 인덱스 |
| page cache | 파일 블록을 메모리에 캐시하는 Linux 통합 캐시 |
| write-back | 변경을 메모리에 두었다가 나중에 디스크에 반영하는 방식 |