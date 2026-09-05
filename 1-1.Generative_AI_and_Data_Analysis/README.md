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

## 목록

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
