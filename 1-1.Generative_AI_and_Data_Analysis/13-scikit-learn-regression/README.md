# Week 13 — Scikit-learn: Machine Learning Basics and Linear Regression

## 강의 자료
- [scikit-learn-ml-basics-linear-regression.ipynb](./scikit-learn-ml-basics-linear-regression.ipynb)
- [oil-daily-production-2023-2024.xlsx](./oil-daily-production-2023-2024.xlsx) — 유종별 일일 생산량 데이터
- [linear-regression-formula-explained.png](./linear-regression-formula-explained.png) — 선형회귀 수식 설명 이미지 (집값 예측 예제)

## 강의 내용 정리

"8장. 머신러닝 라이브러리, Scikit Learn" 슬라이드와 ChatGPT 프롬프트 예시가 함께 제공되는 실습 노트북으로, 다음 개념을 순서대로 다룬다:
- 전통적 프로그래밍과 머신러닝의 차이, 지도/비지도/강화학습 개념
- 머신러닝 파이프라인에서 scikit-learn의 역할
- 독립변수와 종속변수의 구분
- 정규화(`MinMaxScaler`)와 표준화(`StandardScaler`)의 차이
- 선형회귀 이론, `train_test_split`, `LinearRegression`으로 모델 학습, 예측, 그리고 `sklearn.metrics`의 `mean_squared_error`/`r2_score`로 평가

거의 모든 scikit-learn 코드 셀은 `X = `, `minmax_scaler = `, `model = `, `X_train, X_test, y_train, y_test = `, `mse = ` 처럼 빈칸으로 남아 있어 학생이 직접 채우는 "1단계" 실습용 뼈대(skeleton)이며, 실행된 결과가 저장되어 있지 않다.

유일하게 완성되어 있는 코드 셀은 20일치 가스 거래 가상 데이터(`consumption`, `storage`, `oil_price`, `avg_temp`, `gas_price` 컬럼, 2025-05-01~2025-05-20)를 손으로 직접 만든 리스트로 구성한 DataFrame이며, 실제 엑셀 파일에서 읽어온 것이 아니다. 마지막 부분의 마크다운 셀에는 예상 평가 결과(MSE ≈ 0.0112, R² ≈ 0.939, 예측 샘플)가 토의용 예시로 제시되어 있지만, 코드가 실행된 적이 없으므로 이는 실제 셀 출력이 아니라 설명용 텍스트다.

> **참고(자료 불일치)**: 강의계획서 기준으로는 이번 주차가 `Oil_Daily_Production_2023_2024.xlsx` 데이터셋을 활용해 결측치 처리(선형보간, 최빈값 대체, 'Unknown' 처리)와 날짜에서 월/분기를 추출하는 파생변수 생성, 그리고 경유·고급휘발유 월평균 생산량 예측 모델을 다루는 것으로 되어 있다. 하지만 실제로 확보된 이 노트북 파일에는 해당 엑셀 파일을 불러오는 코드도, 결측치 처리도, 날짜 기반 파생변수 생성도 나타나지 않는다 — 대신 가상의 가스 가격 데이터로 기본 선형회귀 실습만 진행된다. 강의계획서에 설명된 유가 데이터 전처리 및 예측 실습은 별도의 "2단계" 노트북이나 강의 중 추가로 다뤄진 자료에 포함되어 있었을 가능성이 있으며, `oil-daily-production-2023-2024.xlsx` 파일 자체는 참고용으로 이 폴더에 함께 보관한다.
