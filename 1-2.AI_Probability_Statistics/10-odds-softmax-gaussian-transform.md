# 인공지능확률통계 10주차 — Odds, Categorical/Softmax, Gaussian, 여러 분포, 확률변수 변환

> 강의일: 2026.11.03
> 교재: **Murphy, *Probabilistic Machine Learning: An Introduction* (PML1) Chapter 2** — 2.4.3 ~ 2.8
> PDF: https://github.com/probml/pml-book/releases/latest/download/book1.pdf

| 이번 강의 범위 | PML1 절 |
|---|---|
| Logistic regression 복습, Odds와 베이즈 룰 | 2.4.2 ~ 2.4.3 (+ 2.3) |
| Categorical / Multinomial, Softmax | 2.5 |
| Gaussian 분포, 독립 실험과 likelihood, Regression | 2.6 |
| Homoscedastic / Heteroscedastic, Softplus | 2.6.3 |
| Dirac delta | 2.6.5 |
| Student t, Cauchy, Laplace, Empirical distribution | 2.7 |
| 확률변수 변환 (Transformation of random variables) | 2.8 |

---

## 0. 한 장 요약

- 신경망 마지막 값 $h$에 **sigmoid**를 씌우면 확률이 됨. 학습할 파라미터 θ = 웨이트(w)라고 보면 됨
- **Odds** = $p/(1-p)$. 베이즈 룰을 odds로 쓰면 **posterior odds = Bayes factor × prior odds** (곱하기 한 번이면 끝)
- **log-odds**를 거꾸로 풀면 sigmoid가 나옴 → sigmoid는 "log-odds를 확률로 바꾸는 함수"임
- 클래스가 2개면 Bernoulli + sigmoid, **C개면 Categorical + softmax**
- Gaussian 데이터 N개가 **독립**이면 likelihood는 곱 → 로그 취하면 $\sum (y_n-\mu)^2$ 형태가 됨
- Regression = 평균이 $wx+b$인 Gaussian. σ가 x와 무관하면 **homoscedastic**, x에 따라 변하면 **heteroscedastic** (σ는 **softplus**로 양수 보장)
- Student t / Cauchy는 꼬리가 두꺼워 **이상치(outlier)에 robust**함
- **Empirical distribution** = 데이터 점마다 delta 함수를 1/N 높이로 꽂은 것
- **변환**: 이산은 "y로 가는 x들의 확률을 다 더함", 연속은 CDF로 계산하고 미분 (선형 변환이면 $|a|$로 나눔)

---

## 🚨 시험 포인트 (교수님 강조)

> | 우선순위 | 내용 | 위치 |
> |---|---|---|
> | 🔥🔥🔥 **기말시험 출제 예고** ("기말시험 꼭 해 봅시다") | 데이터 $\{0.1, 0.2, 0.7, -0.3\}$의 Gaussian **MLE 유도** — likelihood → log → 완전제곱 → $\hat\mu_{MLE}=\bar y$ | 4.4 |
> | 🔥🔥 **시험** 표시 | PDF로 평균 $E[Y]=\int y\,p(y)dy$, 분산 $V[Y]=E[Y^2]-\mu^2$ 유도, $E[Y^2]=\sigma^2+\mu^2$ | 4.2 |
> | ⭐ 별표 (중요) | 2.8 Transformations of random variables — discrete case | 6.1 |
> | ⭐ 시간 많이 투자 | 2.8.3.1 Change of variables: $p(x)dx = p(y)dy$ → $p_y(y)=p_x(x)\left\lvert\frac{dx}{dy}\right\rvert$ | 6.2 |
>
> **답안 작성 규칙**: 공식 결과(예: "$\bar y$")만 덜렁 쓰면 안 됨. **유도 과정을 종이에 디테일하게** 써야 함. 중간에 계산 실수가 있어도 과정이 있으면 괜찮음

---

## 1. 신경망 출력과 확률 — 복습 (2.4.3)

- 신경망은 내부에서 숫자의 범위(range)를 맞추는 등 여러 일을 하고, 마지막에 값 하나 $h$를 내놓음
- 이 $h$에 sigmoid를 통과시키면 최종 출력은 **확률**이 됨:

$$p(y=1 \mid x;\theta) = \sigma(h), \qquad h = f(x;\theta)$$

- $h$는 입력 **x에 의해 결정**되고, 동시에 **웨이트에도 의존**함
- 우리가 계산(학습)해야 하는 파라미터를 θ라고 쓰는데, **웨이트든 θ든 같은 의미**라고 생각하면 됨
- 가장 단순한 경우가 $h = \mathbf{w}^\top\mathbf{x}+b$ → **binary logistic regression**

---

## 2. Odds와 베이즈 룰

### 2.1 Odds란?

$$\text{odds}(p) = \frac{p}{1-p}$$

- 읽는 법: "일어날 확률 ÷ 안 일어날 확률"
- 예: 앞면 확률 $p=0.25$ → 뒷면 확률 $1-p=0.75$ → odds = 0.25/0.75 = **1/3** ("1 대 3")
- 예: $p=0.5$ → odds = 1 ("반반"), $p=0.9$ → odds = 9

**Odds → 확률로 되돌리기**

$$p = \frac{\text{odds}}{1+\text{odds}}$$

- 예: "7 대 3"이면 odds = 7/3 → $p = \dfrac{7}{7+3} = 0.7$
- 예: odds = 1/3 → $p = \dfrac{1/3}{1+1/3} = \dfrac{1}{4} = 0.25$ ✔

### 2.2 베이즈 룰의 Odds 형태

가설 H와 그 반대(complement) $\bar H$ 각각에 베이즈 룰을 쓰면:

