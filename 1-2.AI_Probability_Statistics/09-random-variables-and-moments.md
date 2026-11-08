# 인공지능확률통계 — 확률변수, 평균·분산, 베이즈 룰, Bernoulli/Binomial

> 강의일: 2026.10.27
> 교재: **Kevin P. Murphy, *Probabilistic Machine Learning: An Introduction* (PML1) — Chapter 2 "Probability: Univariate Models"** 2.1 ~ 2.4
> - 교재 페이지: https://probml.github.io/pml-book/book1.html
> - 무료 PDF(GitHub 배포본): https://github.com/probml/pml-book/releases/latest/download/book1.pdf
> - 상세 목차: https://probml.github.io/pml-book/toc1.pdf

| 이번 강의 범위 | PML1 절 |
|---|---|
| 확률의 두 가지 해석, 사건 확률 규칙 | 2.1 |
| 확률변수, PMF/CDF/PDF, 독립, 평균·분산 | 2.2.1 ~ 2.2.5 |
| 요약 통계의 한계 (Anscombe, Datasaurus) | 2.2.6 |
| 베이즈 룰, COVID-19 검사 예제 | 2.3 |
| Bernoulli / Binomial, Sigmoid, Logistic regression | 2.4 |

---

## 0. 한 장 요약

- **Random variable(확률변수)** = 사건(event)을 숫자로 바꿔 주는 함수임
- 연속형은 **CDF**(누적확률)를 미분하면 **PDF**(확률밀도)가 됨. 확률 = PDF를 구간에서 적분한 값
- 분포 전체를 숫자 하나로 요약하면 **평균(Expectation)**, 퍼진 정도는 **분산(Variance)**
- 평균은 **선형**임: $E[aX+b]=aE[X]+b$, $E[X_1+X_2]=E[X_1]+E[X_2]$ (독립 아니어도 성립)
- 분산은 $V[X]=E[X^2]-\mu^2$, $V[aX+b]=a^2V[X]$, **독립이면** $V[X_1+X_2]=V[X_1]+V[X_2]$
- 평균·표준편차가 같아도 데이터 모양은 완전히 다를 수 있음 → **반드시 그려 볼 것** (Datasaurus Dozen)
- 베이즈 룰로 "양성이 나왔을 때 진짜 걸렸을 확률"을 계산함 → 사전확률(유병률)에 크게 좌우됨
- 딥러닝 이진 분류의 출력 = **Bernoulli 분포의 파라미터 θ**. 신경망 출력 $f$에 **sigmoid**를 씌워서 θ를 만듦

---

## 1. 확률이란 무엇인가 — 두 가지 해석 (2.1.1)

| 해석 | 확률의 의미 | 예시 |
|---|---|---|
| **Frequentist interpretation** (빈도주의) | 실험을 **무한히 반복**했을 때 사건이 일어나는 **비율** | 동전을 10,000번 던지면 앞면이 약 5,000번 → P(앞면)=0.5 |
| **Bayesian interpretation** (베이지안) | 어떤 명제에 대한 **불확실성(믿음의 정도)** | "내일 비가 올 확률 70%" — 내일은 한 번뿐이라 반복 실험 불가 |

- 베이지안 해석은 **반복할 수 없는 일회성 사건**에도 확률을 쓸 수 있다는 장점이 있음 (예: "북극 빙하가 2030년까지 녹을 확률")
- 계산 규칙(합 규칙, 곱 규칙 등)은 두 해석 모두 **똑같음**. 차이는 "확률을 어떻게 받아들이느냐"임
- 이 수업(그리고 머신러닝 전반)은 주로 **베이지안 관점**을 씀

### 불확실성의 두 종류 (2.1.2, 교재 보충)

- **Epistemic uncertainty (모델 불확실성)**: 우리가 **몰라서** 생기는 불확실성 → 데이터를 더 모으면 줄어듦
- **Aleatoric uncertainty (데이터 불확실성)**: 현상 자체가 **원래 랜덤**해서 생기는 불확실성 → 데이터를 아무리 모아도 안 줄어듦 (공정한 동전은 아무리 던져 봐도 다음 결과를 50% 이상 맞힐 수 없음)

---

## 2. 사건(Event)에 대한 확률 규칙 복습 (2.1.3)

