# Final Project — AI-Based Automated Stock Trading System

## 제출 자료
- [project-definition-final.docx](./project-definition-final.docx) — 프로젝트 정의서 (최종본)
- [use-case-research-report.docx](./use-case-research-report.docx) — 활용사례 조사 보고서
- [final-presentation.pptx](./final-presentation.pptx) — 최종 발표 자료
- [project-source-code.zip](./project-source-code.zip) — 프로젝트 소스코드 (FinanceManageAgent, 기존 Vue3 앱 기반)

## 프로젝트 개요

기존에 구축되어 있던 FinanceManageAgent(Vue3 기반 자산관리 앱)를 확장해, 코스피 상위 종목을 대상으로 AI가 매수·매도를 판단하는 자동매매 시스템을 구축하는 개인 프로젝트다.

### 1. 종목 선정 파이프라인
FastAPI 기반 배치(APScheduler, 평일 08:50 실행)가 코스피 시가총액 상위 100개 종목을 스캔한다. 외국인 순매수·기관 순매수(절대값)·거래량 비율·변동성에 각각 0.3/0.3/0.3/0.1 가중치를 곱해 StandardScaler로 정규화한 점수를 산출한 뒤, 상위 30개 종목(+ 현재 보유 종목)을 분석 대상으로 선정한다.

### 2. 3갈래 분석
선정된 30개 종목에 대해 독립적으로 3가지 분석을 수행한다.
- **정량 분석**: 한국투자증권(KIS) API의 4개 시장 지표(장 초반 수익률, 종가 위치, 외국인/기관 순매수)와 DART의 3개 재무비율(PER, ROE, 영업이익률, 분기별 갱신).
- **감성 분석**: KR-FinBERT로 시장 전체 RSS 뉴스와 종목별 네이버 금융 뉴스 두 트랙을 각각 분석.
- **시계열 예측**: Prophet으로 KIS의 120거래일 데이터를 학습해 D+1~D+5 가격/거래량 추세와 불확실성 구간을 예측.

### 3. 의사결정과 실행
위 11개 피처와 보유 여부를 하루 한 번(무료 API 한도 고려) Gemini API에 전달하면, 매수·매도 후보 TOP3와 판단 근거를 JSON으로 반환한다. 이 결과는 수급·감성·추세 조건을 검사하는 규칙 기반 안전 필터를 통과해야 하며, 통과한 경우에만 Spring Boot가 KIS 모의투자 API를 통해 실제(모의) 주문을 실행한다.

### 4. MVP 범위
초기 구현 범위는 의도적으로 좁게 설정되어 있다: 회원가입/JWT 없이 관리자 계정 하나만 하드코딩, API 키·종목코드 하드코딩, 4개 탭으로 구성된 Vue3 AI 분석 대시보드, docker-compose 기준 4개 컨테이너(python-api/spring-api/frontend/postgres) 구성. scikit-learn 기반 ML(RandomForest 등)·n8n 워크플로우·LSTM 딥러닝·외부 알림 기능은 명시적으로 범위에서 제외했다 — 종목 스코어링에는 학습 모델이 아닌 StandardScaler(단순 정규화)만 사용한다.

## 참고 사례 조사

- **Lopez-Lira & Tang (2023, arXiv:2304.07619)**: GPT-4로 뉴욕/나스닥/아멕스 뉴스 헤드라인의 감성을 점수화하면 다음 날 수익률과 상관관계가 있음을 보였다(소형주·부정적 뉴스에서 더 뚜렷). 다만 2021년 4분기부터 2023년까지 LLM 활용이 확산되고 시장이 뉴스를 더 빠르게 반영하면서 수익성이 급격히 낮아졌다는 점도 함께 다룬다.
- **JPMorgan LOXM (2017)**: 주문 가격·수량·타이밍을 최적화해 시장 충격을 줄이는 심층강화학습 기반 주문 실행 시스템으로, 유럽 주식시장에서 먼저 도입된 뒤 아시아·미국으로 확대되었다.
- 이 프로젝트는 Lopez-Lira & Tang의 단일 신호(감성) 접근을 정량·재무·시계열·감성을 결합한 다중 신호 구조로 확장하고, 생성형 AI를 최종 의사결정 계층으로 두는 방향을 지향한다. 또한 LOXM처럼 데이터가 누적될수록 성능이 개선된다는 아이디어를 참고한다.

> **참고(문서 간 불일치)**: 활용사례 조사 보고서의 결론부에는 "scikit-learn 기반 피처 중요도 모델을 매일 재학습하여 적용했다"는 문장이 있으나, 이는 프로젝트 정의서(최종본)에서 scikit-learn 기반 ML(RandomForest 포함)을 **명시적으로 범위에서 제외**하고 종목 스코어링에 StandardScaler 정규화만 사용한다고 밝힌 내용과 서로 어긋난다. MVP 범위가 확정되기 전에 조사 보고서가 먼저 작성되어 생긴 불일치로 보이며, 실제 제출 전 두 문서 간 내용을 맞출 필요가 있다. 아울러 Lopez-Lira & Tang 논문에서 언급되는 "정확도 90%"나 분기별 수익성 수치는 이번 정리 과정에서 원문 대조 검증까지는 하지 못했으므로, 인용 시 원 논문을 다시 확인하는 것을 권장한다.