$$p(H\mid D)=\frac{p(D\mid H)\,p(H)}{p(D)}, \qquad p(\bar H\mid D)=\frac{p(D\mid \bar H)\,p(\bar H)}{p(D)}$$

**둘을 나누면** 골치 아픈 분모 $p(D)$가 약분되어 사라짐:

$$\underbrace{\frac{p(H\mid D)}{p(\bar H\mid D)}}_{\text{posterior odds}} = \underbrace{\frac{p(D\mid H)}{p(D\mid \bar H)}}_{\text{Bayes factor (likelihood ratio)}} \times \underbrace{\frac{p(H)}{p(\bar H)}}_{\text{prior odds}}$$

- 비율(ratio)을 계산하려면 H만이 아니라 **complement $\bar H$에 대한 것도 같이 계산**해야 함
- 결론: **사후 odds = Bayes factor × 사전 odds**

**예: 지난주 COVID 검사를 odds로 다시 풀기**
- prior odds = 0.1 / 0.9 = 1/9
- Bayes factor = $p(\text{양성}\mid\text{감염}) / p(\text{양성}\mid\text{비감염})$ = 0.875 / 0.025 = 35
- posterior odds = 35 × 1/9 = 35/9
- 확률로 되돌리면 $p = \dfrac{35/9}{1+35/9} = \dfrac{35}{44} \approx 0.795$ → 지난주 결과와 **똑같음** ✔

### 2.3 Log-odds와 Sigmoid의 관계 (단계별 유도)

log-odds(= **logit**)를 $a$라고 하면:

$$a = \log\frac{p}{1-p}$$

이걸 p에 대해 풀어 보면:

$$
\begin{aligned}
e^a &= \frac{p}{1-p} && \text{(양쪽에 exponential)}\\
e^a(1-p) &= p && \text{(양변에 } 1-p \text{ 곱하기)}\\
e^a &= p + e^a p = p\,(1+e^a) && (e^a p \text{를 오른쪽으로 넘김)}\\
p &= \frac{e^a}{1+e^a} = \frac{1}{1+e^{-a}} = \sigma(a) && \text{(분자·분모를 } e^a\text{로 나눔)}
\end{aligned}
$$

- **sigmoid는 log-odds를 확률로 바꾸는 함수**이고, logit은 그 역함수임
- 그래서 logistic regression에서 $h=\mathbf{w}^\top\mathbf{x}+b$는 사실 **"log-odds를 선형식으로 모델링"** 한 것임

---

## 3. Categorical / Multinomial 분포 (2.5)

Bernoulli/Binomial의 **"동전 → 주사위"** 버전임.

| | 1번 실험 | N번 실험 |
|---|---|---|
| 결과 2개 (동전) | Bernoulli | Binomial |
| 결과 C개 (주사위) | **Categorical** | **Multinomial** |

### 3.1 Categorical 분포 — 주사위 1개

- 결과 $y \in \{1, 2, \ldots, C\}$ 중 **하나**가 튀어나옴
- 파라미터 $\boldsymbol\theta = (\theta_1,\ldots,\theta_C)$, $\theta_c = p(y=c)$, 조건: $0\le\theta_c\le1$, $\sum_c \theta_c = 1$

$$\mathrm{Cat}(y \mid \boldsymbol\theta) = \prod_{c=1}^{C} \theta_c^{\,\mathbb{I}(y=c)}$$

**Indicator function** $\mathbb{I}(y=c)$
- "y가 c일 때만 1, 아니면 0"인 함수
- 그래서 곱셈 안에서 **y와 같은 c 하나만 지수 1**, 나머지는 지수 0 → $\theta^0=1$이라 사라짐
- 예: C=3, y=2 → $\theta_1^0\,\theta_2^1\,\theta_3^0 = \theta_2$ → 결국 "y=2일 확률 θ₂"를 꺼내는 식임
- Bernoulli $\theta^y(1-\theta)^{1-y}$도 똑같은 트릭임

**One-hot encoding** 으로 쓰면: y=2 (C=3) → $\mathbf{y}=(0,1,0)$, $\mathrm{Cat}(\mathbf{y}\mid\boldsymbol\theta)=\prod_c \theta_c^{y_c}$

### 3.2 Multinomial 분포 — 주사위 N개

- 필요한 조건
  - 주사위가 **몇 개(N)** 인지 알아야 함
  - N개 주사위가 **모두 동일**해야 함 = 같은 확률 벡터 θ를 공유
  - 각 던지기는 서로 **독립**
- 출력: 각 면이 나온 횟수 $\mathbf{s}=(s_1,\ldots,s_C)$, $\sum_c s_c = N$

$$\mathcal{M}(\mathbf{s}\mid N,\boldsymbol\theta) = \frac{N!}{s_1!\,s_2!\cdots s_C!}\prod_{c=1}^{C}\theta_c^{s_c}$$

- 예: 공정한 주사위 2개 → "1이 한 번, 6이 한 번" 나올 확률 = $\dfrac{2!}{1!\,1!}\left(\tfrac16\right)^1\left(\tfrac16\right)^1 = \dfrac{2}{36}$ ((1,6), (6,1) 두 경우)
- C=2이면 Binomial, N=1이면 Categorical

### 3.3 Softmax 함수 (2.5.2)

신경망 출력은 실수 C개 $\mathbf{a}=(a_1,\ldots,a_C)$ (logits). 이걸 **합이 1인 확률 벡터**로 바꾸는 함수:

$$\mathrm{softmax}(\mathbf{a})_c = \frac{e^{a_c}}{\sum_{c'=1}^{C} e^{a_{c'}}}$$

