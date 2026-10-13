# 인공지능 확률통계 6주차 — Likelihood·MLE·MAP와 Estimating Counts

> 수업 자료: Think Bayes 2, Ch.5 *Estimating Counts* (+ Ch.6 Odds 맛보기)
> 핵심 흐름: **비전 시스템 동전 문제 (MLE → MAP → Posterior)** → **Prior = 제약조건** → **분산·공분산과 2차 미분** → **기차 문제 / Credible Interval** → **강당 인원 연습문제** → **Odds**

---

## 0. 기호 읽는 법 (먼저 보고 가기)

| 기호 | 읽는 법 | 뜻 |
|---|---|---|
| θ | 세타 | 추정하고 싶은 파라미터 (예: 동전 앞면 확률) |
| L(θ) | 라이클리후드 | θ라고 가정했을 때 **지금 관측한 데이터가 나올 확률** |
| prior(θ) | 프라이어 | 데이터 보기 전에 θ에 대해 믿고 있던 분포 |
| posterior(θ) | 포스티리어 | 데이터를 본 뒤 업데이트된 θ의 분포 |
| Z | 정규화 상수 (evidence) | posterior의 전체 합(넓이)을 1로 맞춰주는 값 |
| arg max_θ f(θ) | 아그맥스 | f(θ)를 **가장 크게 만드는 θ 값** (최댓값 자체가 아니라 그 위치) |
| arg min_θ f(θ) | 아그민 | f(θ)를 가장 작게 만드는 θ 값 |
| (n k) | n choose k | n개 중 k개를 고르는 경우의 수 = n! / (k!(n−k)!) |
| θ̂ | 세타 햇 | θ의 **추정값** |

---

## 1. 비전 시스템 동전 문제 (6주차 메인 예제)

### 1.1 문제 상황

- 동전을 직접 보고 기록하기 귀찮아서 **동전을 던지면 자동으로 앞/뒷면을 판별하는 컴퓨터 비전 시스템**을 만들었음
- 그런데 이 비전 시스템은 완벽하지 않음
  - 인식 성공(제대로 읽음) 확률 = **0.8**
  - 인식 실패(반대로 읽음) 확률 = **y = 0.2**
- 250번 던졌더니 시스템이 **"앞면(H)" 140번** 이라고 보고함
- 질문: **동전 자체의 실제 앞면 확률 θ** 의 분포(posterior)는?

> 주의: 140은 "실제 앞면 횟수"가 아니라 **"시스템이 앞면이라고 보고한 횟수"** 임. 그래서 θ와 관측값 사이에 비전 시스템 오류가 끼어 있음.

### 1.2 "시스템이 앞면이라고 보고할 확률" 구하기

시스템이 H라고 보고하는 경우는 두 가지임 (Sum rule로 쪼갬).

| 실제 동전 | 시스템 판정 | 확률 |
|---|---|---|
| 실제 앞면 (θ) | 제대로 읽음 (0.8) → **H 보고** | θ × 0.8 |
| 실제 뒷면 (1−θ) | 잘못 읽음 (0.2) → **H 보고** | (1−θ) × 0.2 |
| 실제 앞면 (θ) | 잘못 읽음 (0.2) → T 보고 | θ × 0.2 |
| 실제 뒷면 (1−θ) | 제대로 읽음 (0.8) → T 보고 | (1−θ) × 0.8 |

$$
P(\text{H 보고}) = P(\text{보고 H}\mid\text{실제 H})P(\text{실제 H}) + P(\text{보고 H}\mid\text{실제 T})P(\text{실제 T})
$$
$$
= 0.8\theta + 0.2(1-\theta) = 0.8\theta + 0.2 - 0.2\theta = \boxed{0.2 + 0.6\theta}
$$

$$
P(\text{T 보고}) = 1 - (0.2 + 0.6\theta) = \boxed{0.8 - 0.6\theta}
$$

**숫자로 감 잡기**
- θ = 0.5 (공정한 동전) → H 보고 확률 = 0.2 + 0.3 = 0.5 ✔ (오류가 대칭이라 그대로 0.5)
- θ = 1 (무조건 앞면) → 0.2 + 0.6 = 0.8 (앞면만 나와도 20%는 뒷면으로 잘못 읽음)
- θ = 0 (무조건 뒷면) → 0.2 (뒷면만 나와도 20%는 앞면으로 잘못 읽음)

