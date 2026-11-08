# AI 데이터 시스템 및 인프라 — File System (2): Superblock, inode, Indexed Allocation, Directory

> 2026.11.07 강의 / 강의자료 `5. File System` p.28~35
> 이번 강의 범위: On-disk 자료구조(Superblock, bitmap, inode table) → inode 위치 계산 → Indexed Allocation(direct/indirect) → Directory 구조와 연산 → 일관성(Consistency) 문제 → 대규모 시스템(AI 학습, HPC)에서 디렉터리 연산이 병목이 되는 이유

---

## 0. 큰 그림

- 스토리지는 **block device**임. 동일한 크기의 block들의 배열이고, 파일 시스템은 이 block들 위에 자기만의 **on-disk 자료구조**를 얹어서 "파일"과 "디렉터리"라는 추상화를 만든다.
- 어떤 block을 어떤 용도로 쓰는지(layout)는 **파일 시스템마다 다르다**. 이번 강의는 OSTEP의 VSFS(Very Simple File System) 형태를 기준으로 설명함.
- 스토리지는 **persistent media**라서, 한 번 써진 내용은 전원이 꺼져도 남는다 → 그래서 **consistency(일관성)** 가 매우 중요해진다. (DRAM 위 자료구조는 꺼지면 사라지므로 이런 고민을 안 함)

---

## 1. On-disk Layout과 Superblock (p.28)

### 1.1 64개 block 예시 레이아웃

```
block:  0   1   2   3   4   5   6   7   8 ............................. 63
       [S] [i] [d] [I] [I] [I] [I] [I] [D][D][D] ...................... [D]
```

| 기호 | 이름 | 역할 |
|---|---|---|
| **S** | Superblock | 파일 시스템 전체에 대한 메타데이터 |
| **i** | inode bitmap (i-bmap) | inode table의 각 inode가 사용 중(1)/free(0)인지 표시 |
| **d** | data bitmap (d-bmap) | data region의 각 block(D)이 사용 중/free인지 표시 |
| **I** | inode table | 실제 inode들이 저장되는 영역 (block 3~7) |
| **D** | data region | 실제 파일 내용이 저장되는 block들 (block 8~63) |

- 대문자 **D**가 실제 데이터 block, 소문자 **d**는 D 중 어떤 게 쓰이고 있는지 체크하는 bitmap임. 대문자 **I**는 inode table, 소문자 **i**는 inode의 사용 여부 bitmap임.
- inode는 block보다 작다(예: inode 256B, block 4KB) → **block 하나에 inode 여러 개**가 들어간다. (4KB / 256B = block당 16개)

### 1.2 Superblock

- 파일 시스템의 **맨 앞(block 0)** 에 위치. mount 시 OS가 가장 먼저 읽는 block임.
- 담고 있는 정보 (예):
  - 이 파일 시스템에 inode가 몇 개, data block이 몇 개 있는지
  - inode table이 어디서 시작하는지 (예: block 3)
  - block size
  - magic number (이 파일 시스템의 종류를 식별)
- 그림의 화살표처럼 **Superblock → i-bmap → d-bmap → inode table** 의 위치를 알려주는 출발점 역할을 한다.

### 1.3 Quick Format

- **Quick Format은 Superblock(과 bitmap 등 메타데이터)만 새로 초기화**하고, data block의 내용은 지우지 않는다.
- 그래서 빠르고, 대신 **기존 data는 디스크에 그대로 남아 있어 복구가 가능**함.
- 반대로 Full Format은 전체 영역을 덮어쓰기/검사하므로 느리다.

---

## 2. inode와 위치 계산 (p.29)

### 2.1 기본 개념

- **inode(index node)**: 파일 하나의 메타데이터를 담은 자료구조. 파일 이름은 inode에 없다(이름은 디렉터리에 있음).
- 각 파일은 **inode number(i-number)** 로 식별된다.
- inode number만 알면 파일 시스템은 그 inode가 **디스크의 정확히 어디에 있는지 계산**할 수 있다.

### 2.2 위치 계산 방법

1. inode number로 **inode table 내부의 offset** 계산: `offset = inumber × sizeof(inode)`
2. 그 offset에 **inode table 시작 주소**를 더한다.

### 2.3 예제: inode number = 32

전제: block 4KB, inode 256B, inode table 시작 = 12KB (block 3)

```
offset   = 32 × 256 B = 8192 B = 8 KB
주소     = 12 KB + 8 KB = 20 KB
```