- exponential → 모두 양수로 만듦
- 전체 합으로 나눔 → 합이 1
- 예: $\mathbf{a}=(2, 1, 0)$ → $e^2\approx7.39,\ e^1\approx2.72,\ e^0=1$, 합 ≈ 11.11 → 확률 ≈ **(0.665, 0.245, 0.090)**
- 가장 큰 logit이 가장 큰 확률을 받지만 나머지도 0이 아님 → "부드러운(soft) max"
- C=2이면 softmax는 sigmoid와 같아짐

### 3.4 Multiclass logistic regression (2.5.3)

$$p(y \mid \mathbf{x};\boldsymbol\theta) = \mathrm{Cat}\big(y \mid \mathrm{softmax}(\mathbf{W}\mathbf{x}+\mathbf{b})\big)$$

- **행렬 W**로 피처를 C차원 벡터로 변환 (예: 주사위처럼 클래스 6개면 6차원 벡터)
- softmax로 확률 벡터로 변환
- 딥러닝 분류기의 마지막 층(linear + softmax)이 정확히 이 구조임

> **참고 (2.5.4 Log-sum-exp trick)**: logit이 1000처럼 크면 $e^{1000}$이 overflow됨. 모든 $a_c$에서 최댓값 $m$을 빼고 계산해도 softmax 결과는 같음 → 수치적으로 안전하게 계산하는 방법임

---

## 4. Gaussian (Normal) 분포 (2.6)

### 4.1 정의

$$\mathcal{N}(y \mid \mu, \sigma^2) = \frac{1}{\sqrt{2\pi\sigma^2}}\exp\!\left(-\frac{(y-\mu)^2}{2\sigma^2}\right)$$

읽는 법
- $\mu$ (뮤): 평균, 종 모양의 **중심 위치**
- $\sigma^2$ (시그마 제곱): 분산, 종의 **폭**. $\sigma$는 표준편차
- $\exp(-\cdot)$ 안: 평균에서 멀어질수록 $(y-\mu)^2$가 커져서 값이 급격히 작아짐
- 앞의 $\frac{1}{\sqrt{2\pi\sigma^2}}$: 전체 넓이를 1로 맞추는 정규화 상수
- 표준정규분포 $\mathcal N(0,1)$의 꼭대기 높이 ≈ 0.399
- 감 잡기: 평균 ±1σ 안에 약 68%, ±2σ 안에 약 95%, ±3σ 안에 약 99.7%

**CDF (2.6.1)**: $\Phi(y;\mu,\sigma^2)=\int_{-\infty}^{y}\mathcal N(z\mid\mu,\sigma^2)dz$ → 닫힌 형태가 없어서 수치로 계산함 (erf 함수 사용)

**PDF 값은 1보다 클 수 있음 (2.6.2)**
- 예: $\mathcal N(0\mid 0,\ \sigma=0.1)$ → $\dfrac{1}{\sqrt{2\pi}\times0.1}\approx 3.99$
- σ가 작을수록 종이 좁고 높아짐. 높이가 1을 넘어도 **넓이(적분)** 는 항상 1이라 문제없음 (9주차: PDF는 확률이 아니라 밀도)

### 4.2 🔥 [시험] PDF로 평균·분산 계산하기 (2.6.2)

> 교수님이 **"시험"** 이라고 표시한 부분. 정의와 전개를 그대로 쓸 수 있어야 함

**① 평균 (mean, expected value)**

$$E[Y] \triangleq \int_{y} y\,p(y)\,dy$$

- $\triangleq$: "~로 **정의**한다"는 기호
- 읽는 법: "값 y × 그 값의 밀도 p(y)를 전체 y에 대해 적분"
- Gaussian이면 $E[\mathcal N(\cdot\mid\mu,\sigma^2)] = \mu$ (종의 중심)
- 주의: Cauchy처럼 꼬리가 너무 두꺼운 분포는 이 적분이 유한하지 않아서 **평균이 정의되지 않음** (5.2 참고)

**② 분산 (variance)** — "퍼짐(spread)"의 척도, 보통 $\sigma^2$로 씀

$$
\begin{aligned}
V[Y] &\triangleq E\big[(Y-\mu)^2\big] = \int (y-\mu)^2\,p(y)\,dy && \text{(정의)}\\
&= \int (y^2 - 2\mu y + \mu^2)\,p(y)\,dy && \text{(제곱 전개)}\\
&= \underbrace{\int y^2 p(y)\,dy}_{E[Y^2]} + \mu^2\underbrace{\int p(y)\,dy}_{=1} - 2\mu\underbrace{\int y\,p(y)\,dy}_{=\mu} && \text{(적분을 세 개로 쪼갬, } \mu\text{는 상수라 밖으로)}\\
&= E[Y^2] + \mu^2 - 2\mu^2\\
&= E[Y^2] - \mu^2
\end{aligned}
$$

- 핵심: **μ는 이미 계산된 숫자**라서 적분 기호 밖으로 나올 수 있음
- 말로: "분산 = 제곱의 평균 − 평균의 제곱"

**③ 위 식을 옮기면 나오는 유용한 결과**

$$E[Y^2] = \sigma^2 + \mu^2$$

- 예: $Y\sim\mathcal N(3, 4)$ → $E[Y^2] = 4 + 9 = 13$
- **표준편차(standard deviation)**: $\mathrm{std}[Y] = \sqrt{V[Y]} = \sigma$ → y와 같은 단위라 해석이 쉬움

### 4.3 독립 실험 (Independent experiment) — 데이터 여러 개의 likelihood