| 이름 | 식 | 읽는 법 / 의미 |
|---|---|---|
| Conjunction (AND) | $P(A \wedge B) = P(A, B)$ | A와 B가 **동시에** 일어날 확률 |
| 독립일 때 | $P(A, B) = P(A)\,P(B)$ | 독립이면 **곱하기**로 바뀜 |
| Union (OR) | $P(A \vee B) = P(A)+P(B)-P(A,B)$ | 겹치는 부분을 한 번 빼 줌 |
| Conditional | $P(B \mid A) = \dfrac{P(A,B)}{P(A)}$ | "A가 일어났다는 걸 알 때 B의 확률" |
| **Product rule** | $P(A,B) = P(B \mid A)\,P(A)$ | 조건부 확률 식을 뒤집은 것 |

### 독립과 조건부 독립

- **독립(Independence)**: $A \perp B \iff P(A,B)=P(A)P(B)$
- **조건부 독립(Conditional independence)**: $A \perp B \mid C \iff P(A,B \mid C) = P(A \mid C)\,P(B \mid C)$
  - 읽는 법: "C가 주어지면 A와 B는 독립이다"
  - 예: (A=아이의 신발 크기, B=아이의 어휘력) → 둘은 상관이 있어 보이지만, **C=나이**를 알면 독립이 됨. 나이가 둘 다를 결정하기 때문임
  - 주의: 그냥 독립이라고 조건부 독립인 것도 아니고, 조건부 독립이라고 그냥 독립인 것도 아님

---

## 3. 확률변수 (Random Variable) (2.2)

### 3.1 정의

> **Random variable X = 표본공간(일어날 수 있는 모든 결과)의 각 결과를 숫자로 매핑하는 함수**

- 이름은 "변수"지만 실제로는 **함수**임
- 예 1: 주사위 → 나온 눈 그대로 1~6
- 예 2: 동전 2개 던지기 → 결과 {HH, HT, TH, TT}를 "앞면 개수"로 매핑 → HH↦2, HT↦1, TH↦1, TT↦0
- 이렇게 숫자로 바꿔야 평균·분산 같은 **계산**을 할 수 있음

표기 규칙: 대문자 $X$ = 확률변수 자체, 소문자 $x$ = 그 변수가 가지는 특정 값

### 3.2 Discrete(이산) 확률변수 — PMF (2.2.1)

- 값이 셀 수 있는 개수(유한 또는 1, 2, 3, …)인 경우
- **PMF (Probability Mass Function)**: $p(x) = \Pr(X = x)$
- 조건: $0 \le p(x) \le 1$, $\sum_x p(x) = 1$
- 예: 공정한 주사위 → $p(1)=\cdots=p(6)=1/6$

### 3.3 Continuous(연속) 확률변수 — CDF와 PDF (2.2.2)

연속형은 값이 무한히 많아서 **"정확히 X=3.000…일 확률"은 0**임. 그래서 "구간에 들어갈 확률"로 다룸.

**① CDF (Cumulative Distribution Function, 누적분포함수)** — 대문자 P로 씀

$$P(x) = \Pr(X \le x)$$

- 읽는 법: "X가 x **이하**일 확률"
- 성질: 단조증가, $x\to-\infty$이면 0, $x\to+\infty$이면 1
- 구간 확률: $\Pr(a < X \le b) = P(b) - P(a)$
  - 직관: "b까지 누적된 확률"에서 "a까지 누적된 확률"을 빼면 **a와 b 사이**만 남음

**② PDF (Probability Density Function, 확률밀도함수)** — 소문자 p로 씀

$$p(x) = \frac{d}{dx}P(x)$$

- **PDF = CDF를 미분한 것**, 거꾸로 **CDF = PDF를 적분한 것**
- 구간 확률을 PDF로 쓰면:

$$\Pr(a < X \le b) = \int_a^b p(x)\,dx = P(b) - P(a)$$

- 구간을 아주 짧게($dx$) 잡으면 적분이 그냥 **높이 × 폭**이 됨:

$$\Pr(x \le X \le x+dx) \approx p(x)\,dx$$

  → "밀도(density) × 짧은 구간 길이 = 그 구간의 확률". 물리에서 밀도 × 부피 = 질량과 같은 개념임

**⚠ 헷갈리기 쉬운 점: PDF 값은 1보다 클 수 있음**
- 예: $[0, 0.5]$ 구간의 균등분포 → 넓이가 1이 되려면 높이가 2여야 함 → $p(x)=2$
- PDF는 **확률이 아니라 밀도**이고, **넓이(적분값)** 가 확률임

| | Discrete | Continuous |
|---|---|---|
| 함수 | PMF $p(x)=\Pr(X=x)$ | PDF $p(x)$ (밀도) |
| 합이 1 | $\sum_x p(x)=1$ | $\int p(x)dx=1$ |
| 값의 범위 | $0\le p(x)\le1$ | $p(x)\ge0$ (1 넘을 수 있음) |
| 특정 값 확률 | $p(x)$ | 항상 0 |