```
0KB    4KB      8KB      12KB     16KB     20KB     24KB     28KB     32KB
| Super | i-bmap | d-bmap | iblk 0 | iblk 1 | iblk 2 | iblk 3 | iblk 4 |
                           0~15     16~31    32~47    48~63    64~79
                                             ↑ inode 32 = iblock 2의 첫 번째
```

- iblock 하나에 inode 16개 → 32 / 16 = 2 → **iblock 2의 0번째 칸**. 그림의 파란 칸이 inode 32임.
- 디스크는 실제로 **sector(보통 512B)** 단위로 접근하므로 sector 번호로 바꾸면:

```
blk    = (inumber × sizeof(inode)) / blockSize        = (32×256)/4096 = 2
sector = ((blk × blockSize) + inodeStartAddr) / sectorSize
       = (2×4096 + 12288) / 512 = 20480 / 512 = 40
```

→ inode 32는 **sector 40**에 있다. (단, inode 하나만 읽는 게 아니라 그 inode가 포함된 block/sector를 통째로 읽게 됨)

---

## 3. File Structure: Indexed Allocation (p.30)

### 3.1 inode의 구성

| 필드 | 의미 |
|---|---|
| mode | 파일 타입(일반 파일/디렉터리 등) + 권한(rwx) |
| owners (2) | 소유자 user id, group id |
| timestamps (3) | 접근(atime)/수정(mtime)/상태변경(ctime) 시간 |
| size block | 파일 크기 / 사용 중인 block 수 |
| count | **link count** — 이 inode를 가리키는 디렉터리 엔트리(hard link) 수 |
| direct blocks | data block 주소를 직접 가리키는 포인터들 (ext2 기준 12개) |
| single indirect | indirect block 1단계 |
| double indirect | indirect block 2단계 |
| triple indirect | indirect block 3단계 |

### 3.2 Direct → Indirect로 확장하는 이유

- **Direct block**: inode 안의 포인터가 data block 주소를 **바로** 가리킴.
  - 작은 파일은 별도 index block이 필요 없다 → 대부분의 파일이 작다는 관찰을 반영한 설계.
  - 하지만 inode 크기(예: 256B)가 정해져 있으니 포인터 개수에 한계가 있고, 표현 가능한 파일 크기 = **포인터 개수 × block 크기**로 제한된다.
- **Single indirect**: inode의 포인터가 **indirect block(index block)** 을 가리키고, 그 block 안에 data block 주소들이 가득 들어 있음.
  - indirect block은 **실제 데이터가 아니라 데이터의 위치 정보**를 저장하는 block이다.
  - indirect block은 따로 영역이 있는 게 아니라 **data region(대문자 D)의 block을 빌려서** 쓴다.
- **Double indirect**: single로도 부족하면 indirection을 두 번 → 포인터 block을 가리키는 포인터 block.
- **Triple indirect**: depth가 3으로 깊어진다.
- 즉 **multi-level index(불균형 트리)** 구조임. 작은 파일은 빠르게(direct), 큰 파일도 표현 가능(indirect).
- 단점: 큰 파일의 뒷부분을 읽으려면 indirect block들을 차례로 더 읽어야 하므로 **추가 I/O**가 생긴다.

### 3.3 최대 파일 크기 계산 (시험 대비)

전제: block 4KB, 디스크 주소(포인터) 4B, direct 12개

- indirect block 하나에 들어가는 포인터 수 = 4KB / 4B = **1024개**

| 단계 | block 수 | 크기 |
|---|---|---|
| direct | 12 | 12 × 4KB = **48 KB** |
| single indirect | 1024 | 1024 × 4KB = **4 MB** |
| double indirect | 1024² | 1024² × 4KB = **4 GB** |
| triple indirect | 1024³ | 1024³ × 4KB = **4 TB** |
| **합계** | | ≈ 4TB + 4GB + 4MB + 48KB |

- 일반식: `최대 크기 = (D + P + P² + P³) × B` (D = direct 개수, P = block당 포인터 수 = B/포인터크기, B = block 크기)
- 참고: ext4는 이런 포인터 방식 대신 **extent(시작 block, 길이)** 방식을 주로 사용해 연속된 큰 파일을 적은 메타데이터로 표현함.

---

## 4. Directories (p.31)

### 4.1 공통 설계 원칙