데이터 $y_1, \ldots, y_N$을 **독립적으로(iid)** 얻었다고 가정하는 게 핵심임.

**독립 실험이 무슨 뜻인가?**
- 같은 조건에서 매번 서로 영향 없이 측정해야 함
- 처음에 0.1이 나왔다고 세팅을 바꾸고, 0.2가 나왔다고 또 세팅을 바꾸면 → **독립 실험이 아님** (앞 결과가 뒤 실험에 영향을 줌)
- iid = **i**ndependent and **i**dentically **d**istributed (독립 + 같은 분포)

독립이면 joint = 각각의 곱 (9주차 내용):

$$p(y_1,\ldots,y_N \mid \mu,\sigma^2) = \prod_{n=1}^{N} \mathcal N(y_n\mid\mu,\sigma^2)$$

수업 예제: 데이터 $\mathcal D = \{0.1,\ 0.2,\ 0.7,\ -0.3\}$ ($N=4$)를 독립 실험으로 얻었다고 **가정**

$$p(\mathcal D\mid\mu,\sigma) = p(0.1\mid\mu,\sigma)\cdot p(0.2\mid\mu,\sigma)\cdot p(0.7\mid\mu,\sigma)\cdot p(-0.3\mid\mu,\sigma) \triangleq L(\mu,\sigma)$$

- 이 곱을 μ, σ의 함수로 본 것이 **likelihood** $L(\mu,\sigma)$
- **독립 가정이 있어야만** 이렇게 곱으로 쪼갤 수 있음

### 4.4 🔥🔥🔥 [기말시험 출제 예고] Gaussian MLE 유도

> 교수님 판서: **"기말시험 꼭 해 봅시다"** — 아래 과정을 **처음부터 끝까지 손으로** 쓸 수 있어야 함
> 결과 "$\hat\mu_{MLE}=\bar y$"만 쓰면 안 되고, 과정을 디테일하게 적을 것

**목표**: 데이터를 가장 잘 설명하는 μ 찾기

$$\hat\mu_{MLE} = \arg\max_{\mu}\ \log L(\mu,\sigma)$$

- $\arg\max_\mu$: "값을 최대로 만드는 **μ 자체**"를 돌려줌 (최댓값이 아니라 그때의 μ)
- log를 쓰는 이유: 곱 → 합으로 바뀌어 계산이 쉬워짐. log는 증가함수라 최대가 되는 위치는 그대로임

**Step 1. 데이터 하나의 Gaussian PDF 쓰기**

$$p(y\mid\mu,\sigma) = \frac{1}{\sqrt{2\pi}\,\sigma}\exp\!\left[-\frac12\left(\frac{y-\mu}{\sigma}\right)^2\right]$$

**Step 2. 데이터 하나에 log 취하기** (예: $y=0.1$)

$$\log p(0.1\mid\mu,\sigma) = -\log\sigma - \log\sqrt{2\pi} - \frac12\left(\frac{0.1-\mu}{\sigma}\right)^2$$

- $\log\frac{1}{\sqrt{2\pi}\sigma} = -\log\sigma - \log\sqrt{2\pi}$
- $\log(\exp[\cdot]) = [\cdot]$ → exp가 벗겨짐

**Step 3. 전체 log-likelihood = 각 log의 합** (곱의 log = log의 합)

$$\log L = -4\log\sigma - 4\log\sqrt{2\pi} - \frac{1}{2\sigma^2}\Big[(0.1-\mu)^2 + (0.2-\mu)^2 + (0.7-\mu)^2 + (-0.3-\mu)^2\Big]$$

**Step 4. μ와 관계없는 항 정리**

- $-4\log\sigma$, $-4\log\sqrt{2\pi}$는 **μ가 들어 있지 않음** → μ를 찾을 때는 상수라 무시해도 됨 (판서에서 지운 부분)
- $-\frac{1}{2\sigma^2}$은 **음수 상수** → log L을 **최대화** = 대괄호 안을 **최소화**

$$\hat\mu_{MLE} = \arg\min_\mu\ \Big[(0.1-\mu)^2 + (0.2-\mu)^2 + (0.7-\mu)^2 + (-0.3-\mu)^2\Big]$$

**Step 5. 전개해서 μ에 대한 2차식으로 만들기**

각 항 $(y_n-\mu)^2 = \mu^2 - 2y_n\mu + y_n^2$ 를 4개 더하면:

$$= 4\mu^2 - 2\mu\,(0.1+0.2+0.7-0.3) + (0.1^2+0.2^2+0.7^2+0.3^2)$$

- $\mu^2$가 4번 → $4\mu^2$
- 1차항 → $-2\mu \times (\text{데이터 합})$, 데이터 합 $= 0.7 = 4\bar y$ (여기서 $\bar y = 0.7/4 = 0.175$)
- 상수항 → $0.01+0.04+0.49+0.09 = 0.63$

**Step 6. 완전제곱식으로 바꾸기**

$$4\mu^2 - 2\mu\cdot 4\bar y + 0.63 = 4\big(\mu^2 - 2\mu\bar y\big) + 0.63 = 4(\mu - \bar y)^2 + \underbrace{(0.63 - 4\bar y^2)}_{\text{μ와 무관한 상수}}$$

- 일반형: $\sum_n (y_n-\mu)^2 = N(\mu-\bar y)^2 + C$
- $N(\mu-\bar y)^2$은 **항상 0 이상**이고, **$\mu = \bar y$일 때 0으로 최소**가 됨

**Step 7. 결론**

$$\boxed{\hat\mu_{MLE} = \bar y = \frac{1}{N}\sum_n y_n = \frac{0.1+0.2+0.7-0.3}{4} = 0.175}$$

