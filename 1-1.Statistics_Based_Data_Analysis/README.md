# Statistics-Based Data Analysis

<br/>

서강대학교 AI·SW 대학원 **통계기반 데이터 분석(GITS381)** 강의 내용을 정리한
저장소입니다. 담당 교수는 정화민(`vivahyatt@sogang.ac.kr`)이며, 전반부는 확률·분포에서
가설검정·회귀까지의 통계 이론을, 후반부는 연구모형을 세워 데이터를 수집하고 가설을
검증하는 팀 프로젝트를 다룹니다. 각 폴더에는 강의에 사용된 PPT(PDF) 원본과, 강의 내용을 정리한
`README.md`가 함께 들어 있습니다. 이 과목은 실습·발표 비중이 높아 학생이
직접 작성한 실습 리포트, R/엑셀 실습 파일, 중간·기말고사 제출물도 함께
정리되어 있습니다.

<br/>

> *이 저장소의 자료는 학습 및 개인 복습 목적으로 정리한 것이며, 실제 강의
> 내용과 표현상 차이가 있을 수 있습니다.*

<br/>

## 강의 개요

| 항목 | 내용 |
|------|------|
| 학수번호 | GITS381 |
| 학기 | 2026년 1학기 |
| 학점 | 2학점 |
| 시간 | 월 8:10~9:40 |
| 난이도 | 기초 |
| 수업형태 | 강의 60% · 실습 및 발표 40% (대면강의와 실시간 ZOOM 병행) |
| 평가 | 출결 10% · 과제 10% · 실습·발표 가점 등 20% · 중간고사(개인별 과제) 30% · 기말고사(팀 프로젝트) 30% |

**교과목표**

- 내·외부 및 정형·비정형 데이터를 활용해 분석 목적에 따라 가설을 설정하고, 필요한 데이터
  세트를 편성하여 통계기반 분석 모델을 만들고 평가
- 가설 설정 → 모델 개발 → 모델 평가·검증 → 모델 운영방안 마련으로 이어지는 이론과 실습
- 머신러닝·딥러닝을 위한 기초 과목

**참고문헌**

- 국·내외 논문자료 및 담당 교수 논문, Hand out, 교수가 제공하는 데이터 및 URL
- 『제대로 알고 쓰는 R 통계분석』 이윤환, 한빛미디어
- ChatGPT 등 생성형 AI 활용 가능 (과제 제출 시 사용한 프롬프트를 함께 제시)

**운영 특징**

- 팀별 연구 프로젝트 중심. 논문 등의 연구모형을 기반으로 설문지 작성, 데이터 수집,
  공공데이터 활용을 진행
- 중간고사는 R 프로그래밍 개인 과제로 진행하며, Python 추가 작업 시 가점
- 기말고사는 팀 프로젝트 발표로 대체

<br/>

### 주차별 계획 (강의계획서 기준)

| 주차 | 주제 | 형태 |
|------|------|------|
| 01 | 통계기반 데이터 분석 개요 | 수업 (대면) |
| 02 | 확률과 확률분포 | 수업/발표 (대면) |
| 03 | 표본분포, 추정 | 수업/발표 (대면) |
| 04 | 가설검정 | 수업/발표 (대면) |
| 05 | 모집단의 평균비교 검정 | 수업/발표 (대면) |
| 06 | 범주형 자료분석 | 수업/발표 (대면) |
| 07 | 상관과 회귀 | 수업/발표 (대면) |
| 08 | 《중간고사》 | — |
| 09 | 선행연구, 데이터 연구모형 분석·평가 | 수업/팀플 (ZOOM) |
| 10 | 프로젝트: 선행연구 검토, 팀별 연구모형 작성 | 수업/팀플 (ZOOM) |
| 11 | 프로젝트: 연구모형에 따른 데이터 수집, 공공데이터 수집 | 수업/팀플 (ZOOM) |
| 12 | 프로젝트: 연구모형에 따른 가설검증 | 수업/팀플 (ZOOM) |
| 13 | 프로젝트: 연구모형에 따른 가설검증 멘토링 | 수업/팀플 (ZOOM) |
| 14 | 프로젝트: 가설검정 멘토링 | 수업/팀플 (ZOOM) |
| 15 | 프로젝트 팀별 최종 발표 I (기말고사) | 과제발표 (ZOOM) |
| 16 | 프로젝트 팀별 최종 발표 II (기말고사) | 과제발표 (ZOOM) |

<br/>

## 목록

아래는 실제로 보관 중인 자료 기준입니다. 실제 진행 순서는 강의계획서와 달라,
4~7주차가 회귀 → 상관 → 평균비교(t-검정) → 분산분석·로지스틱 회귀 순으로 다루어졌습니다.

| 순서 | 주제 | 자료 |
|------|------|------|
| - | [강의계획서](./syllabus.pdf) | Syllabus |
| 01 | [Introduction](./01-introduction) | PPT |
| 02 | [Probability and Distributions](./02-probability-and-distributions) | PPT |
| 03 | [Sampling Distribution and Estimation](./03-sampling-distribution-and-estimation) | PPT, 참고자료, 학생 발표자료 |
| 04 | [Regression Analysis](./04-regression-analysis) | PPT, 학생 발표자료, 실습 워크북 |
| 05 | [Correlation Analysis](./05-correlation-analysis) | PPT, 학생 발표자료, 실습 워크북 |
| 06 | [Comparing Population Means (t-test)](./06-comparing-population-means) | PPT, R 스크립트, 실습 데이터/워크북, 학생 발표자료 |
| 07 | [ANOVA and Logistic Regression](./07-anova-and-logistic-regression) | PPT, 실습 데이터 |
| 09 | [Prior Research and Research Model](./09-prior-research-and-research-model) | PPT |
| 10 | [Team Project: Topic Selection](./10-team-project-topic-selection) | PPT |
| - | [중간고사 (Midterm Exam)](./midterm-exam) | 리포트, R/Python 구현 |
| - | [기말고사 (Final Exam)](./final-exam) | 팀 프로젝트 제안서 |

<br/>

## 구성

```
1-1.Statistics_Based_Data_Analysis/
├── syllabus.pdf
├── 01-introduction/
├── 02-probability-and-distributions/
├── 03-sampling-distribution-and-estimation/
├── 04-regression-analysis/
├── 05-correlation-analysis/
├── 06-comparing-population-means/
├── 07-anova-and-logistic-regression/
├── 09-prior-research-and-research-model/
├── 10-team-project-topic-selection/
├── midterm-exam/
└── final-exam/
```

8주차는 중간고사 기간으로 별도 강의가 없었으며(강의계획서 기준), 11~14주차는
팀 프로젝트 진행·멘토링 주간으로 별도의 강의 슬라이드 없이 팀별 실습으로
진행되었습니다.

각 폴더의 `README.md`에는 해당 강의의 PPT와 실습 자료를 바탕으로 정리한
핵심 개념 요약이 담겨 있습니다.