→ 즉 보고 확률은 **0.2 ~ 0.8 사이로 눌려 있음**. 비전 오류가 실제 확률을 0.5 쪽으로 끌어당기는 효과임.

### 1.3 Likelihood

"H 보고 수"는 250번 시행 중 성공 횟수이므로 **Binomial**임.

$$
Y = 140 \sim \text{Binomial}(N=250,\ p = 0.2 + 0.6\theta)
$$

$$
L(\theta) = \binom{250}{140}(0.2+0.6\theta)^{140}(0.8-0.6\theta)^{110}
$$

- 140 = H 보고 횟수, 110 = 250 − 140 = T 보고 횟수

---

## 2. MLE (Maximum Likelihood Estimation)

### 2.1 정의

$$
\hat\theta_{MLE} = \arg\max_\theta L(\theta)
$$

"데이터가 가장 잘 나올 법한 θ" 를 고르는 것임. Prior는 쓰지 않음.

### 2.2 왜 log를 씌우나

- **log는 단조증가 함수** 임 → a < b 이면 log a < log b
- 그래서 L(θ)를 최대로 만드는 θ와 log L(θ)를 최대로 만드는 θ는 **같은 위치**임 (최댓값 크기는 달라도 arg max는 동일)
- log를 쓰면
  - 거듭제곱 → 곱셈: log(a¹⁴⁰) = 140 log a
  - 곱셈 → 덧셈: log(ab) = log a + log b
  - 아주 작은 확률을 수백 번 곱해서 0으로 뭉개지는 문제(underflow)도 피함

$$
\log L(\theta) = \log\binom{250}{140} + 140\log(0.2+0.6\theta) + 110\log(0.8-0.6\theta)
$$

- $\log\binom{250}{140}$ 은 θ가 없는 **상수** → arg max에 영향 없음 → 버려도 됨

$$
\hat\theta_{MLE} = \arg\max_\theta \big[140\log(0.2+0.6\theta) + 110\log(0.8-0.6\theta)\big]
$$

### 2.3 NLL (Negative Log Likelihood)

$$
\text{NLL}(\theta) = -\log L(\theta)
$$

- 앞에 마이너스를 붙이면 **최대화 문제 → 최소화 문제** 로 바뀜
- arg max log L = **arg min NLL**
- 머신러닝에서 "loss를 최소화한다"는 표현을 쓰기 때문에 NLL 형태를 주로 씀 (Cross-Entropy loss가 사실상 NLL임)

### 2.4 직접 풀기 — 미분해서 0으로 두기

최솟값(또는 최댓값) 지점에서는 기울기가 0임. log(f)를 미분하면 f'/f 임을 이용함.

$$
\frac{d}{d\theta}\log L = 140\cdot\frac{0.6}{0.2+0.6\theta} + 110\cdot\frac{-0.6}{0.8-0.6\theta} = 0
$$

양변을 0.6으로 나누고 정리:

$$
\frac{140}{0.2+0.6\theta} = \frac{110}{0.8-0.6\theta}
$$
$$
140(0.8-0.6\theta) = 110(0.2+0.6\theta)
$$
$$
112 - 84\theta = 22 + 66\theta
$$
$$
90 = 150\theta \quad\Rightarrow\quad \boxed{\hat\theta_{MLE} = 0.6}
$$

**검산(직관)**: θ = 0.6이면 H 보고 확률 = 0.2 + 0.36 = 0.56. 실제 관측된 H 보고 비율 = 140/250 = **0.56** ✔ → 관측 비율과 정확히 일치하는 θ가 MLE임.

### 2.5 수치 최적화와 Gradient

- 이번 문제는 손으로 풀렸지만, 대부분의 모델은 미분=0 식을 손으로 못 풂
- 그래서 **gradient(기울기)를 계산해서 내려가는 방식**(Gradient Descent)으로 NLL의 최저점을 찾음
- NLL 곡선을 그려보면 θ ∈ (0, 1) 범위에서 한 지점(0.6)에서 가장 낮은 그릇 모양임
- 학습률이 크거나 gradient를 제대로 안 쓰면 최적점 근처에서 **왔다 갔다 하며 수렴하지 않는(diverge/oscillate)** 현상이 생김 → gradient를 정확히 계산하고 step 크기를 조절해야 수렴함

```python
import numpy as np
from scipy.optimize import minimize_scalar

nll = lambda t: -(140*np.log(0.2+0.6*t) + 110*np.log(0.8-0.6*t))
res = minimize_scalar(nll, bounds=(1e-6, 1-1e-6), method='bounded')
res.x   # 0.6
```