→ Gaussian의 평균을 MLE로 추정하면 **표본 평균**이 됨

**다른 방법 — 미분 (검산용)**

$$\frac{\partial}{\partial\mu}\sum_n(y_n-\mu)^2 = -2\sum_n(y_n-\mu) = 0 \Rightarrow N\mu = \sum_n y_n \Rightarrow \hat\mu = \bar y$$

완전제곱이든 미분이든 결과는 같음. 시험에서는 **어느 방법이든 과정을 다 쓰는 것**이 중요함

**보너스 — σ²의 MLE (교재 2.6 / 4장 내용, 같이 알아 두기)**

σ에 대해서도 같은 방식으로 풀면 ($v=\sigma^2$로 두고 미분):

$$\log L = -\frac N2\log v - \frac{1}{2v}\sum_n (y_n-\mu)^2 + C, \qquad \frac{\partial}{\partial v} = -\frac{N}{2v} + \frac{1}{2v^2}\sum_n(y_n-\mu)^2 = 0$$

$$\Rightarrow \hat\sigma^2_{MLE} = \frac1N\sum_n (y_n-\hat\mu)^2 = \frac1N\sum_n y_n^2 - \bar y^2$$

- 수업 데이터로: $\hat\sigma^2 = 0.63/4 - 0.175^2 = 0.1575 - 0.030625 \approx 0.127$, $\hat\sigma \approx 0.356$
- 즉 **표본 분산** = "제곱의 평균 − 평균의 제곱" (4.2의 $V=E[Y^2]-\mu^2$의 데이터 버전)

### 4.5 Gaussian으로 Regression 하기 (2.6.3)

머신러닝/인공지능 확률통계 관점에서 regression을 보면:

$$p(y \mid x;\theta) = \mathcal N\big(y \mid \underbrace{wx+b}_{\text{평균}},\ \sigma^2\big)$$

- **평균이 $wx+b$** (x에 따라 직선을 따라 움직임), **퍼짐(variation)은 σ가 결정**
- Variation은 **수직(y) 방향**으로 생긴다고 봄 → 각 x 위치에서 직선을 중심으로 y가 위아래로 Gaussian 모양으로 흩어짐
- 그림으로: 직선 위 각 점에 세로로 서 있는 종 모양을 상상하면 됨

| | σ의 모양 | 그림 |
|---|---|---|
| **Homoscedastic regression** | σ가 **x와 무관하게 일정** | 직선 주변 띠의 폭이 어디서나 같음 |
| **Heteroscedastic regression** | σ가 **x에 따라 바뀜** $\sigma(x)$ | 띠의 폭이 x에 따라 넓어졌다 좁아졌다 함 |

Heteroscedastic에서 σ를 함수로 모델링하는 방법:

$$p(y\mid x;\theta) = \mathcal N\big(y \mid w_\mu^\top x + b_\mu,\ \sigma_+(w_\sigma^\top x + b_\sigma)^2\big)$$

**Softplus 함수**

$$\sigma_+(a) = \log(1 + e^a)$$

- 실수 전체 $\mathbb R$를 **양수 $\mathbb R^+$** 로 매핑함
- 표준편차는 음수일 수 없으니, 선형식 결과를 softplus에 통과시켜 **예측한 standard deviation이 항상 non-negative**가 되게 함
- 값 감 잡기: $\sigma_+(0) = \log 2 \approx 0.693$, a가 크면 ≈ a, a가 아주 작으면 ≈ 0 (ReLU를 부드럽게 만든 모양)

### 4.6 Gaussian을 많이 쓰는 이유 (2.6.4, 교재 보충)

- 파라미터가 μ, σ² 두 개뿐이라 해석이 쉬움
- **Central limit theorem**: 독립 변수 여러 개를 더하면 분포가 Gaussian에 가까워짐 → 노이즈 모델로 자연스러움
- 평균·분산만 정해졌을 때 가정을 가장 적게 하는(maximum entropy) 분포임

### 4.7 Dirac delta function (2.6.5)

Gaussian에서 **σ → 0**으로 보내면 폭은 0, 높이는 무한대인 뾰족한 "바늘"이 됨:

$$\delta(x) = \begin{cases} +\infty & x=0 \\ 0 & x\neq 0\end{cases}, \qquad \int_{-\infty}^{\infty}\delta(x)\,dx = 1$$

- 0을 넣으면 무한히 큰 값이 나오지만 **넓이는 1**
- **Sifting property**: $\int f(y)\,\delta(x-y)\,dy = f(x)$ → 적분 안에서 특정 점의 값만 "골라냄"
- "확률이 한 점에 100% 몰려 있는 분포"를 연속형으로 표현할 때 씀 → 5.4 empirical distribution에서 사용

---

## 5. 그 밖의 분포들 (2.7)

### 5.1 Student t 분포 — 꼬리가 두꺼움

$$\mathcal T(y\mid\mu,\sigma^2,\nu) \propto \left[1 + \frac{1}{\nu}\left(\frac{y-\mu}{\sigma}\right)^2\right]^{-\frac{\nu+1}{2}}$$

- $\nu$ (뉴): **degrees of freedom(자유도)**. 작을수록 꼬리가 두꺼움, $\nu\to\infty$이면 Gaussian이 됨
- Gaussian은 꼬리가 $e^{-y^2}$로 **아주 빨리** 0이 됨 → 평균에서 먼 값이 "거의 불가능"하다고 봄
- Student t는 꼬리가 **다항식 속도로 천천히** 줄어듦 → 먼 값도 "가끔 있을 수 있다"고 봄

