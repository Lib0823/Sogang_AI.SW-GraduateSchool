# Linux OS and Applications

<br/>

서강대학교 AI·SW 대학원 **Linux 운영체제 및 응용(GITF315)** 강의 내용을 정리한
저장소입니다. 담당 교수는 김영재(`youkim@sogang.ac.kr`)이며, 컴퓨터 시스템 기초에서
출발해 운영체제의 프로세스 관리 → 메모리 관리 → LLM 서빙과 운영체제의 연결까지
다룹니다. 각 폴더에는 강의에 사용된 PPT(PDF) 원본과, 강의 내용을 정리한
`README.md`가 함께 들어 있습니다.

<br/>

> *이 저장소의 자료는 학습 및 개인 복습 목적으로 정리한 것이며, 실제 강의
> 내용과 표현상 차이가 있을 수 있습니다.*

<br/>

## 강의 개요

| 항목 | 내용 |
|------|------|
| 학수번호 | GITF315 |
| 학기 | 2026년 1학기 |
| 학점 | 2학점 |
| 시간 | 토 09:30~11:00 |
| 수업형태 | 강의 100% (주교재 기반 강의노트) |
| 평가 | 중간고사 40% · 기말고사 50% · 참여도 10% |

**교과목표**

- Open Source Linux 운영체제를 중심으로 현대 운영체제의 기본 원리와 핵심 기반 기술을 이해
- 프로세스·스레드, 가상 메모리, 스케줄링, 동기화 등 모든 운영체제에 공통인 요소 기술과
  Linux 고유의 시스템 구조를 구분하여 학습
- 시스템 콜을 활용한 Concurrent Programming 및 Pthread 기반 리눅스 프로그래밍
- LLM 서빙 시스템의 paged attention, 메모리 페이징, 캐시 관리, 동시성 제어를 확장·응용하기
  위한 학문적 기초 확보

**참고자료**: 강의노트 (cyber.sogang.ac.kr)

<br/>

### 주차별 계획 (강의계획서 기준)

| 주차 | 분야 | 주제 |
|------|------|------|
| 01 | 컴퓨터 시스템 기초 | CPU 구조와 어셈블리 언어를 통한 프로그램 실행 모델 이해 |
| 02 | 컴퓨터 시스템 기초 | 메모리 계층 구조와 CPU 캐시 설계 원리 및 성능 영향 분석 |
| 03 | 운영체제 프로세스 관리 | 운영체제의 기본 개념·역할, 커널과 사용자 공간 구조 |
| 04 | 운영체제 프로세스 관리 | CPU 가상화 관점에서 프로세스와 스레드의 구조 이해 |
| 05 | 운영체제 프로세스 관리 | 프로세스 및 스레드 스케줄링의 기본 기법과 성능 지표 |
| 06 | 운영체제 프로세스 관리 | 고급 스케줄링 기법과 CPU 활용률 및 공정성 최적화 |
| 07 | 운영체제 프로세스 관리 | 동시성 문제와 동기화 메커니즘의 원리 및 설계 이슈 |
| 08 | — | 《중간고사》 |
| 09 | 운영체제 메모리 관리 | 메모리 가상화 개념과 주소 변환 과정 및 가상 메모리 구조 |
| 10 | 운영체제 메모리 관리 | 페이징 기법의 동작 원리와 페이지 폴트 처리 과정 |
| 11 | 운영체제 메모리 관리 | TLB와 고급 계층적 페이징 기법 |
| 12 | 운영체제 메모리 관리 | 페이지 교체 정책 및 구현 방법 |
| 13 | 운영체제 메모리 관리 | 스와핑 동작과 메모리 압박 상황에서의 시스템 동작 |
| 14 | 인공지능 AI와 운영체제 | LLM 서빙과 운영체제 개념의 연결 |
| 15 | 인공지능 AI와 운영체제 | LLM 서빙 시스템의 메모리 관리와 요청 스케줄링 구조 |
| 16 | — | 《기말고사》 |

<br/>

## 목록

아래는 실제로 보관 중인 자료 기준이며, 위 강의계획서의 주차 번호와는 일치하지 않습니다.
04번 GPU Architecture는 강의계획서에 없는 보충자료입니다.

| 순서 | 주제 | 자료 |
|------|------|------|
| 01 | [Machine Basics](./01-machine-basics) | PPT, 판서 사진 |
| 02 | [Memory Hierarchy and Caches](./02-memory-hierarchy-and-caches) | PPT |
| 03 | [OS Basics and Process](./03-os-basics-and-process) | PPT |
| 04 | [GPU Architecture (보충자료)](./04-gpu-architecture) | PPT |
| 05 | [CPU Virtualization](./05-cpu-virtualization) | PPT |
| 06 | [CPU Scheduling](./06-cpu-scheduling) | PPT |
| 07 | [No Materials](./07-no-materials) | 자료 없음 (강의 영상만 존재) |
| 08 | [No Materials](./08-no-materials) | 자료 없음 |
| 09 | [Concurrency and Locks](./09-concurrency-and-locks) | PPT |
| 10 | [Memory: Address Translation](./10-memory-address-translation) | PPT |
| 11 | [Memory: Segmentation and Paging](./11-memory-segmentation-and-paging) | PPT |
| 12 | [Memory: TLB and Advanced Page Tables](./12-memory-tlb-and-advanced-page-tables) | PPT |
| 13 | [Swapping](./13-swapping) | PPT |
| 14 | [LLM Serving and RAG](./14-llm-serving-and-rag) | PPT |

<br/>

## 구성

```
1-1.Linux_OS_and_Applications/
├── 01-machine-basics/
├── 02-memory-hierarchy-and-caches/
├── 03-os-basics-and-process/
├── 04-gpu-architecture/
├── 05-cpu-virtualization/
├── 06-cpu-scheduling/
├── 07-no-materials/
├── 08-no-materials/
├── 09-concurrency-and-locks/
├── 10-memory-address-translation/
├── 11-memory-segmentation-and-paging/
├── 12-memory-tlb-and-advanced-page-tables/
├── 13-swapping/
└── 14-llm-serving-and-rag/
```

각 폴더의 `README.md`에는 해당 강의의 PPT와 강의 노트를 바탕으로 정리한
핵심 개념 요약이 담겨 있습니다.