---

## 3. MAP (Maximum A Posteriori)

### 3.1 Prior 정하기 — Beta(2, 2)

θ는 확률이니까 0 < θ < 1 임. 이 범위에서 쓰기 좋은 분포가 **Beta 분포** 임.

$$
\text{prior}(\theta) = \text{Beta}(\theta\mid a=2, b=2) = \frac{\theta^{a-1}(1-\theta)^{b-1}}{B(a,b)} = \frac{\theta(1-\theta)}{B(2,2)}
$$

- a, b는 **shape parameter** (분포 모양을 결정하는 값)
- Beta(2,2)는 0.5에서 가장 높고 0, 1 끝으로 갈수록 0이 되는 **완만한 언덕 모양**
  - 의미: "동전은 대체로 공정한 편이고, 극단적인 값(0이나 1)은 잘 안 나온다"는 약한 믿음
- B(2,2)는 넓이를 1로 맞추는 상수 = 1/6

### 3.2 Posterior

$$
\text{posterior}(\theta) = \frac{L(\theta)\cdot\text{prior}(\theta)}{Z}, \qquad Z = \int_0^1 L(\theta)\,\text{prior}(\theta)\,d\theta
$$

분자를 풀어쓰면:

$$
L(\theta)\cdot\text{prior}(\theta) = \binom{250}{140}(0.2+0.6\theta)^{140}(0.8-0.6\theta)^{110}\cdot\frac{\theta(1-\theta)}{B(2,2)}
$$

- Z는 θ에 대해 적분한 값이라 **θ가 없는 상수**임
- 실제 계산에서는 L × prior를 먼저 구하고, 전체 합(넓이)으로 나눠서 **스케일을 맞춰주면(scaling up/down) 그게 바로 posterior** 가 됨 (Pmf의 `normalize()`가 하는 일)

### 3.3 MAP 정의와 log posterior

$$
\hat\theta_{MAP} = \arg\max_\theta \text{posterior}(\theta) = \arg\max_\theta \log\text{posterior}(\theta) = \arg\min_\theta \big[-\log\text{posterior}(\theta)\big]
$$

log posterior를 풀어쓰면:

$$
\log\text{posterior}(\theta) = \log\binom{250}{140} + 140\log(0.2+0.6\theta) + 110\log(0.8-0.6\theta) + \log\theta + \log(1-\theta) - \log B(2,2) - \log Z
$$

- 상수항: $\log\binom{250}{140}$, $\log B(2,2)$, $\log Z$ → arg max에 영향 없음 → 버림
- 남는 것:

$$
\hat\theta_{MAP} = \arg\max_\theta\Big[\underbrace{140\log(0.2+0.6\theta) + 110\log(0.8-0.6\theta)}_{\text{log likelihood}} + \underbrace{\log\theta + \log(1-\theta)}_{\text{log prior}}\Big]
$$

> **핵심**: MAP = MLE 식 + log prior 항. 즉 **MAP을 구할 때는 Z를 계산할 필요가 없음**. Z가 필요한 건 posterior 분포 전체(평균, 구간 등)를 구할 때임.

### 3.4 결과 비교

| 추정 방법 | 값 | 설명 |
|---|---|---|
| MLE | **0.600** | 데이터만 봄 |
| MAP (Beta(2,2) prior) | **≈ 0.598** | prior가 0.5 쪽으로 살짝 당김 |
| Posterior mean | ≈ 0.597 | posterior 분포의 평균 |
| 90% credible interval | ≈ (0.51, 0.68) | |

- 데이터가 250개로 많아서 prior의 영향이 아주 작음 → MAP ≈ MLE
- 그림으로 보면: prior는 0.5 중심의 넓은 언덕, L(θ)는 0.6 근처에 뾰족한 산 → 곱하면 0.6에 거의 붙은 posterior가 나옴
- 데이터가 적을수록 prior가 결과를 더 크게 끌어당김

---

## 4. Bayesian Formulation의 의미 — Prior = 제약조건(Constraint)

- Bayesian 방법의 원래 목표는 **posterior density 전체를 구하는 것** 임
- 하지만 Z(적분) 계산이 어렵고, 굳이 분포 전체가 필요 없는 경우도 많음
  - 이때는 그냥 **파라미터 추정(parameter estimation)** 문제가 되고, MAP 하나만 구하면 됨