**Quantile (교재 보충)**: CDF의 역함수 $P^{-1}(q)$. 예: 중앙값(median) = $P^{-1}(0.5)$, 즉 "누적확률이 50%가 되는 x"

### 3.4 여러 확률변수 다루기 (2.2.3)

1~5주차에 배운 규칙을 확률변수 버전으로 쓴 것뿐임.

- **Joint**: $p(x, y)$
- **Marginal (Sum rule)**: $p(x) = \sum_y p(x, y)$ — y를 다 더해서 없앰
- **Conditional**: $p(y \mid x) = p(x,y)/p(x)$
- **Product rule**: $p(x, y) = p(x)\,p(y \mid x)$
- **Chain rule** = product rule을 변수 여러 개로 확장한 것:

$$p(x_1, x_2, x_3, \ldots, x_D) = p(x_1)\,p(x_2 \mid x_1)\,p(x_3 \mid x_1, x_2)\cdots p(x_D \mid x_1,\ldots,x_{D-1})$$

  - 읽는 법: "첫 번째 확률 × (첫 번째를 알 때 두 번째) × (앞 두 개를 알 때 세 번째) × …"

### 3.5 확률변수의 독립 (2.2.4)

- $X \perp Y \iff p(X, Y) = p(X)\,p(Y)$ — joint가 각각의 곱으로 **나뉨(분리됨)**
- 여러 개가 서로 독립(mutually independent)이면 $p(X_1,\ldots,X_n)=\prod_i p(X_i)$
- 조건부 독립: $X \perp Y \mid Z \iff p(X,Y \mid Z) = p(X \mid Z)\,p(Y \mid Z)$

---

## 4. 분포의 요약 — 평균과 분산 (Moments, 2.2.5)

분포 전체(함수)를 들고 다니기는 번거로우니, **숫자 1~2개로 대표**하고 싶음 → 그게 평균과 분산임.

### 4.1 평균 (Mean, Expectation)

$$E[X] = \sum_x x\,p(x) \quad(\text{이산}), \qquad E[X] = \int x\,p(x)\,dx \quad(\text{연속})$$

- 읽는 법: "**값 × 그 값의 확률**을 X의 도메인 전체에 대해 다 더한 것" = **가중평균**
- 기호: $E[X]$ = "expectation of X", 보통 $\mu$(뮤)로 씀
- 예: 주사위 $E[X] = 1\cdot\tfrac16 + 2\cdot\tfrac16 + \cdots + 6\cdot\tfrac16 = \tfrac{21}{6} = 3.5$
  - 주사위에 3.5라는 눈은 없지만, "많이 던지면 평균이 3.5에 가까워진다"는 뜻임

#### 평균의 선형성 (Linearity of expectation) — 매우 중요

**(1) 상수배·상수합**

$$E[aX + b] = aE[X] + b$$

유도 (연속형):
$$E[aX+b] = \int (ax+b)\,p(x)\,dx = a\underbrace{\int x\,p(x)\,dx}_{E[X]} + b\underbrace{\int p(x)\,dx}_{=1} = aE[X]+b$$

- 예: 주사위 눈에 2배 하고 1 더하면 평균 = 2×3.5+1 = 8

**(2) 여러 변수의 합**

$$E\Big[\sum_{i=1}^n X_i\Big] = \sum_{i=1}^n E[X_i]$$

- "합의 평균 = 평균의 합"
- **독립이 아니어도 항상 성립**함 ← 시험 포인트
- 예: 주사위 2개 합의 평균 = 3.5 + 3.5 = 7

**(3) 여러 변수의 곱 — 독립일 때만**

$$E\Big[\prod_{i} X_i\Big] = \prod_i E[X_i] \quad (\text{독립일 때만})$$

- 독립이면 $p(x,y)=p(x)p(y)$로 나뉘니까 적분도 각각으로 나뉨:
$$E[XY]=\iint xy\,p(x)p(y)\,dx\,dy = \int x\,p(x)dx \cdot \int y\,p(y)dy = E[X]E[Y]$$

### 4.2 분산 (Variance)

> 분산 = 분포가 평균에서 **옆으로 얼마나 퍼져 있는가**를 나타내는 수치

$$V[X] = E\big[(X-\mu)^2\big], \qquad \mu = E[X]$$

- 읽는 법: "확률변수에서 **평균을 빼고**, **제곱**해서, 그걸 **평균** 낸 것"
- 왜 제곱? 평균보다 큰 쪽(+)과 작은 쪽(−)이 상쇄되지 않게 하려고
- **표준편차(Standard deviation)** $\sigma = \sqrt{V[X]}$ → 원래 단위로 되돌린 것