**왜 중요한가: Robustness (강건성)**
- 데이터에 이상치(outlier)가 하나 섞이면, Gaussian으로 파라미터 추정 시 평균이 이상치 쪽으로 크게 끌려감 (Gaussian 입장에선 그 점이 "너무 말이 안 돼서" 맞춰 주려고 함)
- Student t는 "꼬리에 있을 수 있는 값"으로 받아들여서 **추정이 덜 흔들림** → 파라미터 추정이 robust함
- 샘플을 뽑아 비교해 보면 t분포에서는 가끔 아주 멀리 튀는 값이 나오는 걸 볼 수 있음

### 5.2 Cauchy (Lorentz) 분포

- Student t에서 **$\nu=1$** 로 세팅한 것 = **Cauchy distribution** (= **Lorentz distribution**)

$$\mathcal C(x\mid\mu,\gamma) = \frac{1}{\gamma\pi}\left[1 + \left(\frac{x-\mu}{\gamma}\right)^2\right]^{-1}$$

- 꼬리가 너무 두꺼워서 **평균과 분산이 정의되지 않음** (적분이 발산)

### 5.3 Laplace 분포 (교재 보충)

$$\mathrm{Laplace}(y\mid\mu,b) = \frac{1}{2b}\exp\!\left(-\frac{|y-\mu|}{b}\right)$$

- 제곱 대신 **절댓값** → Gaussian보다 꼬리가 두껍고 중심이 뾰족함. 역시 이상치에 robust함

> Beta(2.7.4), Gamma(2.7.5) 분포도 이 절에 있음. Beta는 5주차 Beta prior에서 다룸

### 5.4 Empirical distribution (2.7.6)

데이터 $x_1, \ldots, x_N$만 있고 분포 모양을 모를 때, **데이터 자체로 분포를 만드는** 방법:

$$p_N(x) = \frac{1}{N}\sum_{n=1}^{N}\delta(x - x_n)$$

- 각 데이터 점마다 **delta 함수(바늘)를 꽂고**, 각 바늘에 **1/N**의 확률을 줌 → 합이 1이라 확률분포로 쓸 수 있음
- 즉 empirical distribution을 **delta 함수들의 합으로 approximation**하는 것임
- CDF는 데이터 점마다 1/N씩 올라가는 **계단 함수**가 됨
- 예: 데이터 {1, 2, 2, 5} → $p(1)=1/4,\ p(2)=2/4,\ p(5)=1/4$

**부드럽게 만들기**: 바늘(delta) 대신 각 점에 **작은 Gaussian**을 씌우고 1/N을 곱해서 더하면 매끈한 분포가 됨

$$p(x) \approx \frac{1}{N}\sum_{n=1}^N \mathcal N(x\mid x_n, \sigma^2)$$

(이걸 kernel density estimation이라고 부름. σ→0이면 다시 empirical distribution이 됨)

---

## 6. ⭐ 확률변수의 변환 (Transformations of random variables, 2.8)

> 교수님이 **별표** 친 절. 공부하다 보면 "이게 왜 이렇게 되지?" 하고 계속 튀어나오는 중요한 내용임

**질문**: $x \sim p(\cdot)$인 확률변수가 있고, $y = f(x)$가 x에 대한 **deterministic(결정론적) 변환**일 때, $p(y)$는 어떻게 되는가?

- deterministic = 같은 x를 넣으면 항상 같은 y가 나옴 (랜덤성은 x에만 있음)

### 6.1 ⭐ Discrete case (2.8.1)

$$p_y(y) = \sum_{x:\ f(x)=y} p_x(x)$$

- 읽는 법: "**f(x)=y가 되는 모든 x**의 확률 질량(probability mass)을 다 더한다"

**교재 예제**
- $X$는 $\{1, 2, \ldots, 10\}$에서 균등분포 → 각각 $p_x(x) = 1/10$
- $f(X) = 1$ (X가 짝수), $f(X) = 0$ (X가 홀수)
- $p_y(1) = \sum_{x\in\{2,4,6,8,10\}} p_x(x) = 5 \times 0.1 = 0.5$
- 따라서 $p_y(0) = 0.5$
- 여기서 f는 **many-to-one function** (x 여러 개가 같은 y 하나로 감) → 그래서 **더하기**가 필요함

**One-to-one이면?** y로 가는 x가 하나뿐이라 확률이 그대로 옮겨감
- 예: $Y=2X+1$, $p(X=3)=0.2$ → $p(Y=7)=0.2$

### 6.2 ⭐ Continuous case — Change of variables (2.8.2 ~ 2.8.3.1)

> 수업에서 그림까지 그려 가며 시간을 가장 많이 쓴 부분

#### (1) 왜 PDF를 그대로 옮기면 안 되나?

- 이산형: $p(X=3)=0.2$ → $p(Y=7)=0.2$ (확률 자체가 옮겨감)
- 연속형: PDF는 **확률이 아니라 밀도**임. 확률은 **밀도 × 구간 폭**
- 변환 f가 x축을 늘이거나 줄이면 **구간 폭이 바뀌므로**, 같은 확률을 유지하려면 **밀도(높이)가 바뀌어야** 함

#### (2) 핵심 아이디어: 확률 질량 보존 (교재 예제)

$x \sim \mathrm{Unif}(0,1)$, $y = f(x) = 2x + 1$ → 분포를 **늘이고(stretch) 옮김(shift)**

- x 근처 아주 작은 구간 $(x,\ x+dx)$는 y의 구간 $(y,\ y+dy)$로 매핑됨
- **두 구간에 들어 있는 확률 질량은 같아야 함** (같은 사건이니까):