- MAP 식을 보면 `log likelihood + log prior` 를 최대화하는 것임
  - log likelihood: 데이터에 맞추려는 힘
  - log prior: **파라미터가 이상한 값으로 가지 못하게 막는 제약조건(constraint) / 벌점(penalty)**
- 예: Beta(2,2) prior의 log θ + log(1−θ) 항은 θ가 0이나 1에 가까워지면 −∞로 떨어짐 → θ가 극단으로 가지 못하게 막음
- 그래서 **"제약조건이 들어간 최적화는 사실상 다 Bayesian과 연결된다"** 고 볼 수 있음
  - 머신러닝의 **정규화(regularization)** 가 대표적 예
  - L2 정규화(weight decay) = 가중치에 Gaussian prior를 준 MAP
  - L1 정규화 = Laplace prior를 준 MAP

$$
\underbrace{\arg\min_\theta\ \big[\text{NLL}(\theta) + \lambda\|\theta\|^2\big]}_{\text{정규화된 loss 최소화}} \;\Longleftrightarrow\; \underbrace{\arg\max_\theta\ \big[\log L(\theta) + \log\text{prior}_{\text{Gaussian}}(\theta)\big]}_{\text{MAP}}
$$

- Bayesian estimation에서는 **prior를 어디서, 왜 이렇게 정했는지 설명하는 것이 중요함** (근거 없는 prior는 결과를 왜곡함)

---

## 5. 분산(Variance)·공분산(Covariance)과 2차 미분

### 5.1 분산

정규분포를 "평균 μ, 표준편차 σ"로 말할 때, σ² 이 분산임.

$$
\text{Var}[X] = E\big[(X-\mu)^2\big] = \sum_x (x-\mu)^2\,p(x) \quad(\text{연속이면 }\int)
$$

- "평균에서 얼마나 떨어져 있나(x−μ)를 제곱하고, 그 확률로 가중평균한 것"
- 작은 예: X가 1, 3을 각각 확률 0.5로 가짐 → μ = 2 → Var = 0.5·(1−2)² + 0.5·(3−2)² = **1**

### 5.2 공분산

두 확률변수 X, Y가 **함께 어떻게 움직이는지** 를 나타냄.

$$
\text{Cov}[X,Y] = E\big[(X-\mu_X)(Y-\mu_Y)\big]
$$

- Cov > 0: X가 평균보다 크면 Y도 평균보다 큰 경향
- Cov < 0: 반대 방향으로 움직이는 경향
- Cov[X,X] = Var[X]
- **X, Y가 독립이면 Cov = 0** 임
  - 단, 역은 성립하지 않음: Cov = 0이라도 독립이 아닐 수 있음 (예: Y = X², X가 −1, 0, 1 균등 → Cov = 0이지만 Y는 X에 완전히 종속됨)

### 5.3 다차원 분포

- 2차원 정규분포는 확률밀도를 **등고선(contour)** 으로 그려볼 수 있음 → 샘플을 뽑으면 타원 모양으로 퍼짐
- 공분산이 0이 아니면 타원이 기울어짐
- 3차원 이상부터는 그림을 못 그리고 머릿속으로만 다뤄야 함

### 5.4 2차 미분의 역수 = 분산 (Laplace Approximation)

- NLL의 최저점(MLE/MAP)에서 **2차 미분값** 을 구하면, 그 지점의 **곡률(얼마나 뾰족한가)** 을 알 수 있음
- 2차 미분의 **역수 ≈ 분산**

$$
\sigma^2 \approx \left(\frac{d^2\,\text{NLL}}{d\theta^2}\Big|_{\hat\theta}\right)^{-1}
$$

- 뾰족함(2차 미분 큼) → 분산 작음 → 추정이 확실함
- 완만함(2차 미분 작음) → 분산 큼 → 추정이 불확실함
- 이걸 이용하면 posterior를 **정규분포 N(θ̂, σ²)로 근사** 할 수 있고, 그 분포에서 θ 샘플을 원하는 만큼 뽑아 쓸 수 있음
- 비전 시스템 예제에 적용하면 θ̂ = 0.6, σ ≈ 0.052 정도임
- 다차원이면 2차 미분 행렬(Hessian)의 역행렬이 **공분산 행렬** 이 됨
- 이 방법은 통계뿐 아니라 온갖 공학·과학 분야에서 오랫동안 널리 쓰여 온 방법임