#### 계산용 공식: $V[X] = E[X^2] - \mu^2$ (단계별 유도)

$$
\begin{aligned}
V[X] &= E[(X-\mu)^2] \\
&= E[X^2 - 2\mu X + \mu^2] && \text{(제곱 전개)}\\
&= E[X^2] - 2\mu\,E[X] + \mu^2 && \text{(선형성. } \mu\text{는 이미 계산된 상수라 밖으로 나옴)}\\
&= E[X^2] - 2\mu^2 + \mu^2 && (E[X]=\mu)\\
&= E[X^2] - \mu^2
\end{aligned}
$$

- 핵심 포인트: **μ는 이미 계산이 끝난 숫자(상수)** 라서 적분 기호(E) 밖으로 꺼낼 수 있음
- 말로: "**분산 = 제곱의 평균 − 평균의 제곱**"

**예: 주사위**
- $E[X^2] = (1+4+9+16+25+36)/6 = 91/6 \approx 15.17$
- $\mu^2 = 3.5^2 = 12.25$
- $V[X] = 91/6 - 12.25 = 35/12 \approx 2.92$, $\sigma \approx 1.71$

#### 선형변환의 분산: $V[aX+b] = a^2 V[X]$

$$
\begin{aligned}
V[aX+b] &= E\big[(aX+b - E[aX+b])^2\big] && \text{(정의: 자기 자신에서 자기 평균을 뺌)}\\
&= E\big[(aX+b - a\mu - b)^2\big] && (E[aX+b]=a\mu+b)\\
&= E\big[a^2 (X-\mu)^2\big] = a^2\,V[X]
\end{aligned}
$$

- **b(평행이동)는 분산에 영향 없음** — 전체를 옆으로 밀어도 퍼진 정도는 그대로
- **a(크기 조절)는 제곱으로 영향** — 2배 늘리면 분산은 4배
- 예: 주사위 눈 ×2 +1 → 분산 = 4 × 35/12 ≈ 11.67

### 4.3 합의 분산과 독립 — 교차항이 0이 되는 이유

변수 2개로 먼저 보면 ($\mu_i = E[X_i]$):

$$
\begin{aligned}
V[X_1 + X_2] &= E\big[(X_1-\mu_1 + X_2-\mu_2)^2\big] \\
&= E[(X_1-\mu_1)^2] + E[(X_2-\mu_2)^2] + 2\,E[(X_1-\mu_1)(X_2-\mu_2)] \\
&= V[X_1] + V[X_2] + 2\,\underbrace{\mathrm{Cov}[X_1, X_2]}_{\text{교차항}}
\end{aligned}
$$

변수 3개면 $(a+b+c)^2 = a^2+b^2+c^2+2ab+2bc+2ca$ 처럼 펼쳐짐:

$$V[X_1+X_2+X_3] = V[X_1]+V[X_2]+V[X_3] + 2\,\mathrm{Cov}[X_1,X_2] + 2\,\mathrm{Cov}[X_2,X_3] + 2\,\mathrm{Cov}[X_3,X_1]$$

**독립이면 교차항이 0이 됨:**

$$E[(X_1-\mu_1)(X_2-\mu_2)] \overset{\text{독립}}{=} E[X_1-\mu_1]\cdot E[X_2-\mu_2] = (\mu_1-\mu_1)(\mu_2-\mu_2) = 0 \cdot 0 = 0$$

- 독립 → 곱의 평균이 **각각으로 나뉨** → 각각은 "평균에서 평균을 뺀 것의 평균"이라 0 → 교차항 전부 0
- 그래서 **독립이면**:

$$V\Big[\sum_i X_i\Big] = \sum_i V[X_i]$$

- **독립이 아니면 분리가 안 됨** → 교차항(공분산)이 남음

**예 (독립)**: 주사위 2개를 따로 던져 합 → $V = 35/12 + 35/12 = 35/6 \approx 5.83$
**반례 (독립 아님)**: $X_2 = X_1$ (같은 주사위 값을 두 번 셈) → $X_1+X_2 = 2X_1$ → $V = 4 \times 35/12 \approx 11.67$. 단순히 더한 5.83과 다름

| 공식 | 성립 조건 |
|---|---|
| $E[X+Y]=E[X]+E[Y]$ | **항상** |
| $E[XY]=E[X]E[Y]$ | 독립 |
| $V[aX+b]=a^2V[X]$ | 항상 |
| $V[X+Y]=V[X]+V[Y]$ | 독립 (정확히는 Cov=0) |

### 4.4 Mode (최빈값, 교재 보충)

