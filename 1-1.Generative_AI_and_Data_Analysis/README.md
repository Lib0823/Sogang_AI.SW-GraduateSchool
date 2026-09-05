# Generative AI and Python Data Analysis

<br/>

서강대학교 AI·SW 대학원 **생성형 AI와 파이썬 데이터 분석(GITA403)** 강의 내용을 정리한
저장소입니다. 담당 교수는 윤혜민(펜네임 "셀레나", 유튜브 채널 `@SELENASSAM`)이며, 강의는
생성형 AI(ChatGPT)로 코드를 생성하고 파이썬으로 이를 실행·검증하는 방식을 축으로
Numpy·Pandas·Matplotlib·Seaborn·BeautifulSoup·Scikit-learn을 다룹니다. 대부분의 주차
자료가 Jupyter Notebook(빈칸 채우기 실습 형태)으로 되어 있어, 각 폴더에는 노트북 원본과
함께 실제 코드 내용을 바탕으로 정리한 `README.md`가 들어 있습니다.

<br/>

> *이 저장소의 자료는 학습 및 개인 복습 목적으로 정리한 것이며, 실제 강의 내용과
> 표현상 차이가 있을 수 있습니다.*

<br/>

## 강의 개요

| 항목 | 내용 |
|------|------|
| 학수번호 | GITA403 |
| 학기 | 2026년 1학기 |
| 학점 | 2학점 |
| 시간 | 수 20:10~21:40 |
| 수강대상 | 초·중급 (기본적인 파이썬 문법 이해 권장) |
| 수업형태 | 강의 45% · 실험/실습 40% · 개별 발표 15% (100% 대면) |
| 평가 | 프로젝트 40% · 과제물 40% · 동료평가 10% · 출결 및 참여도 10% |

**교과목표**

- 생성형 AI와 ChatGPT의 기본 개념 및 프롬프트 엔지니어링 기법 습득
- Numpy·Pandas·Matplotlib·Seaborn·BeautifulSoup·Scikit-learn의 핵심 기능 실습
- 데이터 수집 → 전처리 → 시각화 → 인사이트 분석 → 예측 모델링 수행
- 반복적인 데이터 처리 업무를 파이썬 코드로 자동화하고, AI가 생성한 결과를 비판적으로 검증

**참고문헌**

- 강의 노트(Lecture Note) 및 Google Colaboratory 자료
- 『파이썬 데이터 분석가 되기+챗GPT』 셀레나(윤혜민)

**운영 특징**

- 필기 중간고사 없음 — 단계별 과제 제출로 대체
- 4·6·8·10·12·14주차에 단계별 과제를 제출하며 최종 프로젝트를 완성:
  현업 문제 사례 조사 → 프로젝트 대상 확정서 → 과제 정의서 → 데이터 수집·전처리 →
  분석·시각화·인사이트 도출 → 자동화 구현 및 개선 효과 확인
- '주간 인공지능(주인공)' 코너에서 엑셀·PPT 자동화, 바이브 코딩, sLLM, OpenAI API 등을 병행
- 파이썬 경험이 없는 학생을 위한 약 7주간의 파이썬 기초 스터디 병행

<br/>

### 주차별 계획 (강의계획서 기준)

