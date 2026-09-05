# Comparing Population Means (I) — Independent & Paired t-tests

## 강의 자료
- [comparing-population-means-slides.pdf](./comparing-population-means-slides.pdf)
- [student-report.pptx](./student-report.pptx) — 학생 발표 자료
- 실습 스크립트: [independent-t-test-histogram.R](./independent-t-test-histogram.R)
- 실습 데이터: [diet-before-after.csv](./diet-before-after.csv), [t-test-and-f-test-workbook.xlsx](./t-test-and-f-test-workbook.xlsx), [t-test-workbook-2.xlsx](./t-test-workbook-2.xlsx)

## 강의 내용 정리

이번 강의는 모집단이 두 개인 경우의 평균 비교(t검정)를 다루며, 세 개 이상인 경우(분산분석)는 다음 주차([07-anova-and-logistic-regression](../07-anova-and-logistic-regression))에서 이어진다.

### 1. 평균 비교의 두 가지 유형
- **서로 독립인 두 집단**: 한 변수(예: 성별)로 나뉜 두 집단이 서로 영향을 주지 않는 경우 (예: 남자아이/여자아이의 몸무게).
- **서로 대응(쌍체)인 두 집단**: 동일한 대상의 처치 전후를 비교하는 경우 (예: 다이어트 프로그램 전후 체중).

### 2. 독립표본 t검정
- **전제 조건**: 두 모집단이 정규분포를 이루어야 하며(정규성), 두 집단의 분산이 서로 같아야 한다(등분산성).
- 등분산 여부는 F검정으로 먼저 확인하고(엑셀 데이터 분석 도구의 "F-검정: 분산에 대한 두 집단"), 그 결과(p값 기준 0.05 미만이면 비등분산, 이상이면 등분산)에 따라 t검정 시 등분산 가정 여부(`var.equal`)를 다르게 지정한다.
- R 실습: `var.test()`로 등분산 검정 후 `t.test(..., var.equal=TRUE/FALSE)`로 독립표본 t검정을 수행. 남아·여아 몸무게 데이터를 히스토그램으로 겹쳐 그려 분포를 비교하는 실습([independent-t-test-histogram.R](./independent-t-test-histogram.R))이 포함된다.

### 3. 대응(쌍체)표본 t검정
- 동일 집단의 전/후 값 차이(`diff <- Before - After`)를 계산하고, 이 차이값의 평균이 0인지를 검정한다.
- R 실습: `diet.csv` 데이터(다이어트 전후 체중)를 이용해 `boxplot()`으로 차이값의 분포를 확인하고, `t.test(Before, After, paired=TRUE)`로 대응표본 t검정을 수행하는 과정을 다룬다.

### 4. 세 개 이상의 모집단 비교 (분산분석 개요)
- 모집단이 세 개 이상으로 늘어나는 경우, 두 집단씩 짝지어 비교하는 대신 **일원배치 분산분석(One-way ANOVA)**을 사용한다는 것을 다음 주차 내용의 도입부로 짧게 소개한다.

### 복습 포인트
- 왜 독립표본 t검정 전에 반드시 등분산 검정(F검정)을 먼저 수행해야 하는지 이해하기.
- 대응표본 t검정은 독립표본 t검정과 달리 "차이값(Before - After)" 자체를 하나의 표본으로 보고 검정한다는 점.