- 디렉터리 구조는 파일 시스템마다 다르지만 공통 원칙은 같다.
  - **디렉터리도 파일이다** — 단, 특별한 의미(semantics)를 가진 파일.
  - 디렉터리의 내용(= 디렉터리 엔트리들)은 **data block**에 저장된다.
  - 큰 디렉터리는 **여러 data block**에 걸쳐 저장된다.
  - 일반 파일인지 디렉터리인지는 **inode의 type bit**(mode 필드)로 구분한다.
- 디렉터리의 내용 = **(이름, inode number) 쌍의 목록**.

### 4.2 예시 디렉터리 엔트리

| valid | name | inode |
|---|---|---|
| 1 | `.` | 134 |
| 1 | `..` | 35 |
| 1 | foo | 80 |
| 1 | bar | 23 |

- `.` = 자기 자신(이 디렉터리의 inode가 134), `..` = 부모 디렉터리(inode 35).
- 디렉터리를 보면 "foo라는 파일은 inode 80번"이라는 걸 알 수 있다. 실제 내용은 inode 80의 direct/indirect 포인터를 따라가서 읽는다.
- 부모 디렉터리는 자식(파일/디렉터리)의 이름과 inode를 알고 있다. 예: `/` 의 내용에 `user`가 있고, `user`의 내용에 `workspace`가 있는 식.

### 4.3 경로 탐색 (Path Lookup)

`/user/workspace/a.txt` 를 여는 과정:

1. root 디렉터리의 inode를 읽음 (root inode 번호는 미리 정해져 있음, 예: ext 계열은 2번)
2. root의 data block을 읽어 `user` 엔트리 → inode 번호 획득
3. `user`의 inode 읽기 → data block 읽기 → `workspace` 엔트리 찾기
4. `workspace`의 inode → data block → `a.txt` 엔트리 찾기
5. `a.txt`의 inode 읽기 → 이제 실제 data block 접근 가능

→ 경로가 깊을수록 **inode + 디렉터리 data block 읽기가 단계마다 반복**된다. 그래서 디렉터리 연산은 메타데이터 I/O를 많이 일으킨다.

### 4.4 unlink("foo") — 파일 삭제의 실체

- 삭제(unlink)는 **부모 디렉터리에서 엔트리를 제거**하는 것임 (valid=0 처리 또는 엔트리 제거).
- 그리고 inode 80의 **link count를 1 감소**. 0이 되면 inode bitmap과 data bitmap에서 해당 inode·data block을 **free로 표시**한다.
- **하지만 data block(D)의 실제 내용은 지우지 않는다.** inode 80 자체도 inode table 어딘가에 남아 있다.
- → 이름은 몰라도 inode 80을 어떤 방법으로든 읽으면, 거기 남아있는 direct/indirect 포인터를 따라가 **원래 내용을 복원할 수 있다 = 디지털 포렌식(content forensics)** 의 원리.
- 휴지통 비우기를 해도 "사라진 것처럼" 보이는 이유는 **디렉터리에서 엔트리만 사라졌기 때문**이다.

### 4.5 보안 관점 — 완전 삭제의 비용

- 내용을 확실히 지우려면 data block을 실제로 덮어써야 한다(secure erase, 예: `shred`). → 추가 write가 발생해 비용이 크다.
- 암호화된 스토리지라면 **crypto erase**(암호화 키만 폐기해서 데이터를 못 읽게 만듦)로 빠르게 무력화하는 방법도 있음.
- 다만 공격이 있을지도 모르는 상황에서 매번 이런 삭제를 수행하면 비싼 자원(I/O, SSD 수명 등)을 낭비하게 된다 → **보안은 성능/비용과의 trade-off**이고, 기능을 먼저 만들고 그다음에 따라오는 이슈라는 관점.
- AI 시스템은 데이터·모델·스토리지 계층이 많아서 **공격 표면(attack surface)이 매우 넓다** → AI 보안에서도 스토리지에 대한 이해가 필요하다.

---

## 5. Directory Entry Organizations (p.32)

### 5.1 Linear List

- 단순한 **(inode, name) 쌍**을 나열.
- 찾을 때 **순차 탐색(sequential search)** → O(n).
- 엔트리가 적은 작은 디렉터리에서는 단순하고 효율적.

### 5.2 Tree 기반 구조 (예: B-tree)

- 큰 디렉터리에서 **확장성(scalability)** 향상.
- lookup 지연을 **O(n) → O(log n)** 으로 감소.