- 확률(밀도)이 **가장 높은** 값: $x^* = \arg\max_x p(x)$
- 분포의 봉우리가 여러 개(multimodal)면 mode도 여러 개일 수 있음

---

## 5. 요약 통계의 한계 (Limitations of summary statistics, 2.2.6)

> **평균과 표준편차가 비슷하다고 해서 두 데이터셋이 비슷하게 분포한다고 생각하면 큰일 남**

### Anscombe's quartet

- 데이터셋 4개, 각각 점 11개
- 4개 모두 x 평균 = 9, y 평균 ≈ 7.50, x 분산 = 11, y 분산 ≈ 4.12, 상관계수 ≈ 0.816, 회귀직선 $y \approx 3 + 0.5x$로 **거의 같음**
- 그런데 그려 보면 하나는 직선 경향, 하나는 곡선, 하나는 이상치 1개가 결과를 끌고 감 등 모양이 전부 다름

### Datasaurus Dozen

- 데이터셋 13개, **각 142개 점** (2차원 x, y)
- 13개 모두 x/y 평균, x/y 표준편차, 상관계수가 소수점 둘째 자리까지 같음 (x 평균 ≈ 54.26, y 평균 ≈ 47.83, x 표준편차 ≈ 16.76, y 표준편차 ≈ 26.93, 상관계수 ≈ −0.06)
- 그런데 그려 보면 공룡 모양, 별, 원, 줄무늬, X자 등 완전히 다름
- 생성 방법: Matejka & Fitzmaurice (2017), *"Same Stats, Different Graphs"* — 요약 통계가 거의 변하지 않도록 유지하면서 점을 조금씩 움직여 목표 모양에 가깝게 만드는 방식(simulated annealing). 논문 꼭 읽어 볼 것

### 교훈

- 1차원뿐 아니라 2차원에서도 이런 일이 생김
- 숫자 몇 개만 보고 "맞겠지" 하고 넘어가지 말고 **항상 직접 시각화**해서 눈으로 확인해야 함
- 요약 통계는 분포의 **일부 정보만** 담고 있다는 것을 기억할 것

---

## 6. 베이즈 룰 (Bayes' rule, 2.3)

$$p(H = h \mid Y = y) = \frac{p(Y=y \mid H=h)\;p(H=h)}{p(Y=y)}$$

| 항 | 이름 | 의미 |
|---|---|---|
| $p(H)$ | **Prior** | 데이터를 보기 전 가설 H에 대한 믿음 |
| $p(Y \mid H)$ | **Likelihood** | 가설 H가 맞다면 관측 Y가 나올 확률 |
| $p(Y)$ | **Marginal likelihood / Evidence** | $\sum_h p(Y \mid h)p(h)$ — 정규화 상수 |
| $p(H \mid Y)$ | **Posterior** | 데이터를 본 후 업데이트된 믿음 |

### 6.1 예제: COVID-19 검사 (2.3.1)

**문제**: 검사 결과가 양성(또는 음성)일 때, **내가 진짜로 걸렸을 확률**은?

변수 정의
- $H$ = 실제 감염 여부 (1 = 감염, 0 = 비감염) → 숨겨진 상태
- $Y$ = 검사 결과 (1 = 양성, 0 = 음성) → 관측값

검사 성능 (교재 수치)
- **Sensitivity (민감도, true positive rate)**: $p(Y=1 \mid H=1) = 0.875$ → 감염자를 양성으로 잡아낼 확률
- **Specificity (특이도, true negative rate)**: $p(Y=0 \mid H=0) = 0.975$ → 비감염자를 음성으로 판정할 확률
  - 따라서 **False positive rate** $p(Y=1 \mid H=0) = 1 - 0.975 = 0.025$
  - **False negative rate** $p(Y=0 \mid H=1) = 1 - 0.875 = 0.125$
- **Prior (유병률, base rate)**: $p(H=1) = 0.1$ (인구의 10%가 감염되어 있다고 가정)

**① 양성이 나왔을 때**

$$
p(H=1 \mid Y=1) = \frac{0.875 \times 0.1}{\underbrace{0.875 \times 0.1}_{\text{진짜 양성}} + \underbrace{0.025 \times 0.9}_{\text{가짜 양성}}} = \frac{0.0875}{0.0875 + 0.0225} = \frac{0.0875}{0.11} \approx 0.795
$$

→ 양성이어도 진짜 감염일 확률은 **약 79.5%** (87.5%가 아님!)

**② 음성이 나왔을 때**

$$
p(H=1 \mid Y=0) = \frac{0.125 \times 0.1}{0.125 \times 0.1 + 0.975 \times 0.9} = \frac{0.0125}{0.89} \approx 0.014
$$

