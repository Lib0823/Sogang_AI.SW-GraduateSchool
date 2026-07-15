# Weeks 10-11 — Web Scraping with BeautifulSoup: Samsung Electronics Stock Price

## 강의 자료
- [beautifulsoup-web-scraping-samsung-stock-price.ipynb](./beautifulsoup-web-scraping-samsung-stock-price.ipynb)

## 강의 내용 정리

### 1. 웹 스크래핑 기초 (Week 10)
웹 스크래핑 용어와 요청(request)/응답(response) 개념, `robots.txt`의 역할을 소개하고 Yahoo Finance와 Naver Finance의 `robots.txt`를 비교한다 (슬라이드 이미지 내용이라 세부 항목까지 팩트체크는 어려웠음).

`requests`와 `BeautifulSoup`의 기본 사용법을 직접 작성한 HTML 문자열(`<h1 id='title'>`, `<p id='body'>`, `<p class='scraping'>` 등)로 실습한다. `.stripped_strings`로 깔끔한 텍스트를 추출하는 방법과, `find()`/`find_all()`을 태그명·`id`·`class_`·범용 `attrs={...}` 딕셔너리로 사용하는 방법을 다룬다.

### 2. 실전 스크래핑 — 삼성전자 주가 (Week 11)
Yahoo Finance의 삼성전자(005930.KS) 주가 히스토리 페이지(`https://finance.yahoo.com/quote/005930.KS/history/`)를 대상으로 한다.

- 헤더 없이 요청하면 **HTTP 404**로 차단되는 것을 먼저 보여준 뒤, 크롬 개발자 도구(Network 탭)에서 실제 `User-Agent`/`Accept` 헤더 값을 확인해 요청에 포함시키면 정상적으로 데이터를 받아올 수 있음을 단계별로 시연한다. Yahoo Finance가 기본 `requests` User-Agent를 차단한다는 설명은 기술적으로 정확하다.
- Yahoo Finance는 CSS 클래스명이 자동 생성되어 방문 시점마다 바뀐다는 점(2024-08-08 관측: `yf-ewueuo`, 2024-11-13 관측: `yf-j5d1ld`)을 지적하며, 클래스명을 하드코딩하지 않고 `first_tr.get('class')[0]`로 첫 번째 `<tr>`의 클래스를 동적으로 추출해 사용하는 안정적인 패턴을 가르친다.
- `<td>` 인덱스 기준으로 날짜/시가/고가/저가/종가/수정종가/거래량 7개 값을 추출하고, `pandas.to_datetime`으로 날짜를 "YYYY년 MM월 DD일" 형식으로 변환하며, 종가의 ".00"을 "원"으로 치환하는 등 후처리를 한다.
- 전체 `<tr>` 행을 순회하며 헤더 행은 건너뛰고, 배당(dividend) 행은 `<td>` 셀이 2개뿐이라는 특징을 이용해 `len(cells) == 7` 조건으로 걸러낸다.

### 참고
노트북은 "수집한 데이터로 그래프 시각화하기"라는 마크다운 제목과 슬라이드 이미지에서 끝나며, 실제 시각화 코드는 파일에 포함되어 있지 않다 (강의계획서상 언급된 "시계열 시각화" 부분은 강의 중 라이브 코딩으로 다뤄졌을 가능성이 높다). HTTP 헤더/404 관련 설명에서 기술적 오류는 발견되지 않았다.