---

## 6. Think Bayes Ch.5 — Estimating Counts

4장이 "비율(proportion)" 추정이었다면, 5장은 **"개수(count), 즉 모집단 크기" 추정** 임.

### 6.1 기차 문제 (The Train Problem)

> 철도회사가 기관차에 1부터 N까지 번호를 붙임. 어느 날 **60번** 기관차를 봤음. 기관차는 총 몇 대인가?

**두 단계로 쪼갬**
1. 데이터를 보기 전에 N에 대해 뭘 알았나? → **Prior**
2. N이 주어졌을 때 60번을 볼 확률은? → **Likelihood**

**Prior**: N은 1 ~ 1000 사이 균등(uniform)이라고 가정

**Likelihood**: N대 중 아무거나 똑같은 확률로 보므로
$$
P(\text{60번을 봄}\mid N) = \begin{cases}1/N & N \ge 60\\ 0 & N < 60\end{cases}
$$

- N < 60이면 60번 기관차가 존재할 수 없으니 확률 0
- 이건 4장 **주사위 문제와 같은 likelihood** 임

```python
hypos = np.arange(1, 1001)
prior = Pmf(1, hypos)

def update_train(pmf, data):
    hypos = pmf.qs
    likelihood = 1 / hypos
    likelihood[data > hypos] = 0   # 불가능한 가설은 0
    pmf *= likelihood
    pmf.normalize()
```

**결과**
- 60 미만은 전부 제거됨
- **MAP = 60** (가장 확률이 높은 값) — "하필 제일 큰 번호를 봤을 리가?" 싶지만, 정확히 맞힐 확률을 최대로 하려면 60이 맞음
- **Posterior mean ≈ 333** — 오차 제곱 평균(MSE)을 최소화하려면 평균을 쓰는 게 좋음

$$
\text{mean} = \sum_i p_i q_i \quad(q_i: \text{가능한 값},\ p_i: \text{그 확률})
$$

### 6.2 Prior에 대한 민감도 (Sensitivity to the Prior)

uniform prior의 상한을 바꾸면 결과가 크게 달라짐.

| Prior 상한 | 관측 1개 (60) posterior mean | 관측 3개 (30, 60, 90) posterior mean |
|---|---|---|
| 500 | 207 | 152 |
| 1000 | 333 | 164 |
| 2000 | 552 | 171 |

- 데이터가 1개뿐이면 prior에 따라 결과가 휙휙 바뀜 → 좋지 않음
- 해결책 두 가지
  1. **데이터를 더 모은다** → 데이터가 많아지면 prior가 달라도 posterior가 수렴함 (3개로는 아직 부족)
  2. **배경지식을 더 모아서 더 나은 prior를 쓴다**

### 6.3 Power Law Prior

- 현실에서 회사 규모는 작은 회사가 아주 많고, 큰 회사는 드묾 → **멱법칙(power law)** 을 따름
- 예: 기관차 10대 미만 회사 1000개, 100대 회사 100개, 1000대 회사 10개, 10000대 회사 1개 정도

$$
\text{prior}(N) \propto \left(\frac{1}{N}\right)^\alpha, \quad \alpha \approx 1
$$

```python
alpha = 1.0
ps = hypos**(-alpha)
power = Pmf(ps, hypos)
power.normalize()
```

| Prior 상한 | Power law prior + 관측 3개 posterior mean |
|---|---|
| 500 | 130.7 |
| 1000 | 133.3 |
| 2000 | 134.0 |

- 큰 값에 prior 확률을 적게 줌 → posterior mean이 낮아지고, **상한에 대한 민감도가 거의 사라짐** (상한을 무한히 키워도 134로 수렴)
- 일반적 배경지식에 근거했고 실제로도 더 안정적으로 동작함 → 더 현실적인 prior임

### 6.4 Point Estimate와 Credible Interval

**Point estimate (점 추정)**: posterior를 숫자 하나로 요약
- MAP: 확률이 가장 높은 값
- Posterior mean: 평균

**Percentile / Quantile**
- **percentile rank**: 값 x 이하인 모든 값의 확률을 더한 것
  - 예: `power.prob_le(100)` ≈ 0.29 → 100대는 29번째 percentile
- **quantile**: 반대로, 누적확률이 주어진 값(예: 0.5)을 처음 넘는 지점의 값
  - prob를 0~100(%)로 쓰면 percentile, 0~1(확률)로 쓰면 quantile이라 부름
  - median = 50th percentile = 0.5 quantile → 기차 문제에서 **113**