→ 음성이면 감염일 확률은 약 1.4%

**③ 유병률이 1%로 낮아지면? (같은 검사)**

$$p(H=1 \mid Y=1) = \frac{0.875 \times 0.01}{0.875 \times 0.01 + 0.025 \times 0.99} \approx 0.261$$

→ 양성이어도 진짜 감염일 확률이 **약 26%** 로 뚝 떨어짐

#### 직관: 1,000명으로 세어 보기 (유병률 10%)

| | 양성 (Y=1) | 음성 (Y=0) | 합계 |
|---|---|---|---|
| 감염 (H=1) | 87.5 | 12.5 | 100 |
| 비감염 (H=0) | 22.5 | 877.5 | 900 |
| 합계 | **110** | 890 | 1000 |

- 양성 110명 중 진짜 감염자는 87.5명 → 87.5/110 ≈ 79.5%
- 비감염자가 훨씬 많아서, 오진율 2.5%만으로도 가짜 양성이 22.5명이나 생김

> **Base rate fallacy (기저율 오류)**: likelihood(검사 정확도)만 보고 prior(유병률)를 무시하는 실수. $p(H=1\mid Y=1)$과 $p(Y=1\mid H=1)$은 **완전히 다른 값**임

### 6.2 Monty Hall 문제 (2.3.2)

- 앞선 주차에서 정리함 (선택을 바꾸면 이길 확률 2/3). 교재 2.3.2에 같은 문제가 베이즈 룰 예제로 나옴

---

## 7. Bernoulli / Binomial 분포 (2.4)

### 7.1 Bernoulli 분포 — 동전 1개

- 결과가 2개뿐인 실험: $Y \in \{0, 1\}$ (예: 뒷면=0, 앞면=1 / 고양이=0, 개=1)
- 파라미터 **θ (theta)** = $p(Y=1)$ = 앞면이 나올 확률, $0 \le \theta \le 1$

$$\mathrm{Ber}(y \mid \theta) = \theta^{y}(1-\theta)^{1-y}$$

- 읽는 법: "θ가 주어졌을 때 y의 Bernoulli 확률"
- 한 줄 식이지만 사실 if문임: $y=1$이면 $\theta^1(1-\theta)^0=\theta$, $y=0$이면 $\theta^0(1-\theta)^1 = 1-\theta$
- 평균 $E[Y]=\theta$, 분산 $V[Y]=\theta(1-\theta)$
  - 확인: $E[Y]=1\cdot\theta + 0\cdot(1-\theta)=\theta$, $E[Y^2]=\theta$ → $V = \theta - \theta^2 = \theta(1-\theta)$

### 7.2 Binomial 분포 — 동전 N개

- 동전 N개를 (독립적으로) 던졌을 때 **앞면이 몇 개 나오는가**가 출력
- $Y \sim \mathrm{Bin}(N, \theta)$, Y가 가질 수 있는 값: $0, 1, 2, \ldots, N$
- PMF를 정하려면 **N과 θ 둘 다** 있어야 함

$$\mathrm{Bin}(y \mid N, \theta) = \binom{N}{y}\,\theta^{y}(1-\theta)^{N-y}, \qquad \binom{N}{y} = \frac{N!}{(N-y)!\,y!}$$

식의 각 조각 의미
- $\theta^y$: 앞면 y개가 나올 확률
- $(1-\theta)^{N-y}$: 나머지 N−y개가 뒷면일 확률
- $\binom{N}{y}$: N개 중 **어느** y개가 앞면인지 고르는 경우의 수

**예: N=3, θ=0.5**

| y (앞면 개수) | 경우의 수 $\binom{3}{y}$ | 확률 |
|---|---|---|
| 0 | 1 (TTT) | 1/8 |
| 1 | 3 (HTT, THT, TTH) | 3/8 |
| 2 | 3 | 3/8 |
| 3 | 1 (HHH) | 1/8 |

- 합 = 8/8 = 1 ✔
- N=1이면 Binomial = Bernoulli

**4절과 연결**: Binomial은 독립인 Bernoulli N개의 합이므로
- $E[Y] = \sum E[Y_i] = N\theta$ (선형성)
- $V[Y] = \sum V[Y_i] = N\theta(1-\theta)$ (독립이라 교차항 0)
- 예: N=3, θ=0.5 → 평균 1.5, 분산 0.75

---

## 8. Sigmoid와 Logistic regression — 딥러닝과의 연결 (2.4.2 ~ 2.4.3)

### 8.1 아이디어: 신경망은 "확률(θ)"을 학습함

