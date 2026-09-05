# Weeks 4-5 — Pandas: Data Analysis Fundamentals with Netflix Data

## 강의 자료
- [pandas-fundamentals-with-netflix-data.ipynb](./pandas-fundamentals-with-netflix-data.ipynb)
- [netflix-cleaned.csv](./netflix-cleaned.csv) — 전처리 완료된 넷플릭스 콘텐츠 데이터
- [netflix-selena.csv](./netflix-selena.csv) — 결측치가 포함된 원본(강사 셀레나 제공) 데이터

## 강의 내용 정리

이전 주차와 동일하게, 슬라이드 설명 → ChatGPT 프롬프트 예시 → 빈칸 채우기 실습 코드 순으로 구성된다.

### 1. Series와 DataFrame 생성
`True, 3.14, 'ABC'`처럼 자료형이 섞인 리스트로 Series를 만들어보고, 딕셔너리로 DataFrame을 생성한다. 이어서 `show_id`, `type`, `title`, `director`, `cast`, `country`, `release_year`, `duration`, `listed_in` 컬럼을 가진 8행짜리 넷플릭스 예제 데이터를 직접 만들며 의도적으로 결측치(NaN)를 포함시킨다.

### 2. 파일 입출력
`pd.read_csv()`/`to_csv()`로 결측치가 있는 원본 `netflix_selena.csv`와 전처리가 끝난 `netflix_cleaned.csv`를 각각 불러와 비교한다.

### 3. 데이터 탐색
`.columns`, `.index`, `.head()`, `.tail()`, `.shape`, `.info()`로 데이터의 구조와 결측치 현황을 확인한다.

### 4. 컬럼 선택과 조건 필터링
단일 대괄호(`df['col']`)·점 표기(`df.col`)로 Series를 선택하는 방법과 이중 대괄호(`df[['col']]`)로 DataFrame 형태를 유지하며 선택하는 방법의 차이를 다룬다. `release_year > 2015`와 `type == 'TV Show'`를 `&`로 결합하는 등 비교·논리 연산자를 활용한 조건 필터링을 실습한다.

### 5. 결측치 처리
`.isna().sum()`과 `.info()`로 결측치를 확인하고, for문으로 컬럼별 결측 비율(%)을 직접 계산해본다. `country` 컬럼은 `fillna()`로, `director` 컬럼은 `replace(np.nan, ...)`로 채우는 방법을 비교하고, `dropna(axis=1)`(컬럼 삭제)과 `dropna(subset=[...])`(특정 컬럼 기준 행 삭제)를 실습한다.

### 6. 기술통계와 그룹 집계
`.mean()`, `.median()`, `.sum()`, `.min()`, `.max()`, `.std()`, `.var()`, `.count()`, `.value_counts()`, `.describe()`, 그리고 컬럼별로 서로 다른 집계 함수를 지정하는 `.agg()`를 다룬다. `groupby()`로 `type` 단일 기준, `type`+`country` 복수 기준 집계를 실습한다.

### 7. 행/열 추가·삭제
`.iloc`/`.loc`으로 행을 복사하고 `df['col'] = ...`로 새 컬럼을 추가하는 방법, `.drop()`으로 행(정수 인덱스 배열 기준)과 열(컬럼명 기준)을 삭제하는 방법을 다룬다.

> **참고(오류 정정)**: 행 삭제 실습에서 "2번째부터 4번째 행까지 삭제해줘"라는 프롬프트와 함께 `np.arange(2, 5)`를 인덱스로 사용하는데, DataFrame의 인덱스가 0부터 시작하므로 이 코드는 실제로는 **3번째~5번째 행**을 삭제한다. 프롬프트에서 말하는 "2번째 행"(1-based, 사람이 세는 방식)과 코드의 인덱스 2(0-based, 3번째 행)가 어긋나는 흔한 사례이므로, 실습 시 인덱스 기준을 항상 명확히 구분해서 이해할 필요가 있다.