```python
def quantile(pmf, prob):
    total = 0
    for q, p in pmf.items():
        total += p            # 누적확률을 더해가다가
        if total >= prob:     # prob를 넘는 순간의 값을 반환
            return q
```

**90% Credible Interval**

$$
\Pr[\theta_l < \theta < \theta_u] = 0.9
$$

- 방법 1 — **양쪽 꼬리 5%씩 자르기 (equal-tailed)**
  - 5th percentile = θ_l, 95th percentile = θ_u
  - 기차 문제: `power.credible_interval(0.9)` → **(91, 243)**
    - N ≤ 91일 확률 5%, N > 243일 확률 5% → 그 사이에 있을 확률 90%
- 방법 2 — **수평선 내리기 (highest density interval)**
  - 정규분포처럼 **좌우 대칭** 이면 양쪽 5% 지점이 같은 높이라서, 수평선 하나로 잘라도 방법 1과 같은 구간이 나옴
  - 분포가 **한쪽으로 기울어져 있으면(비대칭)**, 수평선을 위아래로 움직이면서 **곡선과 만나는 두 점 사이의 넓이가 90%가 되도록** 조절함
  - 이렇게 하면 같은 90%를 담으면서 **구간 길이가 가장 짧아짐**

### 6.5 German Tank Problem

- 2차 세계대전 때 연합군이 노획한 독일 전차의 **차대·엔진 일련번호** 로 독일의 전차 생산량을 추정함
- 일련번호가 100개 단위 블록으로 할당되고 블록 안에서 순서대로 사용됨 → 각 블록이 기차 문제와 같은 구조가 됨
- 통계적 추정값은 다른 첩보 추정보다 훨씬 낮았는데, 전후 기록과 비교해 보니 **통계 추정이 훨씬 정확했음**
- 타이어, 트럭, 로켓 등에도 같은 방법을 적용해 실제로 쓸 수 있는 경제 정보를 얻음

### 6.6 Informative vs Uninformative Prior

| 구분 | Informative prior | Uninformative prior |
|---|---|---|
| 의미 | 문제에 대한 배경지식을 최대한 반영 | 최대한 제약을 줄여 데이터가 말하게 함 |
| 장점 | 데이터가 적을 때 큰 차이를 만듦 | 객관적으로 보임 |
| 단점 | 사람마다 정보·해석이 달라 자의적으로 보일 수 있음 | 가진 정보를 버리는 셈 |

- 저자(Downey)는 **informative prior를 선호함**
  - Bayesian 분석은 원래 모델링 결정의 연속임 → prior만 객관적으로 해봐야 전체 분석은 어차피 주관적임
  - 데이터가 많으면 → 어떤 prior를 써도 결과가 거의 같음
  - 데이터가 적으면 → 배경지식(power law 같은)을 쓰는 게 결과를 크게 개선함
  - German tank처럼 생사가 걸린 결정이면, 아는 걸 모르는 척하지 말고 **가진 정보를 모두 써야 함**

---

## 7. 연습문제 — 강당 인원이 1200명보다 적음을 보여라

### 7.1 문제

> 대형 강당에서 강연 중, 소방관이 "인원이 안전 수용 한도 1200명을 넘은 것 같다"고 함. 강연자는 1200명보다 적다고 생각하는데 일일이 세기엔 너무 오래 걸려서 실험을 함.
> 1. "5월 11일생 손 드세요" → **2명**
> 2. "5월 23일생 손 드세요" → **1명**
> 3. "8월 1일생 손 드세요" → **0명**
>
> 강당 인원 N은? N > 1200일 확률은?

### 7.2 모델링

- 각 사람이 특정 날짜 생일일 확률 θ = 1/365
- N명 중 그 날짜 생일인 사람 수 Y ~ **Binomial(N, 1/365)**
- 추정 대상은 θ가 아니라 **N** 임 (θ는 1/365로 고정)

**Prior**: N은 1 ~ 2000 균등 → P(N) = 1/2000
(2000명을 넘을 확률은 거의 없다는 게 결과로 확인됨)

**Likelihood** (세 실험은 서로 독립 → 곱함)

$$
L_1(N) = \binom{N}{2}\theta^2(1-\theta)^{N-2}, \quad
L_2(N) = \binom{N}{1}\theta(1-\theta)^{N-1}, \quad
L_3(N) = \binom{N}{0}\theta^0(1-\theta)^{N}
$$