### 5.3 예: ext4의 디렉터리 구현

- **작은 디렉터리**: linear list로 저장 → 오버헤드 최소.
- **큰 디렉터리**: **HTree(hashed B-tree 유사 구조)** 사용
  - 파일 이름을 **hash** → 그 hash 값으로 **index block**을 찾아감
  - 적은 메타데이터 오버헤드로 빠른 lookup 가능

### 5.4 파일 생성(create) 시 왜 탐색이 필요한가

- 파일을 만들 때는 먼저 **같은 이름의 파일이 이미 있는지** 확인해야 한다 (있으면 생성 실패 또는 기존 파일 open).
- 즉 create = **lookup + insert**. linear list면 전체를 순차 탐색하고, tree/hash면 빠르게 확인.

### 5.5 메모리에 올라온 디렉터리 (dentry cache)

- 디스크(device) 안에서는 디렉터리 엔트리가 **block 단위**로 저장된다.
- 이것이 메모리로 올라오면 리눅스에서는 **dentry cache(directory entry cache, dcache)** 로 관리된다.
- 인메모리 자료구조로는 linear table, linked list, tree, hash table 등을 쓸 수 있다 — 자료구조 수업에서 배운 내용이 여기서 그대로 쓰이는 것.

---

## 6. Directory Structure Example: EXT4 (p.33)

ext4(ext2 계열) 디렉터리 엔트리의 실제 on-disk 형식:

| 필드 | 크기 | 의미 |
|---|---|---|
| inode | 4B | inode number (0이면 **사용하지 않는 엔트리**) |
| rec_len | 2B | 이 엔트리의 시작부터 **다음 엔트리까지의 거리(byte)** |
| name_len | 1B | 이름 길이 |
| file_type | 1B | 1 = 일반 파일, 2 = 디렉터리 (그 외 심볼릭 링크 등) |
| name | 가변 | 파일 이름, **4B 배수로 padding**(`\0`) |

예제:

| offset | inode | rec_len | name_len | file_type | name |
|---|---|---|---|---|---|
| 0 | 21 | 12 | 1 | 2 | `.` |
| 12 | 22 | 12 | 2 | 2 | `..` |
| 24 | 53 | 16 | 5 | 2 | `home1` |
| 40 | 67 | **28** | 3 | 2 | `usr` |
| 52 | **0** | 16 | 7 | 1 | `oldfile` |
| 68 | 34 | 12 | 4 | 2 | `sbin` |

읽는 법:

- 엔트리 최소 크기 = 고정부 8B(inode 4 + rec_len 2 + name_len 1 + file_type 1) + 이름(4B 배수로 올림).
  - `.` → 8 + 4 = 12, `home1`(5글자) → 8 + 8 = 16, `sbin` → 8 + 4 = 12
- 다음 엔트리 offset = 현재 offset + rec_len (0 → 12 → 24 → 40 → 68)
- **삭제된 엔트리 처리**: `oldfile`이 삭제되면서
  - `oldfile`의 inode가 **0**으로 바뀌었고,
  - 바로 앞 엔트리 `usr`의 rec_len이 원래 12에서 **28(=12+16)** 로 늘어나 `oldfile` 자리를 건너뛴다.
  - 그래서 탐색 시 offset 40에서 바로 68로 점프 → `oldfile`은 보이지 않음.
- 하지만 offset 52의 바이트(`oldfile` 이름 등)는 **그대로 남아 있다** → 4.4의 포렌식 이야기와 같은 원리.
- 모든 file_type이 2(디렉터리)이고 `oldfile`만 1(일반 파일)이다.

---

## 7. Tree-Structured Directories (p.34)

- 디렉터리는 **root에서 시작하는 트리** 구조. 그림에서 **사각형은 디렉터리(의 엔트리)**, **동그라미는 파일**임.
- 다른 디렉터리 안에는 **같은 이름이 있어도 된다** (예: `mail`, `find`, `count`, `hex`, `reorder`, `list`, `spell` 등이 여러 곳에 등장).
  - 파일은 이름이 아니라 **경로(path)** 로 유일하게 식별되기 때문.
- 경로 종류
  - **절대 경로(absolute path)**: root부터 (`/spell/mail/prog/list`)
  - **상대 경로(relative path)**: 현재 작업 디렉터리 기준
- 사용자는 디렉터리로 파일을 논리적으로 그룹화할 수 있다.

---

## 8. Operations Performed on a Directory (p.35)