- 입력 x(예: 사진)를 보고 개(1)인지 고양이(0)인지 예측하고 싶음
- 출력을 Bernoulli로 모델링: $p(y \mid x, \theta) = \mathrm{Ber}(y \mid \theta)$
- 이때 **θ는 입력 x에 따라 달라져야 함** → 신경망이 x를 받아 θ를 내놓게 만듦
- 즉 **뉴럴 네트워크의 끝에서 튀어나오는 값 = θ** (Bernoulli의 파라미터)
- 우리가 학습시키는 건 "정답 라벨"이 아니라 **확률**임

### 8.2 문제: 신경망 출력은 아무 실수나 나옴 → Sigmoid로 0~1에 넣기

- 신경망(또는 선형식)의 출력 $f(x;\theta)$는 $-\infty \sim +\infty$의 아무 값 (이걸 **logit** 또는 pre-activation이라 함)
- 그런데 θ는 확률이라 0~1 사이여야 함
- → **Sigmoid(logistic) 함수**로 눌러 담음:

$$\sigma(a) = \frac{1}{1 + e^{-a}}, \qquad p(y=1 \mid x) = \sigma\big(f(x;\theta)\big)$$

동작 확인
| a | $e^{-a}$ | $\sigma(a)$ |
|---|---|---|
| 0 | 1 | 1/(1+1) = **0.5** |
| 2 | ≈ 0.135 | ≈ 0.881 |
| −2 | ≈ 7.39 | ≈ 0.119 |
| +∞ (아주 큼) | → 0 | → **1** |
| −∞ (아주 작음) | → ∞ | → **0** |

- f가 0이면 확률 0.5 (반반), f가 아주 커지면 $e^{-f}$ 텀이 0이 되어 전체가 1이 됨
- 성질 (교재 보충): $1-\sigma(a) = \sigma(-a)$, 역함수는 $a = \log\dfrac{\theta}{1-\theta}$ (**log-odds, logit**)

### 8.3 출력 θ를 어떻게 쓰나

1. **Hard decision**: θ > 0.5 이면 "개", 아니면 "고양이"로 딱 잘라 결정 (일반적인 분류)
2. **Random sampling**: θ를 확률로 보고 Bernoulli에서 **샘플링** → 그 결과로 개/고양이가 튀어나옴 (생성 모델 관점)

전체 흐름:

```
데이터 x ──► 피처 f(x; w) ──► sigmoid ──► θ (0~1) ──► Bernoulli/Binomial ──► y (개/고양이)
           (실수 아무 값)                 (확률)        (판정 또는 샘플링)
```

### 8.4 피처 f를 만드는 방법 — Binary logistic regression

- **피처 f = 웨이트(w)와 실제 데이터(x)의 결합**
- 가장 간단한 형태는 **linear combination**:

$$f(x; \theta) = b + w_1 x_1 + w_2 x_2 + \cdots + w_D x_D = \mathbf{w}^\top \mathbf{x} + b$$

- 이걸 sigmoid에 넣은 모델이 **binary logistic regression**:

$$p(y=1 \mid \mathbf{x}, \theta) = \sigma(\mathbf{w}^\top \mathbf{x} + b)$$

- 예전에는 이런 선형 형태로 많이 했음. **딥러닝은 이 f 자리를 깊은 신경망으로 바꾼 것**뿐이고, 마지막 sigmoid + Bernoulli 구조는 그대로임
- 작은 예: $b=-1, w_1=2, x_1=1.5$ → $f = -1 + 3 = 2$ → $\sigma(2) \approx 0.88$ → 88% 확률로 "개"

---

## 9. 공식 모음