$$\boxed{p(x)\,dx = p(y)\,dy}$$

- 판서 그림 버전: $p_y(y)\,\Delta y = p_x(x)\,\Delta x$
  - 아래(x축)의 얇은 막대 넓이 = 왼쪽(y축)의 얇은 막대 넓이
  - $f$가 가파르면(기울기 큼) $\Delta y$가 넓어짐 → 넓이를 맞추려면 $p(y)$ 높이는 **낮아져야** 함
- 정리하면 $p(y) = p(x)\dfrac{dx}{dy}$

$dx/dy$가 양수든 음수든 확률 보존 관점에서는 상관없으므로 (확률·밀도는 음수가 될 수 없음) 절댓값을 씀:

$$\boxed{p_y(y) = p_x(x)\left|\frac{dx}{dy}\right|} \qquad (2.152)$$

**예제에 적용**: $y=2x+1 \Rightarrow x = \frac{y-1}{2} \Rightarrow \frac{dx}{dy} = \frac12$
- $p_y(y) = 1 \times \frac12 = \frac12$, y의 범위는 $(1, 3)$
- 검산: 폭 2 × 높이 1/2 = 넓이 1 ✔
- 직관: x축 폭 1이 y축 폭 2로 **2배 늘어났으니**, 높이는 **1/2로 낮아짐**

#### (3) 일반적인 단조함수에 대한 유도 (CDF 이용)

$f:\mathbb R\to\mathbb R$가 **monotonic(단조)** 이고 역함수 $g = f^{-1}$가 있다고 하자. 즉 $y=f(x)$, $x=g(y)$

**단조 증가(monotonically increasing)인 경우**

Step 1. CDF로 바꿔서 생각 (2.153)

$$P_y(y) = \Pr(f(X)\le y) = \Pr\big(X \le f^{-1}(y)\big) = P_x\big(f^{-1}(y)\big) = P_x\big(g(y)\big)$$

- 두 번째 등호: f가 **증가함수**라서 $f(X)\le y \iff X\le f^{-1}(y)$ (양변에 $f^{-1}$을 적용해도 부등호 방향 유지)

Step 2. 미분해서 PDF 얻기 (2.154) — chain rule 사용

$$p_y(y) \triangleq \frac{d}{dy}P_y(y) = \frac{d}{dy}P_x\big(g(y)\big) = \frac{dx}{dy}\cdot\frac{d}{dx}P_x\big(g(y)\big) = \frac{dx}{dy}\,p_x\big(g(y)\big)$$

- $\frac{d}{dx}P_x = p_x$ (CDF를 미분하면 PDF, 9주차)
- $\frac{dx}{dy}$는 겉함수 미분 × 속함수 미분에서 "속함수 $g(y)$의 미분"임

**단조 감소(monotonically decreasing)인 경우**
- $f(X)\le y \iff X \ge g(y)$로 **부등호가 뒤집힘** → $P_y(y) = 1 - P_x(g(y))$ → 미분하면 부호가 반대: $-\frac{dx}{dy}p_x(g(y))$
- 이때 $\frac{dx}{dy}<0$이라 결과는 양수가 됨

**두 경우를 합치면 절댓값**:

$$p_y(y) = p_x\big(g(y)\big)\left|\frac{dx}{dy}\right|$$

→ (2)에서 직관으로 얻은 식과 **같은 결과**

#### (4) Gaussian 선형 변환에 적용

$X\sim\mathcal N(\mu,\sigma^2)$, $Y=aX+b$ → $x = \frac{y-b}{a}$, $\left|\frac{dx}{dy}\right| = \frac{1}{|a|}$

$$p_y(y) = \frac{1}{|a|}\,p_x\!\left(\frac{y-b}{a}\right) \;\Rightarrow\; Y \sim \mathcal N(a\mu+b,\ a^2\sigma^2)$$

- 평균은 $a\mu+b$, 분산은 $a^2\sigma^2$ → 9주차의 $E[aX+b]=aE[X]+b$, $V[aX+b]=a^2V[X]$와 정확히 일치함

#### 한눈에 비교

| | Discrete | Continuous |
|---|---|---|
| 옮기는 것 | 확률 질량 그대로 | 밀도 × $\lvert dx/dy\rvert$ |
| 공식 | $p_y(y)=\sum_{x:f(x)=y}p_x(x)$ | $p_y(y)=p_x(g(y))\lvert dx/dy\rvert$ |
| 핵심 직관 | y로 가는 x들을 다 모음 | $p(x)dx=p(y)dy$ (넓이 보존) |
| 조건 | 아무 f나 가능 | f가 단조(역함수 존재) |

---

## 7. 공식 모음