### 8.1 UNIX의 디렉터리 연산

| 연산 | 디렉터리에서 실제로 하는 일 |
|---|---|
| Search for a file (lookup) | 이름으로 디렉터리 엔트리 찾기 |
| Create a file | 새 디렉터리 엔트리 삽입 |
| Delete a file (unlink) | 디렉터리 엔트리 제거 |
| List a directory (`ls`) | 모든 디렉터리 엔트리 나열 |
| Rename a file | 디렉터리 엔트리의 이름 갱신 |

- 이 연산들은 전부 **파일의 내용이 아니라 디렉터리(엔트리)를 바꾸는 연산**이다.
- **Traverse the file system**: 디렉터리 구조 안의 모든 디렉터리와 파일을 체계적으로 방문 → **백업**에 특히 유용.

### 8.2 Key Insight: 디렉터리 연산은 metadata-intensive

- **data-intensive 연산**: `read()`, `write()` — 실제 파일 내용을 읽고 씀. 지금까지 주로 배운 것.
- **metadata-intensive 연산**: lookup, create, delete, list, rename, stat — 실제 데이터는 안 쓰고 inode·bitmap·디렉터리 엔트리만 바꿈.
- **대규모 시스템에서는 메타데이터 연산 수가 데이터 I/O 연산 수보다 훨씬 많고, 전체 성능을 좌우하는 경우가 많다.**

---

## 9. 대규모 시스템에서 디렉터리 연산이 문제가 되는 이유

### 9.1 AI 분산 학습 — Data Parallelism

- **Data parallelism**: 데이터를 N등분해서 **동일한 모델 복제본 N개**가 각자 서로 다른 데이터를 학습하고, 나중에 결과(gradient)를 **평균(averaging)** 해서 모델을 맞추는 기법.
- 학습 데이터는 보통 GPU 서버 로컬이 아니라 **disaggregated된 remote storage**(공유 스토리지)에 있다.
- 이미지 같은 **작은 파일 수백만 개**를 수많은 GPU 노드가 **동시에 open/lookup** 하게 됨
  → 파일 시스템 입장에서는 대량의 병렬 메타데이터 연산이 한꺼번에 몰리는 상황 → **파일 시스템이 버벅거리거나 멈출 수 있다.**
- 전통적인 대응: 파일 시스템을 멈추게 하지 않도록 **사용자에게 가이드라인**을 주는 방식
  - 예) 한 디렉터리에 너무 많은 파일을 두지 않기, 작은 파일들을 큰 파일로 묶기(tar/WebDataset, TFRecord, HDF5 등) 등

### 9.2 HPC 시스템

- HPC는 **compute node가 매우 많다**.
- 각 job은 **데이터 읽기 → 연산 → 결과 저장(checkpoint)** 을 반복한다.
- job마다 실행 시간이 다 다르다.
- 로컬 파일 시스템이 아니라 **네트워크 기반 파일 시스템**이라서, 모든 노드가 하나의 **shared file system**(예: Lustre 같은 병렬 파일 시스템)을 바라본다.
- 수많은 노드가 **같은 디렉터리에 동시에 파일을 create** 하면 그 디렉터리의 엔트리를 갱신하기 위해 lock 경합이 생기고 메타데이터 서버에 부하가 집중된다 → 디렉터리 연산이 병목.

### 9.3 Context Store와 persistence 요구사항 (뒤 강의 예고)

- LLM 서빙의 **context(KV cache)를 저장하는 context store**는 성격이 다르다.
  - context는 사라져도 **다시 계산(recompute)하면 되므로** persistence 요구사항이 크지 않다.
  - 따라서 일반 파일 시스템처럼 무거운 consistency 보장 없이, 이 특성에 맞는 **새로운 context store**가 필요하다는 방향.

---

## 10. Consistency, Redundancy, Crash Consistency

### 10.1 Redundancy

- **redundant**: 같은 정보가 두 군데 이상 있는 것. 꼭 형태가 동일하지 않아도 **같은 정보를 담고 있으면** redundant하다고 한다.
- 파일 시스템 예시
  - data bitmap의 "block 20은 사용 중" ↔ 어떤 inode의 포인터가 block 20을 가리킴
  - inode bitmap의 "inode 80은 사용 중" ↔ 디렉터리 엔트리가 inode 80을 가리킴
- redundancy가 있으면 **둘이 서로 다른 말을 할 때 누가 맞는지** 판단하는 문제가 생긴다.

