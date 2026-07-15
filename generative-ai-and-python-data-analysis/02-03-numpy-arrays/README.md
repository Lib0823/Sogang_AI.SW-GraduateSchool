# Weeks 2-3 — Numpy: Array Basics and Operations

## 강의 자료
- [numpy-array-basics-and-operations.ipynb](./numpy-array-basics-and-operations.ipynb)

## 강의 내용 정리

각 절마다 강의 슬라이드 이미지와 "이 코드를 짜기 위해 ChatGPT에 이렇게 물어봤다"는 형태의 프롬프트 예시가 먼저 나오고, 이어서 빈칸을 채우는 실습 코드 셀이 나오는 구성이다 (생성형 AI 활용을 전제로 한 이 과목의 공통 학습 방식).

### 1. Numpy 불러오기와 배열 생성
`import numpy as np` 및 별칭 없이 불러오는 방법을 비교하고, `[1, 2, 3]` 형태의 1차원 배열 생성부터 시작한다.

### 2. ndarray 속성
`a = np.arange(12).reshape(3, 4)` 예제로 `dtype`, `.shape`, `.ndim`, `.itemsize`, `.size` 속성을 확인하고, `dtype='int8'`처럼 자료형을 직접 지정하는 방법도 다룬다.

### 3. 배열 초기화 함수
`np.zeros`, `np.ones((2, 3, 4))`, `np.empty((2, 3))`을 비교한다. `np.empty`는 메모리를 초기화하지 않고 할당만 하므로 결과값이 임의의 값(garbage value)일 수 있다는 점을 짚는다.

### 4. arange vs. linspace
`np.arange(10, 30, 5)`와 `np.linspace(1, 10, 10)`을 비교한다. `arange`는 간격(step) 기준, `linspace`는 개수(count) 기준으로 값을 생성하며, `linspace`는 기본적으로 끝값을 포함(`endpoint=True`)한다는 차이를 정확히 설명한다.

### 5. 배열 연산
`a = [10, 20, 30, 40]`, `b = np.arange(1, 5)` 예제로 원소별 사칙연산을 다루고, 원소별 곱셈(`A * B`)과 행렬곱(`A @ B`)의 차이, 비교 연산자(`>`, `==`)의 결과가 불리언 배열로 반환됨을 설명한다.

### 6. 집계 함수와 axis
`a = np.arange(8).reshape(2, 4) ** 2` 예제로 `sum`, `mean`, `min`, `max`, `cumsum`, `argmax`를 실습하고, `axis=0`(열 방향)과 `axis=1`(행 방향) 집계의 차이를 비교한다.

### 7. 인덱싱과 슬라이싱
1차원/2차원 배열의 단일 원소 인덱싱, 슬라이싱, 불리언(조건) 인덱싱(`a > 4`인 위치에 1000 대입), 팬시 인덱싱(정수 배열로 순서를 바꿔 조회)을 다룬다.

### 8. reshape과 배열 결합/분할
`reshape()`에서 `-1`을 사용해 나머지 차원을 자동 계산하는 기능, 그리고 `vstack`/`hstack`(결합)과 `vsplit`/`hsplit`(분할)을 실습한다.

> **참고(보완 설명)**: 슬라이드에는 `reshape()`가 "새 배열을 반환한다"고만 설명되어 있는데, 이는 정확히는 새로운 `ndarray` 객체를 반환한다는 뜻이지 데이터가 항상 복사된다는 뜻은 아니다. 실제로는 대부분의 경우 원본 배열과 메모리를 공유하는 **뷰(view)**를 반환하며, 메모리 레이아웃상 뷰로 표현이 불가능한 경우에만 복사본이 만들어진다. 따라서 `reshape()` 결과를 수정하면 원본 배열도 함께 바뀔 수 있다는 점에 유의해야 한다.
