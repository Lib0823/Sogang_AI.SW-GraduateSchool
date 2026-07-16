# Week 9 — Seaborn: Visualization Basics

## 강의 자료
- [seaborn-visualization-basics.ipynb](./seaborn-visualization-basics.ipynb)

## 강의 내용 정리

Seaborn에 내장된 `tips`(식당 팁) 데이터셋 하나만을 사용해 실습이 진행된다.

### 1. 데이터 불러오기
`sns.load_dataset('tips')`로 데이터를 불러오고 `.head()`, `.info()`로 확인한다. 빈칸 실습으로 `sns.get_dataset_names()`를 이용해 Seaborn에 내장된 다른 데이터셋 목록을 출력해보도록 한다.

### 2. 범주형 산점도 (categorical scatter)
1x2 서브플롯으로 `sns.stripplot()`과 `sns.swarmplot()`을 비교한다. 요일(day)별 팁 금액을 성별(sex)로 색상 구분(`alpha=0.7`)하며, swarmplot 호출부는 학생이 직접 채우도록 비워져 있다.

### 3. 카운트 플롯 (count plot)
`sns.countplot()`으로 시간대(time)별 빈도를 먼저 그리고, 이어서 `hue='day'`와 `palette='Set2'`를 추가하는 두 번째 그래프를 실습한다.

### 4. 회귀 산점도 (regression scatter)
`sns.regplot()`으로 `total_bill`과 `tip`의 관계를 시각화하며, `fit_reg=True`(회귀선 포함)와 `fit_reg=False`(회귀선 제외)를 비교한다.

### 5. 히스토그램+KDE, 조인트플롯, 관계형 플롯
강의계획서상으로는 이 3가지 플롯 유형도 이번 주차 핵심 내용에 포함되지만, 실제 노트북 파일에는 해당 절의 슬라이드 이미지와 제목만 있고 **실행 가능한 코드 셀이 존재하지 않는다**. 강의 중 라이브 코딩으로 다뤄졌거나 별도 자료로 보완되었을 가능성이 있다.

### 참고
각 절 앞에는 "이 코드를 요청하기 위한 ChatGPT 프롬프트" 예시가 함께 제공되며, 이 과목 전반에 쓰이는 공통 시스템 프롬프트("숙련된 Python/데이터분석 전문가" 역할)를 전제로 한다. strip/swarm plot과 regplot에 대한 마크다운 설명은 기술적으로 정확하다.