| 구분 | 공식 |
|---|---|
| Odds | $p/(1-p)$, 역변환 $p=\text{odds}/(1+\text{odds})$ |
| Odds 형태 베이즈 | posterior odds = Bayes factor × prior odds |
| Logit ↔ Sigmoid | $a=\log\frac{p}{1-p} \iff p=\sigma(a)=\frac{1}{1+e^{-a}}$ |
| Categorical | $\prod_c \theta_c^{\mathbb I(y=c)}$ |
| Multinomial | $\frac{N!}{\prod_c s_c!}\prod_c\theta_c^{s_c}$ |
| Softmax | $e^{a_c}/\sum_{c'}e^{a_{c'}}$ |
| Gaussian | $\frac{1}{\sqrt{2\pi\sigma^2}}\exp\!\left(-\frac{(y-\mu)^2}{2\sigma^2}\right)$ |
| Log-likelihood (iid) | $-\frac N2\log(2\pi\sigma^2)-\frac{1}{2\sigma^2}\sum_n(y_n-\mu)^2$ |
| PDF 평균·분산 🔥 | $E[Y]=\int y\,p(y)dy$, $V[Y]=E[Y^2]-\mu^2$, $E[Y^2]=\sigma^2+\mu^2$ |
| MLE 🔥🔥🔥 | $\hat\mu=\bar y$, $\hat\sigma^2=\frac1N\sum(y_n-\bar y)^2$ |
| Regression | $\mathcal N(y\mid wx+b,\sigma^2)$ |
| Softplus | $\log(1+e^a)$ |
| Empirical | $\frac1N\sum_n\delta(x-x_n)$ |
| 이산 변환 | $p_y(y)=\sum_{x:f(x)=y}p_x(x)$ |
| Change of variables | $p(x)dx=p(y)dy \Rightarrow p_y(y)=p_x(g(y))\left\lvert\frac{dx}{dy}\right\rvert$ |
| 선형 변환 (연속) | $p_y(y)=\frac{1}{\lvert a\rvert}p_x\!\left(\frac{y-b}{a}\right)$ |

---

## 8. 용어 정리

| English | 한국어 | 한 줄 설명 |
|---|---|---|
| Odds | 오즈 | $p/(1-p)$ |
| Log-odds / Logit | 로그 오즈 | sigmoid의 역함수 |
| Bayes factor | 베이즈 인자 | likelihood의 비율 |
| Complement | 여사건 | H가 아닌 경우 $\bar H$ |
| Categorical distribution | 범주형 분포 | 주사위 1개 |
| Multinomial distribution | 다항 분포 | 주사위 N개의 면별 횟수 |
| Indicator function | 지시 함수 | 조건 맞으면 1, 아니면 0 |
| One-hot encoding | 원-핫 인코딩 | 해당 클래스만 1인 벡터 |
| Softmax | 소프트맥스 | 실수 벡터 → 확률 벡터 |
| iid | 독립 동일 분포 | 독립 + 같은 분포 |
| Homoscedastic | 등분산 | σ가 x와 무관 |
| Heteroscedastic | 이분산 | σ가 x에 따라 변함 |
| Softplus | 소프트플러스 | $\mathbb R\to\mathbb R^+$ |
| Dirac delta function | 디랙 델타 함수 | 한 점에 넓이 1이 몰린 바늘 |
| Student t distribution | t 분포 | 꼬리가 두꺼운 분포 |
| Degrees of freedom (ν) | 자유도 | t 분포 꼬리 두께 조절 |
| Cauchy / Lorentz distribution | 코시 / 로렌츠 분포 | t 분포의 ν=1 |
| Robust | 강건한 | 이상치에 덜 흔들림 |
| Empirical distribution | 경험적 분포 | 데이터 점마다 1/N 확률 |
| Transformation of RV | 확률변수 변환 | Y=f(X)의 분포 구하기 |

---

## 9. 셀프 체크리스트

- [ ] p=0.25의 odds, odds 7/3의 확률을 계산할 수 있는가?
- [ ] 베이즈 룰을 odds 형태로 바꿀 때 $p(D)$가 사라지는 이유를 설명할 수 있는가?
- [ ] $a=\log\frac{p}{1-p}$에서 $p=\sigma(a)$를 유도할 수 있는가?
- [ ] Categorical의 indicator function 트릭을 C=3, y=2 예로 설명할 수 있는가?
- [ ] Multinomial을 쓰기 위한 조건(N, 동일한 주사위, 독립)을 말할 수 있는가?
- [ ] softmax((2,1,0))을 대략 계산할 수 있는가?
- [ ] 독립 실험이 아닌 예를 들 수 있는가?
- [ ] 🔥🔥🔥 데이터 $\{0.1,0.2,0.7,-0.3\}$으로 likelihood → log → 완전제곱 → $\hat\mu_{MLE}=\bar y=0.175$를 **처음부터 끝까지** 손으로 쓸 수 있는가?
- [ ] 🔥🔥 $V[Y]=\int(y-\mu)^2p(y)dy$를 세 개의 적분으로 쪼개 $E[Y^2]-\mu^2$를 유도할 수 있는가?
- [ ] Homoscedastic과 heteroscedastic의 차이, softplus를 쓰는 이유를 설명할 수 있는가?
- [ ] Student t / Cauchy가 robust한 이유를 설명할 수 있는가?
- [ ] Empirical distribution을 delta 함수로 쓸 수 있는가?
- [ ] ⭐ 이산 변환 예제({1..10} 균등, 짝수→1)를 풀고 many-to-one의 의미를 설명할 수 있는가?
- [ ] ⭐ $p(x)dx=p(y)dy$에서 $p_y(y)=p_x(x)|dx/dy|$를 얻고, Unif(0,1)→2x+1 예제의 높이 1/2을 설명할 수 있는가?
- [ ] ⭐ CDF를 이용한 단조 증가 함수 유도(2.153→2.154)와 절댓값이 붙는 이유를 설명할 수 있는가?

## 10. 다음 할 일

- 독립 실험(iid) 가정이 무엇이고 언제 깨지는지 정리
- Empirical distribution 모델링 방법 복습
- 신경망 출력 h → sigmoid/softmax → 확률 계산 흐름 복습
- 🔥 기말 대비: 4.4 MLE 유도를 빈 종이에 직접 써 보기 (데이터 숫자를 바꿔서도 연습)
- 예습: PML1 2.8.3.2 이후 (multivariate change of variables, Jacobian), 2.8.4 ~ 2.8.7 (linear transformation moments, convolution, central limit theorem, Monte Carlo approximation)