$$
L(N) = P(Y_1=2, Y_2=1, Y_3=0 \mid N) = L_1(N)\cdot L_2(N)\cdot L_3(N)
$$

**작은 N으로 감 잡기**
- N = 1이면? 1명뿐인데 5월 11일생이 2명 손을 들 수는 없음 → $\binom{1}{2} = 0$ → **L(1) = 0**
  - (실험 2만 보면 N=1일 때 likelihood = $1\cdot\theta(1-\theta)^0 = \theta$ 로 0이 아니지만, 세 실험을 곱하면 실험 1 때문에 0이 됨)
- N이 아주 크면? 8월 1일생이 0명일 확률 $(1-\theta)^N$ 이 급격히 작아짐 → likelihood가 작아짐
- 즉 N이 너무 작아도, 너무 커도 likelihood가 작고, 중간 어딘가에서 커짐

**Posterior**

$$
P(N\mid \text{data}) = \frac{P(N)\cdot L(N)}{\sum_{N'} P(N')\cdot L(N')}
$$

| N | P(N) | Likelihood = P(Y∣N) | P(N)·L(N) | Posterior |
|---|---|---|---|---|
| 1 | 1/2000 | 0 | 0 | 0 |
| 2 | 1/2000 | L(2) | ... | ... |
| ⋮ | ⋮ | ⋮ | ⋮ | ⋮ |
| 2000 | 1/2000 | L(2000) | ... | ... |

```python
from scipy.stats import binom

hypos = np.arange(1, 2001)
prior = Pmf(1, hypos)
prior.normalize()

theta = 1/365
likelihood1 = binom.pmf(2, hypos, theta)
likelihood2 = binom.pmf(1, hypos, theta)
likelihood3 = binom.pmf(0, hypos, theta)

posterior = prior * likelihood1 * likelihood2 * likelihood3
posterior.normalize()

posterior.mean()          # 약 486
posterior.prob_gt(1200)   # 약 0.0115
```

### 7.3 결과

| 항목 | 값 |
|---|---|
| MAP | 약 365명 |
| Posterior mean | 약 **486명** |
| 90% credible interval | 약 (170, 940)명 |
| **Pr[N > 1200]** | ≈ 0.0115 = **약 1.15%** |

- 강당 인원은 약 486명으로 추정되고, 1200명을 넘을 확률은 약 1.15%뿐임
- 소방관이 1% 위험을 받아들일지는 별개 문제지만, 질문 단 3개로 "1200명 미만일 가능성이 매우 높다"를 보일 수 있다는 점이 핵심임
- MAP이 365 근처인 이유: 총 3번 질문해서 손 든 사람이 3명 → "날짜 하나당 평균 1명" → N ≈ 365

---

## 8. Odds (Ch.6 맛보기)

### 8.1 정의

- p = P(Head) — "Yes / 성공 / 합격" 처럼 관심 있는 사건의 확률
- 1 − p = P(Tail) — 반대 사건의 확률

$$
\text{odds} = \frac{p}{1-p}
$$

| p | 1−p | odds = p/(1−p) | 비율 표기 |
|---|---|---|---|
| 0.5 | 0.5 | 1 | 1 : 1 |
| 0.4 | 0.6 | 4/6 = 2/3 | 2 : 3 |
| 0.6 | 0.4 | 6/4 = 3/2 | 3 : 2 |
| 0.8 | 0.2 | 8/2 = 4 | 4 : 1 |

- odds > 1 이면 일어날 가능성이 더 큼, odds < 1 이면 안 일어날 가능성이 더 큼
- p는 0~1 범위, odds는 0~∞ 범위

### 8.2 Odds → 확률로 되돌리기

odds가 a : b 이면

$$
p = \frac{a}{a+b}, \qquad 1-p = \frac{b}{a+b}
$$

- 3 : 2 → p = 3/(3+2) = **3/5 = 0.6**
- 4 : 1 → p = 4/(4+1) = **4/5 = 0.8**, 1−p = 1/(4+1) = **1/5 = 0.2**

odds 값 하나(o)로 쓰면: $p = \dfrac{o}{1+o}$ (예: o = 4 → 4/5)

- 다음 장(Ch.6)에서 odds를 이용한 **Bayes's Rule (odds form)** 을 배움. logistic regression의 log-odds(logit)와도 연결됨.

---

## 9. 한눈에 보는 공식 정리

| 개념 | 공식 |
|---|---|
| 비전 시스템 H 보고 확률 | $P(\text{H 보고}) = 0.8\theta + 0.2(1-\theta) = 0.2 + 0.6\theta$ |
| Binomial likelihood | $L(\theta) = \binom{n}{k}p^k(1-p)^{n-k}$ |
| MLE | $\hat\theta_{MLE} = \arg\max_\theta L(\theta) = \arg\max_\theta \log L(\theta) = \arg\min_\theta \text{NLL}(\theta)$ |
| NLL | $\text{NLL}(\theta) = -\log L(\theta)$ |
| Posterior | $\text{posterior}(\theta) = \dfrac{L(\theta)\,\text{prior}(\theta)}{Z},\ Z = \int L(\theta)\,\text{prior}(\theta)\,d\theta$ |
| MAP | $\hat\theta_{MAP} = \arg\max_\theta[\log L(\theta) + \log\text{prior}(\theta)]$ (Z 불필요) |
| Beta prior | $\text{Beta}(\theta\mid a,b) = \dfrac{\theta^{a-1}(1-\theta)^{b-1}}{B(a,b)}$ |
| 분산 | $\text{Var}[X] = E[(X-\mu)^2]$ |
| 공분산 | $\text{Cov}[X,Y] = E[(X-\mu_X)(Y-\mu_Y)]$, 독립 → 0 (역은 X) |
| Laplace 근사 | $\sigma^2 \approx (\text{NLL}''(\hat\theta))^{-1}$ |
| 기차 문제 likelihood | $P(\text{data}\mid N) = 1/N\ (N \ge \text{data}),\ 0\ (\text{그 외})$ |
| Power law prior | $\text{prior}(N) \propto N^{-\alpha}$ |
| Posterior mean | $\sum_i p_i q_i$ |
| 90% credible interval | $\Pr[\theta_l < \theta < \theta_u] = 0.9$ |
| Odds | $o = p/(1-p)$, $p = o/(1+o)$, a:b → $p = a/(a+b)$ |

---

## 10. 셀프 체크리스트

- [ ] 비전 시스템 문제에서 P(H 보고) = 0.2 + 0.6θ 를 표 없이 유도할 수 있다
- [ ] θ=0, 0.5, 1을 넣어서 H 보고 확률이 각각 0.2, 0.5, 0.8이 되는 이유를 설명할 수 있다
- [ ] log를 씌워도 arg max가 바뀌지 않는 이유(단조증가)를 말할 수 있다
- [ ] NLL을 쓰면 최대화가 최소화 문제가 된다는 걸 이해했다
- [ ] 미분 = 0 으로 θ̂_MLE = 0.6 을 직접 계산할 수 있다 (112 − 84θ = 22 + 66θ)
- [ ] MAP 식에서 어떤 항이 상수라서 버려지는지(조합, B(2,2), Z) 구분할 수 있다
- [ ] MAP을 구할 때는 Z가 필요 없고, posterior 분포 전체가 필요할 때 Z가 필요하다는 걸 안다
- [ ] Prior가 제약조건/정규화 역할을 한다는 의미를 설명할 수 있다
- [ ] 공분산이 0이어도 독립이 아닐 수 있는 예를 들 수 있다
- [ ] 2차 미분의 역수가 분산이 되는 직관(뾰족 ↔ 확실)을 설명할 수 있다
- [ ] 기차 문제의 likelihood가 1/N (N ≥ 60), 0 (N < 60) 인 이유를 안다
- [ ] MAP(60)과 posterior mean(333)이 각각 어떤 목표에 맞는 추정값인지 안다
- [ ] Prior 민감도 문제의 두 가지 해결책(데이터 추가, 더 나은 prior)을 말할 수 있다
- [ ] Power law prior가 왜 상한 민감도를 줄이는지 설명할 수 있다
- [ ] Equal-tailed credible interval과 수평선 방식(HDI)의 차이를 설명할 수 있다
- [ ] 강당 문제에서 N = 1의 likelihood가 0인 이유를 말할 수 있다
- [ ] 강당 문제의 세 likelihood를 Binomial로 쓰고, 곱해서 posterior를 만드는 과정을 설명할 수 있다
- [ ] odds 4:1을 확률 0.8로, 확률 0.4를 odds 2:3으로 바꿀 수 있다