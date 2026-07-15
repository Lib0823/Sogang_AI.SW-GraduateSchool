# Weeks 6-7 — Matplotlib: Data Visualization

## 강의 자료
- [matplotlib-data-visualization.ipynb](./matplotlib-data-visualization.ipynb)
- [titanic-selena.csv](./titanic-selena.csv) — 타이타닉 생존자 데이터 (강사 셀레나 제공)

## 강의 내용 정리

타이타닉 데이터셋(`titanic_selena.csv`)을 소재로 Matplotlib의 주요 그래프 유형을 실습한다. (노트북의 코드 셀은 모두 빈칸 채우기용 미실행 상태로, 아래는 다뤄지는 내용을 정리한 것이다.)

### 1. 기본 설정
라이브러리 임포트, `plt.plot()` 기본 선 그래프, `xlabel`/`ylabel`/`legend` 설정을 다룬다.

### 2. 제목과 다중 서브플롯
`fontsize`, `color`, `fontweight`, `loc`, `pad`, `backgroundcolor` 등 제목 꾸미기 옵션과, `suptitle`로 여러 서브플롯 전체에 대한 상위 제목을 붙이는 방법을 다룬다.

### 3. 막대 그래프
막대 색상·눈금 커스터마이징과, `enumerate()`와 `plt.text()`를 조합해 막대 위에 값 라벨을 표시하는 방법을 다룬다.

### 4. 타이타닉 데이터 불러오기
`read_csv`, `head`, `info`로 데이터를 확인한다.

### 5. 가로 막대 그래프 (성별 생존자 수)
`barh()`로 성별 생존자 수를 시각화하고, `axvline()`으로 기준선을 추가하며 값 라벨을 표시한다.

### 6. 파이 차트 (생존 비율)
`pie()`로 생존 비율을 시각화하며 `explode`, `autopct`, `shadow` 옵션을 다룬다.

### 7. 히스토그램 (나이 분포)
`dropna(subset=['Age'])`로 결측치를 제거한 뒤 `hist()`로 나이 분포를 그린다. 실제 타이타닉 데이터셋 기준 승객 수가 891명에서 714명으로 줄어드는데(나이 결측 177건), 노트북의 설명이 이 수치와 정확히 일치한다.

### 8. 상관관계 히트맵
`plt.matshow()`로 변수 간 상관관계를 시각화하고, 눈금 라벨 회전과 컬러바 추가 방법을 다룬다.

### 9. 박스플롯 (객실 등급별 나이 분포)
`Pclass`(객실 등급)별 나이 분포를 박스플롯으로 비교하며, 사분위수·이상치(outlier) 개념을 설명한다.

### 10. 그래프 조합
`plt.subplot()`으로 여러 그래프를 격자 형태로 배치하는 방법과, `twinx()`로 하나의 그래프에 서로 다른 두 개의 y축을 사용하는 방법을 다룬다.

### 11. 그래프 저장과 한글 폰트
`plt.savefig()`로 그래프를 파일로 저장하는 방법과, Colab 환경에서 한글 폰트가 깨지는 문제를 해결하는 `koreanize-matplotlib` 패키지를 소개한다.

마크다운 설명 중 기술적으로 부정확한 내용은 발견되지 않았다 (제목 옵션 목록, 박스플롯 용어, 891→714건 결측치 수치 모두 정확함).
