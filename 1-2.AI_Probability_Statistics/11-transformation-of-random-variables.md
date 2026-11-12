# 인공지능확률통계 — Transformation of Random Variables (2026.11.10)

> 참고 교재: H. Pishro-Nik, *Introduction to Probability, Statistics and Random Processes* (probabilitycourse.com, 전체 무료 공개)
> - Ch.4.1.3 Functions of Continuous Random Variables (Method of Transformations, Eq. 4.5 / 4.6)
> - Ch.4.1.4 Solved Problems — **Problem 6** ⭐시험
> - Ch.5.2.4 Functions of Two Continuous Random Variables (Jacobian, Convolution) — **Example 5.29** ⭐시험
> - Ch.5.3 Covariance / Ch.6.1 Covariance Matrix, Multivariate Gaussian
>
> 이 강의의 목적: VAE(Variational Auto-Encoder) 같은 확률적 모형 이론에는 **변수 변환(variable transformation)** 이론이 계속 나옴. 이번 시간은 그 기초를 다지는 것임.

---

## 0. 한눈에 보는 핵심

| 상황 | 공식 |
|---|---|
| 1차원 선형 변환 $Y=aX+b$ | $E[Y]=aE[X]+b$, $\ \mathrm{Var}(Y)=a^2\mathrm{Var}(X)$ |
| 벡터 선형 변환 $\mathbf{Y}=A\mathbf{X}+\mathbf{b}$ | $E[\mathbf{Y}]=A\boldsymbol\mu+\mathbf{b}$, $\ \Sigma_Y=A\Sigma_XA^T$ |
| 이산 합 $Y=X_1+X_2$ (독립) | $P(Y=k)=\sum_i P(X_1=i)P(X_2=k-i)$ (convolution) |
| 연속 1차원, $g$ 단조 | $f_Y(y)=f_X(x)\left|\dfrac{dx}{dy}\right|=\dfrac{f_X(x_1)}{|g'(x_1)|}$ |
| 연속 1차원, $g$ 비단조 (해가 여러 개) | $f_Y(y)=\displaystyle\sum_i \dfrac{f_X(x_i)}{|g'(x_i)|}$ ← **모든 해를 다 더함** |
| 연속 2차원 $(Z,W)=g(X,Y)$ | $f_{ZW}(z,w)=f_{XY}(h_1,h_2)\,|J|$, $J$ = 역함수 $h$의 Jacobian determinant |
| 연속 합 $Z=X+Y$ (독립) | $f_Z(z)=\displaystyle\int f_X(w)f_Y(z-w)\,dw$ |

**모든 공식의 뿌리는 하나: 확률은 보존된다.**
$$f_Y(y)\,|dy| = f_X(x)\,|dx|$$

---

## 1. 선형 변환(Linear Transform)과 평균·분산·공분산

### 1.1 기댓값(Expectation)과 분산(Variance) 복습

- $E[X]=\mu$ : "X의 평균(뮤)"
- 분산: $X$에서 평균을 뺀 것의 제곱에 기댓값을 취한 것
$$\mathrm{Var}(X)=E\big[(X-\mu)^2\big]=E[X^2]-\mu^2$$
- 공분산(Covariance): 두 변수 각각 평균을 빼서 곱한 뒤 기댓값을 취한 것
$$\mathrm{Cov}(X_1,X_2)=E\big[(X_1-\mu_1)(X_2-\mu_2)\big]=E[X_1X_2]-\mu_1\mu_2$$
- $\mathrm{Cov}(X,X)=\mathrm{Var}(X)$ 임. 즉 분산은 "자기 자신과의 공분산"임.

### 1.2 1차원 선형 변환 $Y=aX+b$

- **평균**: $E[Y]=aE[X]+b$ → 평균에도 똑같이 $a$를 곱하고 $b$를 더하면 됨
- **분산**: $\mathrm{Var}(Y)=a^2\,\mathrm{Var}(X)$ → $b$(평행이동)는 퍼진 정도와 무관하므로 사라지고, $a$는 **제곱**으로 들어감

유도:
$$Y-E[Y]=(aX+b)-(a\mu+b)=a(X-\mu)$$
$$\mathrm{Var}(Y)=E\big[a^2(X-\mu)^2\big]=a^2\mathrm{Var}(X)$$

예) $X$의 평균 2, 분산 3, $Y=4X-1$ → $E[Y]=4\cdot2-1=7$, $\mathrm{Var}(Y)=16\cdot3=48$

### 1.3 공분산 행렬(Covariance Matrix, 공분산 행렬)

랜덤 벡터 $\mathbf{X}=[X_1,X_2]^T$ 에 대해
$$\Sigma=\mathrm{Cov}(\mathbf{X})=E\big[(\mathbf{X}-\boldsymbol\mu)(\mathbf{X}-\boldsymbol\mu)^T\big]=
\begin{bmatrix}\mathrm{Var}(X_1) & \mathrm{Cov}(X_1,X_2)\\ \mathrm{Cov}(X_2,X_1) & \mathrm{Var}(X_2)\end{bmatrix}$$

- 대각선 = 각 변수의 분산, 비대각 = 공분산
- 항상 **대칭(symmetric)** 행렬임 ($\mathrm{Cov}(X_1,X_2)=\mathrm{Cov}(X_2,X_1)$)
- 독립이면 비대각이 0 → 대각행렬

### 1.4 벡터 선형 변환 $\mathbf{Y}=A\mathbf{X}+\mathbf{b}$

$$E[\mathbf{Y}]=A\boldsymbol\mu+\mathbf{b},\qquad \Sigma_Y=A\,\Sigma_X\,A^T$$

- 1차원의 $a^2$가 행렬에서는 $A(\cdot)A^T$ 형태가 된 것임
- 유도: $\mathbf{Y}-E[\mathbf{Y}]=A(\mathbf{X}-\boldsymbol\mu)$ 이므로
$\Sigma_Y=E[A(\mathbf{X}-\boldsymbol\mu)(\mathbf{X}-\boldsymbol\mu)^TA^T]=A\Sigma_XA^T$

**자주 쓰는 공분산 성질** (손으로 계산할 때 편함)
$$\mathrm{Cov}(aX+bY,\ cX+dY)=ac\,\mathrm{Var}(X)+(ad+bc)\,\mathrm{Cov}(X,Y)+bd\,\mathrm{Var}(Y)$$

---

## 2. 이산 확률변수의 합 — Convolution

### 2.1 주사위 두 개의 합

$X_1, X_2$ : 공정한 주사위 두 개 (독립), $Y=X_1+X_2$

- $Y=2$ 가 되는 경우: (1,1) **한 가지뿐** → $P(Y=2)=1/36$
- $Y=3$ : $X_1+X_2=3$ 이 되는 경우 (1,2), (2,1) → $2/36$
- 일반적으로 $Y=k$ 가 되려면 "두 개 더한 게 $k$" 가 되는 모든 조합을 찾아서 더하면 됨

$$P(Y=k)=\sum_{i}P(X_1=i)\,P(X_2=k-i)$$

이 형태를 **Convolution(합성곱)** 이라 부름.

| $k$ | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 경우의 수 | 1 | 2 | 3 | 4 | 5 | 6 | 5 | 4 | 3 | 2 | 1 |

→ $P(Y=k)=\dfrac{6-|k-7|}{36}$, 합 = 36/36 = 1 ✓

- 이산(discrete) 케이스는 손으로 따져서 매칭되는 상황을 다 찾으면 됨. 이를 깔끔하게 정리한 것이 convolution 공식임.
- 연속 버전은 7절 참고.

---

## 3. 연속 확률변수의 1차원 변환 $Y=g(X)$

### 3.1 기본 아이디어 — 확률 보존

PDF(Probability Density Function, 확률 밀도 함수)는 "확률" 자체가 아니라 **밀도**임.
$$P(x\le X\le x+\Delta x)\approx f_X(x)\,\Delta x$$
밀도에 폭 $\Delta x$를 곱해야 확률이 됨.

변환 $y=g(x)$ 로 작은 구간 $\Delta x$ 가 $\Delta y$ 로 옮겨가도, **그 안에 들어 있는 확률은 같아야 함** (선형이든 비선형이든 무관).
$$f_Y(y)\,|\Delta y| = f_X(x)\,|\Delta x|\quad\Rightarrow\quad f_Y(y)=f_X(x)\left|\frac{dx}{dy}\right|$$

- 구간이 늘어나면($|dy|>|dx|$) 밀도는 낮아지고, 줄어들면 밀도는 높아짐
- 절댓값을 붙이는 이유: 감소함수면 $dx/dy<0$ 인데 밀도는 음수가 될 수 없음

### 3.2 방법 1 — CDF를 거쳐서 구하기 (가장 안전한 방법)

1. $F_Y(y)=P(Y\le y)$ 를 $X$에 대한 사건으로 바꿈
2. $F_X$로 계산
3. $y$로 미분 → $f_Y(y)=F_Y'(y)$

CDF(Cumulative Distribution Function, 누적 분포 함수): $F_X(x)=P(X\le x)$

#### 예제 A: $X\sim \mathrm{Uniform}(0,1)$, $Y=e^X$ (강의에서 직접 계산)

**Step 0. $Y$의 범위(range)부터 확인**: $x\in[0,1]$ → $y\in[e^0,e^1]=[1,e]$

**Step 1. CDF**
$$F_Y(y)=P(e^X\le y)=P(X\le \ln y)=\ln y\qquad(1\le y\le e)$$
($X$가 Uniform(0,1)이면 $P(X\le t)=t$)

**Step 2. 미분**
$$f_Y(y)=\frac{d}{dy}\ln y=\frac{1}{y},\quad 1\le y\le e\quad(\text{그 외 }0)$$

검산: $\int_1^e \frac1y dy=\ln e-\ln 1=1$ ✓

**Step 3. 기댓값** — $y$에 $y$의 밀도를 곱해서 $y$의 도메인 $[1,e]$에서 적분
$$E[Y]=\int_1^e y\cdot\frac1y\,dy=\int_1^e 1\,dy=e-1\approx1.718$$

> LOTUS(Law of the Unconscious Statistician)로 하면 PDF를 몰라도 바로 됨:
> $E[Y]=E[e^X]=\int_0^1 e^x\cdot 1\,dx=e-1$ — 같은 결과. 기댓값만 필요하면 LOTUS가 더 간단함.

### 3.3 방법 2 — 공식(Method of Transformations)

**(1) $g$가 단조(strictly monotonic)일 때 — Eq. 4.5**
$$f_Y(y)=\frac{f_X(x_1)}{|g'(x_1)|}=f_X(x_1)\left|\frac{dx_1}{dy}\right|,\quad\text{단 } g(x_1)=y$$
($g(x)=y$ 의 해가 없으면 $f_Y(y)=0$)

위 예제 A에 적용: $x_1=\ln y$, $g'(x)=e^x$ → $f_Y(y)=\dfrac{1}{e^{\ln y}}=\dfrac1y$ ✓

**(2) $g$가 단조가 아닐 때 — Eq. 4.6** ★
정의역을 단조인 구간 여러 개로 쪼갤 수 있으면,
$$\boxed{f_Y(y)=\sum_{i=1}^{n}\frac{f_X(x_i)}{|g'(x_i)|}}\qquad x_1,\dots,x_n:\ g(x)=y\text{ 의 모든 실근}$$

- 핵심: **같은 $y$로 여러 $x$가 매핑되면, 각 $x$에서 넘어온 확률을 전부 더해줘야 함** ("여러 군데서 오면 다 더해줘야 됨")
- 그리고 **$y$에 따라 해의 개수가 달라질 수 있음** → $y$ 구간을 나눠서 따로 계산

### 3.4 예제 B: $X\sim\mathrm{Uniform}(-1,1)$, $Y=X^2$ (강의 그림 예제)

그림: $x$축 $-1\sim1$, $y=x^2$ 포물선. $y$축의 한 점 $y$로 **양쪽($+\sqrt y$, $-\sqrt y$)에서 하나로 모여 들어옴** → 두 쪽 확률을 더해야 함.

- 범위: $y\in[0,1]$
- $f_X(x)=\frac12$ ($-1\le x\le1$)
- 해: $x_1=\sqrt y,\ x_2=-\sqrt y$, $|g'(x)|=|2x|=2\sqrt y$

$$f_Y(y)=\frac{1/2}{2\sqrt y}+\frac{1/2}{2\sqrt y}=\frac{1}{2\sqrt y},\qquad 0<y\le1$$

CDF로 검산: $F_Y(y)=P(-\sqrt y\le X\le\sqrt y)=\frac{2\sqrt y}{2}=\sqrt y$ → 미분하면 $\frac{1}{2\sqrt y}$ ✓

> **표준정규 $X$에 대해 $Y=X^2$** 를 같은 방법으로 하면
> $f_Y(y)=\dfrac{1}{\sqrt{2\pi y}}e^{-y/2}\ (y>0)$ → 자유도 1인 **카이제곱(Chi-square) 분포** $\chi^2_1$.
> 회귀(regression)에서 추정값과 실제값 차이(잔차)의 제곱이 카이제곱 분포를 따르는 이유가 이것임.

> **주의**: $y=x^2$처럼 매핑할 때 **$y$의 range가 어떻게 되는지 항상 명확히** 할 것. 범위 밖은 $f_Y=0$.

---

## 4. ⭐시험⭐ Problem 6 — $Y=\sin X$ (교재 Ch.4.1.4 Solved Problems)

> **문제**: $X\sim\mathrm{Uniform}\left(-\dfrac{\pi}{2},\ \pi\right)$, $Y=\sin(X)$. $f_Y(y)$를 구하라.

### 풀이 순서 (시험 답안 쓰는 순서 그대로)

**Step 1. $X$의 PDF**
구간 길이 $= \pi-(-\frac\pi2)=\frac{3\pi}{2}$ 이므로
$$f_X(x)=\frac{1}{3\pi/2}=\frac{2}{3\pi},\qquad -\frac\pi2\le x\le\pi$$

**Step 2. 범위 확인**: $R_X=[-\frac\pi2,\pi]$ → $R_Y=[-1,1]$

**Step 3. 그래프 보고 해의 개수 세기** ($\sin x$ on $[-\frac\pi2,\pi]$)

```
 y
 1 |            * (π/2)
   |         *     *
   |       *         *
 0 +-----*-------------*----- x
   |   *  0                π
-1 * (-π/2)
```

- $-\frac\pi2\to\frac\pi2$ : $-1$에서 $1$까지 **증가**
- $\frac\pi2\to\pi$ : $1$에서 $0$까지 **감소**
- 따라서
  - $y\in(-1,0)$ : 해 **1개** → $x_1=\arcsin y$ (증가 구간에서만 만남)
  - $y\in(0,1)$ : 해 **2개** → $x_1=\arcsin y$, $\ x_2=\pi-\arcsin y$

$\arcsin y$ : "사인값이 $y$가 되는 각도" ($-\frac\pi2\sim\frac\pi2$ 범위로 돌려줌)
$x_2=\pi-\arcsin y$ 인 이유: $\sin(\pi-\theta)=\sin\theta$

**Step 4. 미분값의 절댓값**
$g'(x)=\cos x$.
$$|\cos(\arcsin y)|=\sqrt{1-\sin^2(\arcsin y)}=\sqrt{1-y^2}$$
$$|\cos(\pi-\arcsin y)|=|-\cos(\arcsin y)|=\sqrt{1-y^2}$$
($\cos^2\theta=1-\sin^2\theta$ 이용)

**Step 5. 공식(Eq. 4.6) 적용**

- $y\in(-1,0)$ (해 1개):
$$f_Y(y)=\frac{f_X(x_1)}{|g'(x_1)|}=\frac{\frac{2}{3\pi}}{\sqrt{1-y^2}}=\frac{2}{3\pi\sqrt{1-y^2}}$$

- $y\in(0,1)$ (해 2개 → 더함):
$$f_Y(y)=\frac{f_X(x_1)}{|g'(x_1)|}+\frac{f_X(x_2)}{|g'(x_2)|}=\frac{\frac{2}{3\pi}}{\sqrt{1-y^2}}+\frac{\frac{2}{3\pi}}{\sqrt{1-y^2}}=\frac{4}{3\pi\sqrt{1-y^2}}$$

**Step 6. 최종 답**
$$\boxed{f_Y(y)=\begin{cases}\dfrac{2}{3\pi\sqrt{1-y^2}} & -1<y<0\\[2ex]\dfrac{4}{3\pi\sqrt{1-y^2}} & 0<y<1\\[2ex] 0 & \text{otherwise}\end{cases}}$$

**Step 7. 검산 (전체 적분 = 1?)**
$\int\frac{1}{\sqrt{1-y^2}}dy=\arcsin y$ 이므로
- $\int_{-1}^{0}\frac{2}{3\pi\sqrt{1-y^2}}dy=\frac{2}{3\pi}\cdot\frac\pi2=\frac13$
- $\int_{0}^{1}\frac{4}{3\pi\sqrt{1-y^2}}dy=\frac{4}{3\pi}\cdot\frac\pi2=\frac23$
- 합 $=1$ ✓

직관 확인: $P(Y<0)=P(X\in[-\frac\pi2,0])=\frac{\pi/2}{3\pi/2}=\frac13$ ✓ — 확률 보존이 맞게 됐음.

### 시험 포인트
1. $f_X$ 상수값 $\frac{2}{3\pi}$ 정확히 구하기 (구간 길이 $\frac{3\pi}{2}$)
2. **$y$ 부호에 따라 해의 개수가 1개/2개로 달라짐**을 그래프로 설명
3. $x_2=\pi-\arcsin y$ 찾기
4. $|\cos(\cdot)|=\sqrt{1-y^2}$ 변환
5. 해가 2개인 구간은 **더한다**
6. 최종 답을 구간별(piecewise)로, 범위 밖은 0

---

## 5. 2차원 변환과 Jacobian

### 5.1 Joint CDF / Joint PDF 복습

- Joint CDF: $X\le x_0$ 이고 $Y\le y_0$ 인 영역에 들어갈 확률
$$F_{XY}(x_0,y_0)=P(X\le x_0,\ Y\le y_0)$$
- Joint PDF: $f_{XY}(x,y)=\dfrac{\partial^2F_{XY}}{\partial x\,\partial y}$, 작은 넓이 $dx\,dy$ 를 곱해야 확률이 됨
$$P\big((X,Y)\in \text{작은 사각형}\big)\approx f_{XY}(x,y)\,dx\,dy$$

### 5.2 정리 (Ch.5.2.4) — Jacobian 방법

$(Z,W)=g(X,Y)=(g_1(X,Y),\,g_2(X,Y))$, $g$는 일대일(one-to-one)이고 미분 가능.
역함수 $h=g^{-1}$: $X=h_1(Z,W)$, $Y=h_2(Z,W)$ 라 하면

$$\boxed{f_{ZW}(z,w)=f_{XY}\big(h_1(z,w),\,h_2(z,w)\big)\,|J|}$$

$$J=\det\begin{bmatrix}\dfrac{\partial h_1}{\partial z} & \dfrac{\partial h_1}{\partial w}\\[1.5ex]\dfrac{\partial h_2}{\partial z} & \dfrac{\partial h_2}{\partial w}\end{bmatrix}=\frac{\partial h_1}{\partial z}\frac{\partial h_2}{\partial w}-\frac{\partial h_1}{\partial w}\frac{\partial h_2}{\partial z}$$

읽는 법: "원래 joint PDF의 $x$ 자리에 $h_1$, $y$ 자리에 $h_2$ 를 넣고, 역함수 $h$의 Jacobian determinant 절댓값을 곱한다"

- 1차원 $f_Y(y)=f_X(x)\left|\frac{dx}{dy}\right|$ 의 2차원 버전임. $\frac{dx}{dy}$ (한 변수 미분) → $J=\frac{\partial(x,y)}{\partial(z,w)}$ (편미분 행렬의 determinant)
- 의미: $dx\,dy=|J|\,dz\,dw$ — 넓이가 얼마나 늘어나고 줄어드는지의 배율임. 확률 보존 $f_{ZW}\,dz\,dw=f_{XY}\,dx\,dy$ 그대로.
- **주의**: $J$는 **역함수 $h$** ($x,y$를 $z,w$로 미분)의 Jacobian임. 정방향 $g$의 Jacobian $J_g$를 구했다면 $|J|=1/|J_g|$.

---

## 6. ⭐시험⭐ Example 5.29 — 독립 표준정규의 선형 변환

> **문제**: $X, Y$ 는 **독립(independent)** 인 **표준정규(standard normal)** 확률변수.
> $$Z=2X-Y,\qquad W=-X+Y$$
> 일 때 $f_{ZW}(z,w)$ 를 구하라.

### 풀이

**Step 1. $X,Y$의 joint PDF**
독립이므로 곱하면 됨:
$$f_{XY}(x,y)=f_X(x)f_Y(y)=\frac{1}{\sqrt{2\pi}}e^{-x^2/2}\cdot\frac{1}{\sqrt{2\pi}}e^{-y^2/2}=\frac{1}{2\pi}\exp\left\{-\frac{x^2+y^2}{2}\right\}$$

**Step 2. 역함수 $h$ 구하기** ($x,y$ 를 $z,w$ 로 표현)
$$z=2x-y,\quad w=-x+y$$
두 식을 더하면 $z+w=x$ → $\boxed{x=z+w}$
$y=w+x=w+(z+w)$ → $\boxed{y=z+2w}$

검산: $z=2(z+w)-(z+2w)=z$ ✓, $w=-(z+w)+(z+2w)=w$ ✓

**Step 3. Jacobian**
$$J=\det\begin{bmatrix}\frac{\partial x}{\partial z} & \frac{\partial x}{\partial w}\\ \frac{\partial y}{\partial z} & \frac{\partial y}{\partial w}\end{bmatrix}=\det\begin{bmatrix}1&1\\1&2\end{bmatrix}=1\cdot2-1\cdot1=1$$

(정방향으로 해도 $\det\begin{bmatrix}2&-1\\-1&1\end{bmatrix}=2-1=1$ → 역수도 1 ✓)

**Step 4. 대입**
$$f_{ZW}(z,w)=f_{XY}(z+w,\ z+2w)\cdot|1|=\frac{1}{2\pi}\exp\left\{-\frac{(z+w)^2+(z+2w)^2}{2}\right\}$$

전개: $(z+w)^2+(z+2w)^2=(z^2+2zw+w^2)+(z^2+4zw+4w^2)=2z^2+6zw+5w^2$

$$\boxed{f_{ZW}(z,w)=\frac{1}{2\pi}\exp\left\{-\frac{2z^2+6zw+5w^2}{2}\right\},\qquad z,w\in\mathbb{R}}$$

### 시험 포인트
1. 독립 → joint PDF = 곱
2. **역함수**를 정확히 구하고 검산
3. Jacobian은 **역함수 기준** ($\partial x/\partial z$ …), 절댓값
4. $x$ 자리에 $h_1$, $y$ 자리에 $h_2$ 대입 후 지수 전개
5. $Z,W$ 의 범위: 선형 변환이라 그대로 $\mathbb{R}^2$
6. (심화) 결과가 다시 2차원 가우시안이 됨 → 8절, 과제 참고

---

## 7. 연속 확률변수의 합 — Convolution

$Z=X+Y$ 의 PDF를 구하려면 보조 변수 $W=X$ 를 하나 만들어 2차원 변환으로 바꿈.

- 역함수: $x=w,\ y=z-w$, $J=\det\begin{bmatrix}0&1\\1&-1\end{bmatrix}=-1$ → $|J|=1$
- $f_{ZW}(z,w)=f_{XY}(w,\ z-w)$
- $w$ 를 적분해서 없애면 (marginal):
$$f_Z(z)=\int_{-\infty}^{\infty}f_{XY}(w,\ z-w)\,dw$$
- **독립**이면:
$$\boxed{f_Z(z)=\int_{-\infty}^{\infty}f_X(w)\,f_Y(z-w)\,dw = (f_X * f_Y)(z)}$$

2절 주사위의 $\sum_i P(X_1=i)P(X_2=k-i)$ 와 **완전히 같은 구조**임 (합 → 적분).

**결과**: $X\sim N(\mu_X,\sigma_X^2)$, $Y\sim N(\mu_Y,\sigma_Y^2)$ 독립 →
$$X+Y\sim N(\mu_X+\mu_Y,\ \sigma_X^2+\sigma_Y^2)$$
(예: 표준정규 두 개의 합은 $N(0,2)$)

---

## 8. 다변량 가우시안과 공분산의 역행렬(Inverse Covariance)

### 8.1 벡터 형태(Vector Form)

$D$차원 가우시안:
$$\mathcal N(\mathbf{x}\mid\boldsymbol\mu,\Sigma)=\frac{1}{(2\pi)^{D/2}|\Sigma|^{1/2}}\exp\left\{-\frac12(\mathbf{x}-\boldsymbol\mu)^T\Sigma^{-1}(\mathbf{x}-\boldsymbol\mu)\right\}$$

- $|\Sigma|$ : 공분산 행렬의 determinant
- $\Sigma^{-1}$ : 공분산 행렬의 **역행렬 (precision matrix)** — 지수 안에 들어가는 것은 $\Sigma$ 가 아니라 $\Sigma^{-1}$ 임

### 8.2 독립 가우시안의 곱 → 벡터 형태

Example 5.29 Step 1의 $f_{XY}$ 를 벡터로 쓰면
$$\frac{1}{2\pi}\exp\left\{-\frac{x^2+y^2}{2}\right\}=\frac{1}{2\pi|I|^{1/2}}\exp\left\{-\frac12\begin{bmatrix}x&y\end{bmatrix}I^{-1}\begin{bmatrix}x\\y\end{bmatrix}\right\}$$
→ $\boldsymbol\mu=\mathbf 0$, $\Sigma=I$ (단위행렬)인 2차원 가우시안임. 독립 = 공분산 0 = 대각행렬.

### 8.3 Example 5.29 결과 다시 보기

$$2z^2+6zw+5w^2=\begin{bmatrix}z&w\end{bmatrix}\begin{bmatrix}2&3\\3&5\end{bmatrix}\begin{bmatrix}z\\w\end{bmatrix}$$
(비대각 $6zw$ 를 3, 3으로 반씩 나눠 넣음)

→ 지수 안 행렬 $\begin{bmatrix}2&3\\3&5\end{bmatrix}$ 가 바로 **$(Z,W)$ 공분산 행렬의 역행렬** $\Sigma_{ZW}^{-1}$ 임. 자세한 확인은 아래 과제 풀이.

**결론**: 가우시안을 선형 변환하면 다시 가우시안이며,
$$\mathbf{X}\sim\mathcal N(\boldsymbol\mu,\Sigma)\ \Rightarrow\ A\mathbf{X}+\mathbf b\sim\mathcal N(A\boldsymbol\mu+\mathbf b,\ A\Sigma A^T)$$
Jacobian으로 힘들게 구한 결과와 1.4절의 $A\Sigma A^T$ 공식이 같은 답을 줌.

---

## 9. 자가 점검 체크리스트

- [ ] $Y=aX+b$ 의 평균·분산 공식을 쓰고, 분산에서 $b$가 사라지는 이유를 말할 수 있다
- [ ] 공분산 행렬의 대각/비대각 의미, $\Sigma_Y=A\Sigma_XA^T$ 를 안다
- [ ] 주사위 두 개 합의 분포를 convolution으로 구할 수 있다
- [ ] "확률 보존" $f_Y|dy|=f_X|dx|$ 로부터 변환 공식을 설명할 수 있다
- [ ] CDF 방법으로 $Y=e^X$ ($X\sim U(0,1)$) 의 PDF와 $E[Y]=e-1$ 을 구할 수 있다
- [ ] 비단조 $g$ 에서 해가 여러 개면 **모두 더해야** 함을 안다 ($Y=X^2$)
- [ ] ⭐ Problem 6 ($Y=\sin X$) 을 처음부터 끝까지 손으로 풀고 적분=1 검산까지 할 수 있다
- [ ] 2차원 Jacobian 공식에서 $J$가 **역함수** 기준임을 안다
- [ ] ⭐ Example 5.29 를 역함수 → $J$ → 대입 → 전개 순서로 풀 수 있다
- [ ] 연속 convolution 식을 보조변수 $W=X$ 로 유도할 수 있다
- [ ] 다변량 가우시안 지수에 $\Sigma^{-1}$ 가 들어감을 안다

---
---

# 📝 과제

## 문제

Example 5.29 에서 $X,Y$ 는 독립 표준정규, $Z=2X-Y,\ W=-X+Y$ 이다.

1. 선형 변환 공식 $\Sigma_{ZW}=A\Sigma_{XY}A^T$ 를 이용해 $(Z,W)$ 의 평균 벡터와 공분산 행렬을 구하라.
2. 1의 결과를 2차원 가우시안 벡터 형태 $\mathcal N(\boldsymbol\mu,\Sigma)$ 에 대입하면 Jacobian 방법으로 구한
$f_{ZW}(z,w)=\dfrac{1}{2\pi}\exp\left\{-\dfrac{2z^2+6zw+5w^2}{2}\right\}$ 와 같아짐을 보여라.
(즉, 지수 안의 행렬이 공분산 행렬의 역행렬임을 확인하라.)

## 풀이

### 1. 평균과 공분산 행렬

행렬로 쓰면
$$\begin{bmatrix}Z\\W\end{bmatrix}=\underbrace{\begin{bmatrix}2&-1\\-1&1\end{bmatrix}}_{A}\begin{bmatrix}X\\Y\end{bmatrix}$$

- 평균: $E[X]=E[Y]=0$ 이므로 $E[Z]=E[W]=0$ → $\boldsymbol\mu_{ZW}=\mathbf 0$
- $X,Y$ 독립 표준정규 → $\Sigma_{XY}=I$

$$\Sigma_{ZW}=AIA^T=AA^T=\begin{bmatrix}2&-1\\-1&1\end{bmatrix}\begin{bmatrix}2&-1\\-1&1\end{bmatrix}$$

원소별 계산:
- (1,1): $2\cdot2+(-1)(-1)=5$
- (1,2): $2\cdot(-1)+(-1)\cdot1=-3$
- (2,1): $(-1)\cdot2+1\cdot(-1)=-3$
- (2,2): $(-1)(-1)+1\cdot1=2$

$$\boxed{\Sigma_{ZW}=\begin{bmatrix}5&-3\\-3&2\end{bmatrix}}$$

공분산 성질로 교차 확인:
- $\mathrm{Var}(Z)=\mathrm{Var}(2X-Y)=4\cdot1+1\cdot1=5$ ✓
- $\mathrm{Var}(W)=\mathrm{Var}(-X+Y)=1+1=2$ ✓
- $\mathrm{Cov}(Z,W)=\mathrm{Cov}(2X-Y,\,-X+Y)=2(-1)\mathrm{Var}(X)+(-1)(1)\mathrm{Var}(Y)=-2-1=-3$ ✓ (독립이라 $\mathrm{Cov}(X,Y)=0$)

### 2. 가우시안 벡터 형태에 대입

**determinant**: $|\Sigma_{ZW}|=5\cdot2-(-3)(-3)=10-9=1$

**역행렬** (2×2: $\begin{bmatrix}a&b\\c&d\end{bmatrix}^{-1}=\frac{1}{ad-bc}\begin{bmatrix}d&-b\\-c&a\end{bmatrix}$)
$$\Sigma_{ZW}^{-1}=\frac11\begin{bmatrix}2&3\\3&5\end{bmatrix}=\begin{bmatrix}2&3\\3&5\end{bmatrix}$$

검산: $\begin{bmatrix}5&-3\\-3&2\end{bmatrix}\begin{bmatrix}2&3\\3&5\end{bmatrix}=\begin{bmatrix}10-9&15-15\\-6+6&-9+10\end{bmatrix}=I$ ✓

**대입** ($D=2$, $\boldsymbol\mu=\mathbf 0$)
$$f_{ZW}(z,w)=\frac{1}{(2\pi)^{1}\cdot1^{1/2}}\exp\left\{-\frac12\begin{bmatrix}z&w\end{bmatrix}\begin{bmatrix}2&3\\3&5\end{bmatrix}\begin{bmatrix}z\\w\end{bmatrix}\right\}$$

이차형식 전개:
$$\begin{bmatrix}z&w\end{bmatrix}\begin{bmatrix}2z+3w\\3z+5w\end{bmatrix}=z(2z+3w)+w(3z+5w)=2z^2+6zw+5w^2$$

$$\therefore\ f_{ZW}(z,w)=\frac{1}{2\pi}\exp\left\{-\frac{2z^2+6zw+5w^2}{2}\right\}$$

→ Jacobian 방법의 결과와 **정확히 일치**함.

### 정리
- 정규화 상수 $\frac{1}{2\pi}$ 가 그대로인 이유: $|\Sigma_{ZW}|=|A|^2|I|=1^2=1$ 이고, Jacobian 방법에서 $|J|=1$ 이었던 것과 같은 사실임
- 지수 안의 행렬 $\begin{bmatrix}2&3\\3&5\end{bmatrix}$ = $\Sigma_{ZW}^{-1}$ (공분산의 역행렬)
- 따라서 $(Z,W)\sim\mathcal N\left(\mathbf 0,\ \begin{bmatrix}5&-3\\-3&2\end{bmatrix}\right)$ — 가우시안의 선형 변환은 다시 가우시안이고, 공분산은 $A\Sigma A^T$