| 구분 | 공식 |
|---|---|
| CDF | $P(x)=\Pr(X\le x)$ |
| PDF | $p(x)=\frac{d}{dx}P(x)$ |
| 구간 확률 | $\Pr(a<X\le b)=\int_a^b p(x)dx = P(b)-P(a)$ |
| 짧은 구간 | $\Pr(x\le X\le x+dx)\approx p(x)dx$ |
| Chain rule | $p(x_{1:D})=p(x_1)\prod_{d=2}^{D} p(x_d\mid x_{1:d-1})$ |
| 평균 | $E[X]=\sum_x x\,p(x)$ / $\int x\,p(x)dx$ |
| 선형성 | $E[aX+b]=aE[X]+b$, $E[\sum X_i]=\sum E[X_i]$ |
| 독립 곱 | $E[\prod X_i]=\prod E[X_i]$ |
| 분산 | $V[X]=E[(X-\mu)^2]=E[X^2]-\mu^2$ |
| 선형변환 분산 | $V[aX+b]=a^2V[X]$ |
| 독립 합 분산 | $V[\sum X_i]=\sum V[X_i]$ |
| 베이즈 룰 | $p(h\mid y)=\frac{p(y\mid h)p(h)}{\sum_{h'}p(y\mid h')p(h')}$ |
| Bernoulli | $\theta^y(1-\theta)^{1-y}$, 평균 θ, 분산 θ(1−θ) |
| Binomial | $\binom{N}{y}\theta^y(1-\theta)^{N-y}$, 평균 Nθ, 분산 Nθ(1−θ) |
| Sigmoid | $\sigma(a)=1/(1+e^{-a})$ |
| Logistic regression | $p(y=1\mid x)=\sigma(\mathbf{w}^\top\mathbf{x}+b)$ |

---

## 10. 용어 정리

| English | 한국어 | 한 줄 설명 |
|---|---|---|
| Frequentist interpretation | 빈도주의 해석 | 반복 실험의 장기 비율 |
| Bayesian interpretation | 베이지안 해석 | 믿음/불확실성의 정도 |
| Random variable | 확률변수 | 결과 → 숫자로 매핑하는 함수 |
| PMF | 확률질량함수 | 이산형 $\Pr(X=x)$ |
| CDF | 누적분포함수 | $\Pr(X\le x)$ |
| PDF | 확률밀도함수 | CDF의 미분, 적분해야 확률 |
| Quantile | 분위수 | CDF의 역함수 |
| Expectation / Mean | 기댓값 / 평균 | 값 × 확률의 합 |
| Variance | 분산 | 평균에서 얼마나 퍼졌나 |
| Standard deviation | 표준편차 | 분산의 제곱근 |
| Covariance | 공분산 | 합의 분산에서 교차항 |
| Linearity of expectation | 기댓값의 선형성 | 합의 평균 = 평균의 합 |
| Summary statistics | 요약 통계 | 평균·분산 등 대표 숫자 |
| Sensitivity | 민감도 | $p(\text{양성}\mid\text{감염})$ |
| Specificity | 특이도 | $p(\text{음성}\mid\text{비감염})$ |
| Base rate fallacy | 기저율 오류 | prior를 무시하는 실수 |
| Bernoulli distribution | 베르누이 분포 | 동전 1개 |
| Binomial distribution | 이항 분포 | 동전 N개 중 앞면 개수 |
| Sigmoid / Logistic function | 시그모이드 | 실수를 0~1로 |
| Logit / Log-odds | 로짓 | sigmoid의 입력값 |
| Logistic regression | 로지스틱 회귀 | 선형식 + sigmoid + Bernoulli |

---

## 11. 셀프 체크리스트

- [ ] Frequentist와 Bayesian 해석의 차이를 예시로 설명할 수 있는가?
- [ ] Random variable이 왜 "함수"인지 설명할 수 있는가?
- [ ] CDF와 PDF의 관계(미분/적분)를 쓰고, $\Pr(a<X\le b)$를 두 가지 방법으로 쓸 수 있는가?
- [ ] PDF 값이 1보다 클 수 있는 이유를 설명할 수 있는가?
- [ ] $V[X]=E[X^2]-\mu^2$를 처음부터 유도할 수 있는가?
- [ ] $V[aX+b]=a^2V[X]$를 유도하고, b가 사라지는 이유를 말할 수 있는가?
- [ ] $V[X_1+X_2+X_3]$를 전개하고, 독립일 때 교차항이 0이 되는 이유를 설명할 수 있는가?
- [ ] "합의 평균 = 평균의 합"은 독립이 필요 없고 "합의 분산 = 분산의 합"은 독립이 필요하다는 걸 구분하는가?
- [ ] Datasaurus Dozen이 주는 교훈을 말할 수 있는가?
- [ ] COVID 예제에서 $p(H=1\mid Y=1)\approx0.795$를 직접 계산할 수 있는가? 유병률이 바뀌면 어떻게 변하는지 설명할 수 있는가?
- [ ] Bernoulli, Binomial PMF를 쓰고 N=3, θ=0.5 표를 만들 수 있는가?
- [ ] 신경망 출력 → sigmoid → θ → Bernoulli 흐름을 설명할 수 있는가? σ(0)=0.5인 이유는?

## 12. 다음 할 일

- 분산 계산 연습 (주사위, Bernoulli, Binomial로 직접 계산해 보기)
- 확률변수와 Expectation operator의 선형성 정리 복습 (4.1 ~ 4.3)
- Datasaurus Dozen 논문 *"Same Stats, Different Graphs"* (Matejka & Fitzmaurice, 2017) 읽어 보기
- 예습: PML1 2.5 Categorical/Multinomial(Softmax), 2.6 Gaussian 분포