### 10.2 Crash Consistency Problem

- 파일 하나를 쓰는 것도 실제로는 **여러 구조를 갱신**해야 한다: data block, inode, data bitmap, (새 파일이면) inode bitmap, 디렉터리 엔트리.
- 이 갱신들은 원자적(atomic)이지 않아서, 중간에 **예측할 수 없는 이벤트(unexpected event: 전원 차단, crash)** 가 끼어들면 일부는 갱신되고 일부는 안 된 상태로 디스크에 남는다.
- 예
  - 파일 내용과 inode는 써졌는데 **디렉터리 엔트리가 갱신되지 않음** → 파일은 있는데 디렉터리에서 안 보임 (orphan)
  - bitmap은 사용 중이라는데 아무 inode도 그 block을 가리키지 않음 → space leak
  - inode는 block을 가리키는데 bitmap은 free → 나중에 다른 파일이 같은 block을 써서 데이터 오염
- 이걸 **crash consistency problem**이라고 하고, 반드시 핸들링해야 한다.
  - 해결 기법: fsck(사후 검사), **Journaling**, Log-Structured FS 등 → 이후 강의 내용.

### 10.3 DB의 접근: Transaction

- DB는 트랜잭션 시작/끝을 **TxB(Transaction Begin) / TxE(Transaction End)** 로 표시한다.
- 데이터가 persistent하게 남기 때문에, 중간에 끊기면 **누가 올바른 상태인지에 대한 규칙**과 원래대로 되돌리는 **rollback 메커니즘**이 필요하다 → WAL(Write-Ahead Logging), Checkpoint, Crash Recovery로 구현.
- 파일 시스템의 journaling도 같은 아이디어(TxB → 메타데이터/데이터 → TxE)를 차용한다.

---

## 11. 핵심 정리

- 파일 시스템 레이아웃 = **Superblock / inode bitmap / data bitmap / inode table / data region**
- Quick Format은 메타데이터만 초기화 → 데이터 복구 가능
- inode 위치 = **inode table 시작 주소 + inumber × sizeof(inode)**
- inode는 **direct + single/double/triple indirect** 포인터로 data block을 가리키는 multi-level index 구조
- 디렉터리 = **(name, inode number) 목록을 담은 특별한 파일**, inode의 type bit로 구분
- 삭제(unlink)는 엔트리 제거 + link count 감소 + bitmap free 처리일 뿐, **data block 내용은 남는다** → 포렌식
- 디렉터리 엔트리 구성: linear list(O(n)) vs B-tree/HTree(O(log n)), ext4는 작은 디렉터리는 linear, 큰 디렉터리는 HTree
- 디렉터리 연산은 **metadata-intensive** → 대규모 AI 학습/HPC에서 성능 병목

---

## 12. 셀프 체크리스트

- [ ] Superblock, i-bmap, d-bmap, inode table, data region 각각의 역할을 설명할 수 있다
- [ ] Quick Format 후 데이터 복구가 가능한 이유를 설명할 수 있다
- [ ] inode 크기 256B, inode table 시작 12KB일 때 inode 32의 주소(20KB)와 sector 번호(40)를 계산할 수 있다
- [ ] block 4KB, 포인터 4B, direct 12개일 때 최대 파일 크기를 계산할 수 있다
- [ ] indirect block이 데이터가 아닌 "위치 정보"를 담고, data region의 block을 사용한다는 걸 안다
- [ ] 디렉터리가 파일이면서 무엇을 저장하는지, 일반 파일과 어떻게 구분되는지 설명할 수 있다
- [ ] 경로 `/a/b/c` 를 열 때 어떤 블록들을 순서대로 읽는지 설명할 수 있다
- [ ] unlink 후에도 내용 복원이 가능한 이유를 설명할 수 있다
- [ ] ext4 디렉터리 엔트리의 rec_len이 삭제된 엔트리를 어떻게 건너뛰는지 설명할 수 있다
- [ ] linear list와 B-tree/HTree의 lookup 복잡도 차이를 말할 수 있다
- [ ] data-intensive vs metadata-intensive 연산을 구분할 수 있다
- [ ] 분산 학습(data parallelism)과 HPC에서 디렉터리 연산이 병목이 되는 이유를 설명할 수 있다
- [ ] crash consistency problem이 무엇이고 왜 persistent media에서만 문제가 되는지 설명할 수 있다