| 주차 | 주제 | 단계별 과제 |
|------|------|------|
| 01 | 생성형 AI 개념·동향, 프롬프트/컨텍스트/하네스/루프 엔지니어링, Colab 환경 설정 | — |
| 02 | Numpy: 배열 생성과 축(axis), 속성, 초기화 | — |
| 03 | Numpy: 인덱싱·슬라이싱, reshape, 병합(stack)과 분할(split) | — |
| 04 | Pandas: Series/DataFrame 구조, 입출력, 열 선택, 조건 필터링 | 현업 문제 사례 조사 |
| 05 | Pandas: 결측치 처리, groupby와 집계, 행·열 추가/삭제 | — |
| 06 | Matplotlib: 기본 그래프, 축·제목 설정, 선·막대·파이·히스토그램 | 프로젝트 대상 확정서 |
| 07 | Matplotlib: 히트맵, 박스 플롯, 서브플롯 | — |
| 08 | 《중간 시험》 — 필기 대신 과제 제출 | 과제 정의서 |
| 09 | Seaborn: 6가지 주요 그래프 유형 | — |
| 10 | BeautifulSoup: 웹 스크래핑 원리, robots.txt, HTTP 헤더 | 데이터 수집 및 전처리 (.ipynb) |
| 11 | BeautifulSoup: 삼성전자 주가 수집·가공, 시계열 시각화 | — |
| 12 | 오피넷 Open API: 실시간 유가 수집 자동화, XML 파싱·정제, 변동률 시각화 | 분석·시각화, 인사이트 도출 (.ipynb) |
| 13 | Scikit-learn: 머신러닝 개념, 결측치 처리, 피처 엔지니어링, 회귀 예측 | — |
| 14 | 프로젝트 발표 (1차 그룹) | 자동화 구현 및 개선 효과 확인 |
| 15 | 프로젝트 발표 (2차 그룹) | — |
| 16 | 프로젝트 발표 (3차 그룹), 전체 마무리 및 종합 피드백 | 최종 프로젝트 제출 |

<br/>

## 목록

아래는 실제로 보관 중인 자료 기준이며, 위 강의계획서의 주차 번호와 묶음이 다를 수 있습니다.

| 순서 | 주제 | 자료 |
|------|------|------|
| - | [강의계획서](./syllabus.pdf) | Syllabus |
| 01 | [Generative AI Basics](./01-generative-ai-basics) | PDF (생성형 AI 기초, 파이썬 라이브러리 개념) |
| 02-03 | [Numpy](./02-03-numpy-arrays) | 실습 노트북 |
| 04-05 | [Pandas](./04-05-pandas-data-analysis) | 실습 노트북, 넷플릭스 데이터 |
| 06-07 | [Matplotlib](./06-07-matplotlib-visualization) | 실습 노트북, 타이타닉 데이터 |
| - | [중간고사 (Midterm Submission)](./midterm-submission) | 과제 정의서(초안) |
| 09 | [Seaborn](./09-seaborn-visualization) | 실습 노트북 |
| 10-11 | [Web Scraping (BeautifulSoup)](./10-11-web-scraping-beautifulsoup) | 실습 노트북 |
| 12 | [Opinet API Automation](./12-opinet-api-automation) | API 가이드, 실습 노트북, 과거 유가 데이터 |
| 13 | [Scikit-learn](./13-scikit-learn-regression) | 실습 노트북, 유종별 생산량 데이터 |
| - | [기말 프로젝트 (Final Project)](./final-project) | 프로젝트 정의서, 조사 보고서, 발표자료, 소스코드 |

<br/>

## 구성

```
1-1.Generative_AI_and_Data_Analysis/
├── syllabus.pdf
├── 01-generative-ai-basics/
├── 02-03-numpy-arrays/
├── 04-05-pandas-data-analysis/
├── 06-07-matplotlib-visualization/
├── midterm-submission/
├── 09-seaborn-visualization/
├── 10-11-web-scraping-beautifulsoup/
├── 12-opinet-api-automation/
├── 13-scikit-learn-regression/
└── final-project/
```

강의계획서 기준, 8주차는 중간고사 기간으로 별도 강의가 없었으며 필기시험 대신 기말
프로젝트를 위한 "과제 정의서" 제출로 대체되었습니다. 14주차는 개인 프로젝트
멘토링·피드백 주간, 15~16주차는 프로젝트 발표 주간으로 별도의 강의 슬라이드가
없었습니다.

각 폴더의 `README.md`에는 실습 노트북의 실제 코드·마크다운 내용을 바탕으로 정리한
핵심 개념 요약과, 노트북 설명 중 확인된 오류에 대한 정정 사항이 담겨 있습니다.
