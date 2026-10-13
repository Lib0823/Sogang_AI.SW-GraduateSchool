# 딥러닝 기초 6주차 — Fancier Optimization, Regularization, Transfer Learning, Self-Supervised Learning

> 낭종호 교수 / 2026.10.12 (월)
> 범위: Lecture 6 *Training Neural Networks, Part 2* 후반부 (Optimization ~ Transfer Learning) + Lecture 7 *Self-supervised Learning* 전체
> 기본 교재: Stanford CS231n (2017) Lecture 7 + 최신 내용 추가

**시험 안내**: 계산기 사용 가능, **A4 용지 1장에 정리한 내용 지참 가능**

---

## 0. 큰 흐름 복습 — 이미지 분류 방법의 발전 (기출 18점 문제)

> 문제: 이미지 분류 방법은 "k-Nearest Neighbor → Linear Classifier → Neural Network → Deep NN"으로 발전함. 각 방법의 문제점과, 다음 방법에서 그 문제를 어떻게 해결했는지 설명하라. (각 3점 × 6 = 18점)

| 단계 | 문제점 | 다음 단계의 해결 방법 |
|---|---|---|
| **(a) KNN** | 모든 class의 학습 데이터 전부와 비교해야 하므로 predict 시간이 김 → **O(N)** | **(b) Linear Classifier**: 학습을 통해 class별 **대표 template을 weight 형태로** 만들어 두고, predict 시에는 대표 template만 비교함 |
| **(c) Linear Classifier** | template과의 비교가 **linear 함수**라서, 선형으로 분리되지 않는 복잡한 분류 문제는 풀 수 없음 | **(d) Multi-layer NN (1990년대)**: Linear Classifier를 여러 단계로 쌓고 단계마다 **Non-linearity(Activation Function)** 를 둠 |
| **(e) MNN** | network가 깊어지면 **gradient descent 문제(vanishing gradient)** 가 발생해서 학습이 잘 안 됨 | **(f) DNN (2010년대)**: **ReLU, Batch Normalization** 등으로 vanishing gradient 해결 |

- 2012년 CNN(AlexNet)으로 이미지 분류에서 DNN이 잘 된다는 게 확인됐고, 몇 년 뒤 이를 자연어 처리에 적용함
- 지금까지 배운 Data Preprocessing, Weight Initialization, Batch Normalization 등은 모두 **DNN이 학습이 잘 되게 하는 기법**임
  - **Data Preprocessing**: 데이터를 zero-centered → normalized 시켜 정규분포 형태로 만듦. normalize 전에는 weight가 조금만 바뀌어도 loss가 크게 변해 최적화가 어렵고, normalize 후에는 weight 변화에 덜 민감해서 최적화가 쉬움

### 이번 시간 주제 (Today)
1. **Fancier Optimization** — loss를 더 잘, 더 빨리 줄이는 방법
2. **Regularization** — training error와 validation error의 gap을 줄이는 방법 (overfitting 완화)
3. **Transfer Learning** — 적은 데이터로도 학습하는 방법
4. **Self-Supervised Learning** (Lecture 7) — label 없이 큰 모델을 학습하는 방법

---

## 1. Optimization 기본

### 1-1. Loss Space (Loss Landscape)
- NN의 출력은 **중간에 있는 weight W가 어떤 값이냐**에 의해 결정됨
- **Loss** = 학습 데이터를 넣었을 때 **우리가 원하는 정답과 NN이 예측한 값의 차이**
- weight가 $w_1, w_2$ 두 개라면, $(w_1, w_2)$ 값에 따른 loss를 지형도(평면/곡면)로 그릴 수 있음 → 이게 **loss space**
- **Optimization** = 학습 데이터 전체에 대한 **평균 loss를 가장 작게 하는 W를 찾는 것**
  - 무식한 방법: 모든 W 조합을 다 해보기 → W가 너무 많아서 불가능
  - 그래서 "가장 작게 만드는 W를 어떻게 효율적으로 찾을 것인가"가 optimization 문제임
- **loss space는 데이터셋에 의해 결정됨** → 데이터가 추가되거나 바뀌면 loss space도 달라짐

### 1-2. Vanilla Gradient Descent

$$w_{t+1} = w_t - \eta \nabla L(w_t)$$

- $\nabla L(w_t)$ (그래디언트, "나블라 L"): 현재 위치에서 **loss가 가장 빠르게 증가하는 방향**
- $\eta$ (에타): learning rate, 한 번에 얼마나 이동할지
- **minus를 붙이는 이유**: loss가 작아지는 방향(기울기의 반대 방향)으로 가야 하기 때문임

```python
while True:
    weights_grad = evaluate_gradient(loss_fun, data, weights)
    weights += -step_size * weights_grad   # loss가 작아지는 방향으로 update
```

- 각 weight가 loss에 얼마나 기여했는지는 **chain rule로 gradient를 backpropagation** 시켜서 구함 (맨 아래층 w의 영향은 바로 계산하기 어려우니 한 단계씩 내려오면서 계산)
- **1차원 예시**: $L(w) = w^2$, 시작점 $w=-3$
  - $\nabla L = 2w = -6$ → $\eta = 0.1$이면 $w = -3 - 0.1 \times (-6) = -2.4$
  - 반복하면 $w = 0$ (loss 최소)에 수렴함

### 1-3. Batch / Mini-batch / Stochastic GD

| 방식 | 한 번 update에 쓰는 데이터 | 특징 |
|---|---|---|
| **Batch GD** | 전체 학습 데이터 | 경로가 매끄럽지만 한 걸음이 너무 오래 걸림 |
| **Mini-batch GD** | 일부(mini-batch) | 실무 표준 |
| **SGD** (batch size "1") | 데이터 1개 | 보통 "하나 보고 한 번 update"라는 의미로 씀. 경로가 지그재그(noisy) |

- 실제로는 mini-batch로 gradient를 **추정(estimate)** 함:

$$L(W) = \frac{1}{N}\sum_{i=1}^{N} L_i(x_i, y_i, W), \qquad \nabla_W L(W) = \frac{1}{N}\sum_{i=1}^{N} \nabla_W L_i(x_i, y_i, W)$$

  - mini-batch에 있는 데이터의 loss를 누적(accumulate)해서 gradient를 구함

### 1-4. Learning Rate의 영향
- **너무 작음**: 수렴이 매우 느림
- **적절함**: 안정적으로 수렴
- **너무 큼**: 진동하거나 발산함

---

## 2. SGD의 문제점

### 문제 ① Poor Conditioning — 지그재그(Zig-zag)
- loss가 **한 방향으로는 급격히, 다른 방향으로는 완만하게** 변하면?
  - 가파른 방향(steep)으로는 왔다 갔다 진동(jitter)하고, 완만한 방향(shallow)으로는 아주 느리게 진행함
- 이런 loss function을 **condition number가 크다**고 함 (Hessian 행렬의 가장 큰 singular value / 가장 작은 singular value 비율이 큼)

**왜 이런 일이 생기나? — 뉴런 예시로 보기**

| 입력 | weight | 곱 | weight의 gradient (= 입력 × upstream 100) |
|---|---|---|---|
| $x_1 = 100$ | $w_1 = 10$ | 1000 | **10,000** |
| $x_2 = 100$ | $w_2 = 10$ | 1000 | 10,000 |
| $x_n = -2$ | $w_n = 1$ | -2 | **-200** |

- 출력 = 1000 + 1000 − 2 = 1998 → ReLU 통과 → upstream gradient 100이 내려옴
- $w_n$은 출력(1998)에 거의 영향을 못 줬음 (loss space에서 **shallow direction**)
- 그런데도 $w_n$은 **출력에 영향을 많이 준 다른 weight들 때문에 결정된 upstream gradient에 맞춰서** update됨
- 이 update는 영향 큰 weight 입장에서는 loss를 줄이는 방향이지만, **$w_n$ 입장에서는 아닐 수도 있음** → 방향별로 update 양이 불균형해짐

### 문제 ② Local Minima와 Saddle Point

| | 모양 | 문제 |
|---|---|---|
| **Local minima** | 움푹 파인 골짜기 | gradient = 0 → **빠져나오지 못함** |
| **Saddle point (안장점)** | 한 방향은 내려가고 다른 방향은 올라가는 평평한 지점 | 더 내려가야 하는데 gradient가 엄청 작은 값이라 **매우 느리게 진행됨** |

- **고차원에서는 local minima보다 saddle point가 훨씬 흔함** (모든 방향이 동시에 오르막인 경우보다, 일부 방향만 오르막인 경우가 훨씬 많기 때문)

### 문제 ③ Noisy Gradient
- gradient를 mini-batch에서 구하므로 noisy함
- mini-batch마다 데이터 구성이 다르기 때문에, 어떤 mini-batch에 대해 loss를 줄이는 방향으로 update해도 **다른 mini-batch에서는 loss를 줄이는 방향이 아닐 수 있음**

---

## 3. Fancier Optimization 알고리즘

> 큰 그림: 두 갈래로 발전함
> - **Gradient의 크기(절대값)에 따른 update**: SGD → SGD+Momentum → Nesterov
> - **과거 Gradient 값과의 비율(상대값)에 따른 update**: AdaGrad → RMSProp → Adam

### 3-1. SGD + Momentum — "원래 가던 방향으로 가려는 관성"

$$v_{t+1} = \rho v_t + \nabla f(x_t), \qquad x_{t+1} = x_t - \alpha v_{t+1}$$

```python
vx = 0
while True:
    dx = compute_gradient(x)
    vx = rho * vx + dx            # 이전까지 누적된 gradient와 이번 gradient의 weighted sum
    x -= learning_rate * vx
```

- $v$: velocity(속도), gradient의 **running mean**
- $\rho$ (로): **friction(마찰력)** 역할, 보통 0.9 또는 0.99
- 최근 gradient일수록 가중치가 큼: $g_1, g_2, g_3$이 차례로 들어오면 $v_3 = \rho^2 g_1 + \rho g_2 + g_3$
- **작은 숫자 예시** ($\rho = 0.9$, gradient가 계속 1이면)
  - $v_1 = 1,\ v_2 = 0.9 + 1 = 1.9,\ v_3 = 1.71 + 1 = 2.71$ → 같은 방향이 계속되면 **가속됨**
  - 이후 gradient가 0이 돼도 $v_4 = 0.9 \times 2.71 = 2.44$ → **계속 움직임**
- $\rho = 1$ (마찰 없음)이면 dx = 0이라도 계속 update가 일어남

**효과**
- **Local minima / Saddle point**: local gradient가 0이라도 관성으로 벗어날 수 있음
- **Poor conditioning**: 진동 방향은 서로 상쇄되고, 일관된 방향은 누적돼서 지그재그가 줄어듦
- **Gradient noise**: 이동이 부드러워짐 (smooth)

**단점**: 가던 방향으로 계속 가니까 **Overshooting**(최소점을 지나쳐버림)이 일어날 수 있음

### 3-2. Nesterov Momentum — "갈 곳의 gradient를 반영하자"

| | Momentum | Nesterov |
|---|---|---|
| 순서 | 현재 위치에서 gradient를 구한 후, 거기에 velocity를 더해서 옮김 | **velocity만큼 먼저 옮겨서, 그 위치에서 gradient를 구함** |
| 의미 | 현재 기준 | 미리 가볼 곳(look-ahead) 기준 → weight를 먼저 update하고 forward |

$$v_{t+1} = \rho v_t - \alpha \nabla f(x_t + \rho v_t), \qquad x_{t+1} = x_t + v_{t+1}$$

- **직관 예시**: velocity가 100인 상태
  - 가볼 곳의 새로운 gradient가 +2 (오르막) → velocity를 100 − 2로 줄임
  - 가볼 곳의 새로운 gradient가 −2 (내리막) → velocity를 100 + 2로 늘림
  - 즉 **앞을 미리 보고 브레이크를 밟거나 가속함** → overshooting이 덜함
- $x_t + \rho v_t$ 위치에서 gradient를 구하는 게 불편하므로, 변수 치환 $\tilde{x}_t = x_t + \rho v_t$ 로 다시 정리함:

$$v_{t+1} = \rho v_t - \alpha \nabla f(\tilde{x}_t), \qquad \tilde{x}_{t+1} = \tilde{x}_t + v_{t+1} + \underbrace{\rho(v_{t+1} - v_t)}_{\text{correction factor}}$$

```python
dx = compute_gradient(x)
old_v = v
v = rho * v - learning_rate * dx
x += -rho * old_v + (1 + rho) * v
```

**Sharp minimum과 overfitting**
- 좁고 뾰족한 골짜기(sharp minimum)는 학습 데이터에만 딱 맞는 지점 → **overfitting** 지점일 가능성이 높음
- 이런 지점은 **overshooting을 해야 빠져나올 수 있음** (momentum 계열의 장점이 되기도 함)
- 학습 데이터가 많아지면 이런 뾰족한 point 자체가 없어짐

**비교 정리**
- **SGD**: zig-zag 때문에 weight update가 너무 느림
- **SGD + Momentum**: 가던 방향으로 계속 가니까 overshooting이 일어날 수 있음
- **Nesterov**: overshooting이 일어날 수 있지만 많이 일어나지는 않음 (error correction term 덕분)

### 3-3. AdaGrad — "과거 대비 비율만큼 update하자"

```python
grad_squared = 0
while True:
    dx = compute_gradient(x)
    grad_squared += dx * dx                                   # 과거 gradient 제곱을 계속 누적
    x -= learning_rate * dx / (np.sqrt(grad_squared) + 1e-7)  # 누적값의 제곱근으로 나눔
```

$$\text{새로운 update 양} = \frac{dx_j}{\sqrt{\sum_{i=0}^{j} dx_i^2}}$$

- **차원(파라미터)별로 따로** 계산하는 element-wise scaling임
- 1e-7: 0으로 나누는 것을 방지하는 작은 값

| 방식 | 반영하는 것 |
|---|---|
| SGD, Momentum, Nesterov | 지금까지 gradient의 **합 (Amount, 양)** |
| AdaGrad | 지금까지 gradient 합에 비해 **지금 gradient의 크기 (Ratio, 비율)** |

- 과거에 gradient가 작았다가 갑자기 커지면 → 많이 반영
- 과거에 gradient가 컸다가 갑자기 작아지면 → 조금만 반영

**Q1. 지그재그 문제에서 AdaGrad는 어떻게 동작하나?**
- small gradient 방향 → 작은 수로 나눔 → update가 커짐
- large gradient 방향 → 큰 수로 나눔 → update가 작아짐
- → **각 dimension의 update 양을 비슷하게 만듦**
- 예시: A 방향 gradient가 매번 10, B 방향이 매번 0.1이면 첫 step에서 A: $10/\sqrt{100} = 1$, B: $0.1/\sqrt{0.01} = 1$ → **둘 다 1씩 움직임**

**Q2. 오래 학습하면 step size는?**
- 처음에는 분모가 작아서 크게 움직이다가, 학습이 진행될수록 **분모(누적합)가 계속 커져서 step size가 0에 가까워짐**
- 위 예시에서 A의 2번째 step: $10/\sqrt{200} \approx 0.71$, 3번째: $10/\sqrt{300} \approx 0.58$ … 계속 줄어듦
- → 학습이 멈춰버릴 수 있음 → **누적 gradient의 영향을 점점 줄여나가자 = RMSProp**

### 3-4. RMSProp — "과거 누적값의 일정 비율만 반영하자"

```python
grad_squared = 0
while True:
    dx = compute_gradient(x)
    grad_squared = decay_rate * grad_squared + (1 - decay_rate) * dx * dx   # 지수이동평균
    x -= learning_rate * dx / (np.sqrt(grad_squared) + 1e-7)
```

- 누적합 대신 **지수이동평균(exponential moving average)** 을 씀 → 오래된 gradient는 영향이 점점 줄어듦
- decay_rate 보통 0.9 (또는 0.99)
  - decay_rate = 1: 이번 gradient를 아예 반영 안 함 (의미 없음)
  - decay_rate = 0: 이번 $(dx)^2$만 사용
- 예시: dx가 계속 10이고 decay_rate = 0.9이면 grad_squared는 100으로 수렴 → step = $10/\sqrt{100} = 1$로 **계속 유지됨** (AdaGrad처럼 0으로 줄지 않음)

**비교**
- SGD: 느림
- SGD + Momentum: overshooting
- AdaGrad, RMSProp: 모든 dimension에서 거의 같은 비율로 진행 (approximately equal progress among all dimensions)

### 3-5. Adam = (SGD + Momentum) + (RMSProp)

```python
first_moment = 0
second_moment = 0
for t in range(1, num_iterations):
    dx = compute_gradient(x)
    first_moment  = beta1 * first_moment  + (1 - beta1) * dx         # Momentum (1차 모멘트, 평균)
    second_moment = beta2 * second_moment + (1 - beta2) * dx * dx    # RMSProp (2차 모멘트, 분산)
    first_unbias  = first_moment  / (1 - beta1 ** t)                 # Bias correction
    second_unbias = second_moment / (1 - beta2 ** t)
    x -= learning_rate * first_unbias / (np.sqrt(second_unbias) + 1e-7)
```

- 분자에 **현재 gradient 대신 momentum**을 사용한 RMSProp이라고 보면 됨 → **방향(momentum)과 스텝 크기(RMSProp)를 모두 적절하게**
- **Bias correction이 필요한 이유**: first/second moment가 0에서 시작하므로 초기에는 값이 0쪽으로 치우쳐 너무 작음
  - 처음에는 $(1 - \beta^t)$가 작은 수 → 작은 수로 나눠서 moment를 크게 키워줌
  - 학습이 진행될수록 $\beta^t \to 0$, 즉 1로 나누게 되어 원래 moment 값으로 진행함
  - 예시: $t=1,\ \beta_1 = 0.9$ → first_moment $= 0.1 \cdot dx$ → $0.1 \cdot dx / (1 - 0.9) = dx$ (원래 크기로 복원)
- **추천 기본값**: $\beta_1 = 0.9,\ \beta_2 = 0.999$, learning_rate = 1e-3 또는 5e-4
- **Adam is a good default choice in most cases** — 대부분의 딥러닝 문제에서 기본 선택
- 단점: 일반화 성능이 SGD보다 나쁠 때가 있음, 메모리 사용량이 큼 (파라미터마다 moment 2개 저장)

### 3-6. 최적화 알고리즘 계보 한눈에 보기

```
GD ─(조금만 보고 빨리)─▶ SGD
                         ├─(스텝 방향)──▶ Momentum ──▶ NAG(Nesterov) ──┐
                         │                    └──────────┐               ├─▶ Nadam (Adam + NAG)
                         └─(스텝 사이즈)─▶ AdaGrad ─▶ RMSProp ─▶ Adam ──┘
                                              └─▶ AdaDelta (보폭이 너무 작아져 멈추는 걸 방지)
```

| 알고리즘 | 업데이트 방향 | 학습률 | 수렴 속도 | 안정성 | 추천 상황 |
|---|---|---|---|---|---|
| SGD | 현재 기울기 | 일정 | 느림 | 낮음 | 간단한 문제, 베이스라인 |
| Momentum | + 과거 기울기 | 일정 | 빠름 | 높음 | 대부분의 문제 |
| AdaGrad | 파라미터별 학습률 감소(누적) | 자동 감소 | 초기 빠름, 후반 느림 | 중간 | 희소 데이터 (예: NLP) |
| RMSProp | 최근 기울기 지수이동평균 | 자동 조절 | 빠름 | 높음 | 딥러닝 일반 |
| Adam | 1차 + 2차 모멘트 (편향 보정) | 자동 조절 | 가장 빠름 | 높음 | 거의 모든 딥러닝 문제 (기본 선택) |

---

## 4. Beyond Training Error — Train/Validation gap 줄이기

### 4-1. Loss가 가장 작은 게 좋은 건가?
- 좋은 optimizer는 **training loss**를 줄여줌
- 하지만 loss가 작다 = **학습 데이터에 딱 맞춘다**는 뜻
- 우리가 진짜 신경 쓰는 건 **처음 보는 데이터(new data)에서의 error**임
  - 학습 데이터에 덜 맞더라도 test 데이터에서는 더 잘 맞을 수 있음
  - 학습 데이터에 없는 데이터에 대해서는 정확도가 떨어질 수밖에 없음
- **Validation data**: 학습에 사용하지 않은 데이터로, 학습 중 성능 측정에 사용함
- 학습 곡선 패턴:
  - training loss: 계속 줄다가 0까지는 가지 않고 평평해짐
  - validation loss: 줄어들다가 **어느 순간 다시 커짐** → 이 시점에서 학습을 멈춤 (**Early Stopping**)

### 4-2. Gap을 줄이는 방법 정리

1. **여러 개의 모델을 사용 (Model Ensembles)**: 여러 independent model을 training하고, test 시에 각 모델의 결과를 평균해서 최종 결정
2. **하나의 모델을 사용**
   - a. **CLR (Cyclic Learning Rate)**, **Polyak Averaging**
   - b. **Regularization**
     1. Loss에 regularization term 추가
     2. Dropout (node)
     3. Batch Normalization
     4. Data Augmentation
     5. DropConnect (weight)
     6. Fractional Max Pooling
     7. (+ Stochastic Depth)

### 4-3. Model Ensembles
1. 여러 개의 independent model을 학습시킴
2. test 시에 결과를 평균함
→ 보통 **약 2% 추가 성능 향상**

**Snapshot Ensembles** — 모델을 여러 개 따로 학습시키는 대신, **하나의 모델을 학습하는 도중의 snapshot 여러 개**를 사용함
- **Cyclic learning rate schedule** (예: cosine annealing with restart)을 쓰면 더 효과적임
  - learning rate를 줄여서 한 local minimum에 수렴시키고 snapshot 저장 → learning rate를 다시 크게 올려 그곳을 탈출 → 다른 minimum에 수렴 → 반복
  - 학습 1번으로 M개 모델을 얻는 효과 ("train 1, get M for free")

### 4-4. Polyak Averaging
- **학습이 끝난 후의 weight 값을 최종값으로 쓰는 게 아니라, 학습 단계의 최근 weight 값들을 평균내서 최종값으로 정함**

$$\theta_t = \frac{1}{t}\sum_{i} \theta_i$$

```python
while True:
    data_batch = dataset.sample_data_batch()
    loss = network.forward(data_batch)
    dx = network.backward()
    x += -learning_rate * dx
    x_test = 0.995 * x_test + 0.005 * x   # test용 weight는 이동평균으로 따로 유지
```

- 동기: 최소점 주변에서 양쪽 벽을 왔다 갔다 진동하는 경우, 평균을 내면 골짜기 중앙(최소점)에 더 가까워짐

---

## 5. Regularization

> **Single 모델 상에서** train/validation gap을 줄이는 방법

### 5-1. Loss에 Regularization Term 추가

$$L = \underbrace{\frac{1}{N}\sum_{i=1}^{N}\sum_{j \neq y_i} \max(0,\ f(x_i;W)_j - f(x_i;W)_{y_i} + 1)}_{\text{학습 데이터에 weight를 맞추자 (SVM loss)}} + \underbrace{\lambda R(W)}_{\text{학습 데이터에 weight가 종속되지 않게 하자}}$$

| 종류 | $R(W)$ | 비고 |
|---|---|---|
| **L2 regularization** | $\sum_k \sum_l W_{k,l}^2$ | **Weight decay**, 가장 많이 씀 |
| L1 regularization | $\sum_k \sum_l \lvert W_{k,l}\rvert$ | |
| Elastic net (L1 + L2) | $\sum_k \sum_l \beta W_{k,l}^2 + \lvert W_{k,l}\rvert$ | |

- 너무 큰 weight 값을 갖지 않도록 페널티를 줘서 **모델을 단순하게** 만듦 → 노이즈까지 학습하는 것을 막음
- $\lambda$가 너무 크면 **과소적합(underfitting)** 이 생길 수 있음
- regularization term을 쓰면서 큰 모델도 overfitting 없이 학습시킬 수 있게 됨

### 5-2. Regularization의 공통 패턴
- **Training**: random noise를 추가함
- **Testing**: noise에 대해 marginalize(평균)함

### 5-3. Dropout
- **각 forward pass마다 일부 뉴런을 랜덤하게 0으로 만듦**
- dropping 확률은 hyperparameter, 0.5가 흔함
- 일반적으로 **fully-connected layer에서는 neuron**을, **convolution layer에서는 channel**을 drop-out 함
- 결과적으로 매번 **더 작은 버전의 NN(smaller version of the NN)** 을 학습시키는 셈임

```python
p = 0.5  # unit을 활성 상태로 유지할(keep) 확률. 높을수록 dropout이 적음

def train_step(X):
    H1 = np.maximum(0, np.dot(W1, X) + b1)      # ReLU
    U1 = np.random.rand(*H1.shape) < p          # first dropout mask (True/False)
    H1 *= U1                                    # drop!
    H2 = np.maximum(0, np.dot(W2, H1) + b2)     # ReLU
    U2 = np.random.rand(*H2.shape) < p          # second dropout mask
    H2 *= U2                                    # drop!
    out = np.dot(W3, H2) + b3
```

- mask 동작 예: `u1 = [False, True, False]`, `h1 = u1 * [2, 3, 4]` → `[0, 3, 0]`

**왜 Dropout이 좋은 아이디어인가?**

1. **Feature 간 co-adaptation 방지 (redundant representation 강제)**
   - 고양이 점수를 "귀가 있음, 꼬리가 있음, 털이 있음, 발톱이 있음, 장난스러운 표정"으로 판단한다고 할 때, 일부 feature가 랜덤하게 꺼지면 남은 feature만으로도 판단할 수 있어야 함
   - → NN이 **특정 feature에 종속되지 않게** 함 (예: 귀가 없는 고양이도 있음)
   - → 많은 feature에 dependency를 **분산(distribute)** 시키는 효과 → **overfitting 방지**
2. **Model Ensemble in Single Model**
   - Dropout은 **parameter를 공유하는 거대한 ensemble**을 학습시키는 것으로 볼 수 있음
   - 각 binary mask 하나가 모델 하나임
   - 4096 unit의 FC layer → 가능한 mask 수는 $2^{4096} \approx 10^{1233}$개 (우주의 원자 수는 약 $10^{82}$개)

**Dropout: Test time**
- Dropout을 쓰면 출력이 random이 됨: $y = f_W(x, z)$ ($z$: random mask)
- test 시에는 randomness를 평균내고 싶음:

$$y = f(x) = E_z[f(x,z)] = \int p(z) f(x,z)\,dz$$

- 이 적분은 계산하기 어려움
  - test에서도 dropout을 켜고 쓰면 출력이 random이라 **여러 번(예: 10번) 돌려서 평균**을 내야 함
- **근사 방법**: 뉴런 하나로 생각해보기 (입력 $x, y$, weight $w_1, w_2$, keep 확률 0.5)
  - test 시 (dropout 없음): $E[a] = w_1 x + w_2 y$
  - training 시 (4가지 mask가 각각 1/4 확률):

$$E[a] = \tfrac14(w_1x + w_2y) + \tfrac14(w_1x + 0y) + \tfrac14(0x + 0y) + \tfrac14(0x + w_2y) = \tfrac12(w_1x + w_2y)$$

  - training 때 기대값이 test 때의 **절반(= keep 확률 p배)** 이므로, **test 시에는 activation에 p를 곱해서** 스케일을 맞춤

```python
def predict(X):
    H1 = np.maximum(0, np.dot(W1, X) + b1) * p   # scale the activations
    H2 = np.maximum(0, np.dot(W2, H1) + b2) * p
    out = np.dot(W3, H2) + b3
```

- 정리: **drop in forward pass(학습) / scale at test time(추론)**
- 참고: 실제 프레임워크(PyTorch 등)는 반대로 **학습 때 p로 나눠두고(inverted dropout)** test 때는 아무것도 안 함 → test 코드를 건드리지 않아도 되는 장점

### 5-4. Data Augmentation
- **학습 데이터 자체를 랜덤하게 변형시켜가면서 학습**시킴 → 데이터를 늘리는 방법 중 하나
- 이미지를 변형해도 label은 그대로 → **왼쪽으로 앉은 고양이도 "cat"임** (Horizontal Flip)

**Random crops and scales (ResNet 예)**
- **Training**: random crop / scale 샘플링
  1. $L$을 [256, 480] 범위에서 랜덤 선택
  2. 학습 이미지의 짧은 변이 $L$이 되도록 resize
  3. 224 × 224 patch를 랜덤으로 잘라냄
- **Testing**: 고정된 crop 세트의 결과를 평균
  1. 이미지를 5개 scale {224, 256, 384, 480, 640}로 resize
  2. 각 크기마다 224 × 224 crop 10개 사용: 4 corners + center, + 각각의 flip

**Color Jitter**
- 간단한 방법: contrast와 brightness를 랜덤화
- 복잡한 방법 (AlexNet, ResNet 등):
  1. 학습 셋의 모든 [R, G, B] 픽셀에 PCA 적용
  2. principal component 방향을 따라 "color offset"을 샘플링
  3. 학습 이미지의 모든 픽셀에 offset을 더함

**문제에 맞게 창의적으로 (Get creative!)** — 다음을 랜덤하게 섞고 조합:
- translation, rotation, stretching, shearing, lens distortions, …

### 5-5. 랜덤 noise를 주는 그 외 방법들
- **DropConnect**: 뉴런이 아니라 **connection의 weight**를 랜덤하게 0으로 만듦
- **Fractional Max Pooling**: pooling할 영역을 랜덤하게 다르게 함
- **Stochastic Depth**: 학습 시 forward할 때 **어떤 layer를 랜덤하게 drop**하고 계산함 (skip connection으로 우회)

### 5-6. Regularization 방법 총정리 (시험 대비 표)

| Regularization 방법 | 내용 | Randomness 추가 방법 | Marginalize 방법 |
|---|---|---|---|
| ① Dropout | 학습 시 뉴런의 activation 값을 0으로 만듦 | "0"으로 만들 뉴런을 random 선택 | Loss 값을 계산할 때 각 학습 데이터에 대한 loss를 합산하여 평균 계산 |
| ② Batch Normalization | batch에 있는 학습 데이터에 대한 각 layer의 특정 뉴런 activation 값을 normalize | 학습할 데이터를 random 선택 (batch 구성이 매번 다름) | 〃 |
| ③ Data Augmentation | 학습 데이터를 random하게 변형하여 사용 | transform/crop parameter를 random 선택 | 〃 |
| ④ DropConnect | 학습 시 connection의 weight를 0으로 함 | "0"으로 만들 weight를 random 선택 | 〃 |
| ⑤ Fractional Max Pooling | 학습 시 pooling 영역을 서로 다르게 함 | pooling 영역을 random 결정 | 〃 |
| ⑥ Stochastic Depth | 학습 시 forward할 때 어떤 layer를 drop하고 계산 | drop할 layer를 random 결정 | 〃 |

### 5-7. Loss Space와 Skip Connection
- network가 깊어지면 loss space가 **울퉁불퉁하게 non-convex**해짐 (local minima가 폭발적으로 많아짐)
- **Skip connection**은 이런 non-convexity의 폭발을 막아줌
  - ResNet-56 (skip connection 있음): loss space가 하나의 매끈한 그릇 모양
  - ResNet-56-noshort (skip connection 없음): 뾰족한 산과 골짜기가 가득한 지형
- → skip connection이 있으면 최적화가 훨씬 쉬워짐

---

## 6. Transfer Learning (전이 학습)

### 6-1. 왜 필요한가
- "CNN을 학습/사용하려면 데이터가 많이 필요하다"
- **Overfitting이 일어나는 이유: network capacity(파라미터 수)에 비해 학습 데이터가 적기 때문**
- **Overfitting 방지 방법**: ① Regularization ② **Transfer Learning**
- 추가 이유
  - **데이터 부족**: 의료·산업 등 특정 도메인은 label된 데이터가 매우 적음 (일반 이미지 수백만 장 vs 의료 이미지 수천 장)
  - **학습 비용**: 처음부터 학습하면 대규모 데이터, 긴 학습 시간, 고비용 GPU가 필요함
- **정의**: 대규모 데이터로 학습된 **사전 학습 모델(Pre-trained model)의 지식을 새로운(목표) 작업에 전이**해서, 적은 데이터와 짧은 학습 시간으로도 높은 성능을 얻는 방법

### 6-2. 핵심 아이디어 — 층별로 학습되는 feature가 다름

```
Image → Low-Level Feature → Mid-Level Feature → High-Level Feature → Trainable Classifier
        (엣지, 색깔)        (질감, 패턴)        (물체 부분)
```

- **아래층(입력 쪽, Conv-64, Conv-128)**: **More generic** — 어떤 이미지에서든 쓸 수 있는 일반적인 특징
- **위층(출력 쪽, FC-4096, FC-1000)**: **More specific** — 학습한 task에 특화된 특징

### 6-3. CNN으로 Transfer Learning 하는 방법

1. **ImageNet으로 학습**: 전체 network (Conv … FC-4096, FC-4096, FC-1000)
2. **Small Dataset (C개 class)**: 마지막 **FC-C만 reinitialize해서 학습**, 나머지는 전부 **Freeze**
3. **Bigger dataset**: 데이터가 많을수록 **위쪽 layer를 더 많이** 학습 (예: FC 3개), 나머지는 Freeze
   - fine-tuning 시에는 **learning rate를 낮춤** → 원래 LR의 **1/10**이 좋은 시작점

| | **비슷한 dataset** (very similar) | **매우 다른 dataset** (very different) |
|---|---|---|
| **데이터 매우 적음** | 맨 위층에 Linear Classifier만 학습 | 곤란함… 여러 stage의 feature에서 linear classifier를 시도해봄 |
| **데이터 꽤 많음** | 몇 개 layer만 fine-tune | 더 많은 layer를 fine-tune |

- 예: ImageNet으로 학습된 network를 그대로 가져다 X-ray 이미지 분류에 쓰면 잘 안 됨 → 데이터 특성이 매우 다르기 때문임

### 6-4. Transfer Learning의 3가지 방식

| 방법 | 내용 | 적합한 상황 | 장점 | 단점 |
|---|---|---|---|---|
| **Feature Extraction** | 사전 학습 모델 가중치 고정, **마지막 분류층만 새로 학습** | 목표 데이터가 매우 적을 때, 빠른 프로토타입 | 빠르고 안정적, 과적합 위험 낮음 | 성능 상한이 낮음 |
| **Fine-tuning (일부 층)** | 앞쪽 층 고정, **뒤쪽 층 + 분류층을 함께 추가 학습** | 일반적인 경우 (데이터가 어느 정도 있을 때) | 성능과 안정성의 균형 | 학습할 층 선택 필요 |
| **Full Fine-tuning** | 모든 층을 사전 학습 가중치로 초기화 후 **전체를 새 데이터로 추가 학습** | 목표 데이터 충분, 도메인 차이가 클 때 | 가장 높은 성능 가능 | 과적합 위험, 시간/자원 더 필요 |

- 데이터가 적을수록 Transfer Learning이 처음부터 학습(From Scratch)하는 것보다 훨씬 높은 성능을 보임

| | 처음부터 CNN 학습 | Transfer Learning |
|---|---|---|
| Training data | 수천~수백만 장의 label된 이미지 | 수백~수천 장 (적음) |
| Computation | 연산 집약적 | 보통 수준 |
| Training time | 실제 문제 기준 며칠~몇 주 | 몇 초~몇 분 |
| 정확도 | 높음 (작은 데이터에서는 overfit 가능) | 좋음, 사전 학습 모델에 따라 다름 |

### 6-5. ImageNet 기반 Transfer Learning이 효과적인 이유
- **ImageNet**: 1000개 class 중 하나를 맞히는 분류 데이터셋
- ImageNet으로 학습된 CNN은 **1000 class 객체를 분류할 수 있는 visual feature를 추출하도록 학습되어 있기 때문에**, 이 feature를 이용한 분류기만 학습해도 다른 종류의 이미지 분류에 효과적으로 쓸 수 있음
- 실사 이미지 기반 문제들은 대부분 ImageNet으로 사전 학습된 모델을 fine-tuning 해서 씀

### 6-6. Transfer Learning은 예외가 아니라 표준임
- **Object Detection (Fast R-CNN)**: ImageNet으로 pretrain된 CNN을 backbone으로 사용
- **Image Captioning (CNN + RNN)**: 이미지 쪽은 ImageNet pretrained CNN, 단어 쪽은 **word2vec으로 pretrain된 word vector** 사용

### 6-7. 사전 학습 모델·데이터 자원
- **Hugging Face** (huggingface.co/models): 전 세계의 사전 학습된 모델들이 업로드되어 있는 사이트
- **AI Hub** (aihub.or.kr): 정부 지원으로 만든 AI 학습용 데이터를 다운로드할 수 있는 사이트

### 6-8. 교수님 코멘트 — 현재 추세
- 지금 나와 있는 AI 모델보다 더 좋은 성능의 모델을 **개인이나 일반 회사가 처음부터 만들기는 이미 늦었음**
- → **큰 모델을 가져다가 내 데이터로 fine-tuning 하는 것이 추세**
- 텍스트도 마찬가지: 인터넷상의 엄청난 양의 텍스트로 학습시켜 놓은 모델을, 내 응용 분야 데이터로 fine-tuning 해서 씀

---

## 7. Self-Supervised Learning (SSL, 자기 지도 학습) — Lecture 7

### 7-1. 왜 필요한가
- 큰 모델을 학습시키려면 학습 데이터가 엄청나게 많아야 함
- 그런데 **사람이 일일이 labeling 할 수는 없음** (대규모 데이터는 있지만 label이 거의 없고, labeling 비용이 큼)
- → **label이 없는 데이터에 스스로 label을 붙이게 할 수는 없을까?**

### 7-2. 정의
- **Self-Supervised Learning**: label이 없는 대규모 데이터에서 **스스로 학습할 수 있는 사전 과제(pretext task)를 만들어** 데이터의 구조와 의미를 학습하는 방법
- 즉, **정답을 자동으로 만들어 놓고 그 정답을 맞추도록** network를 학습시키는 것
- 특징
  - supervised data를 학습하는 것처럼 보이는 unsupervised learning
  - 일반적으로 데이터의 일부분을 발췌(또는 변형)해서, 그 부분적인 데이터로 학습시킴
  - 일반적인 loss가 아니라 **proxy(대리인) loss**를 얻어서 학습함
- 학습한 표현(representation)은 다양한 downstream 작업(분류, 검출, 검색, VQA, 텍스트 분류/생성 등)에 전이해서 사용함

| 용어 | 의미 |
|---|---|
| **Pretext task** | "핑계, 구실" — 여기서는 사용자가 정의한 새로운 문제. 진짜 목적이 아니라 좋은 feature를 얻기 위한 구실 과제 |
| **Downstream task** | 실제로 풀고 싶은 문제 (분류, 검출, segmentation 등) |
| **Representation** | encoder가 출력하는 feature vector (데이터의 표현) |

### 7-3. Generative vs Self-supervised Learning
- 공통점: 둘 다 **사람의 label 없이** 데이터로부터 학습함

| | Generative Learning (생성) | Self-supervised Learning (자기 지도) |
|---|---|---|
| 목표 | **데이터 분포 $p_{data}(x)$ 를 모델링** | downstream task에 쓸 **좋은 feature**를 만드는 pretext task를 풂 |
| 방식 | 학습한 데이터 분포(manifold)에서 sampling해서 실제 같은 데이터 생성 | 분류·회귀 같은 supervised 목적함수로 학습, pretext task의 label은 **자동 생성** |
| 1달러 지폐 비유 | 실물을 보고 그린 정밀한 지폐 그림 (픽셀 단위 디테일까지) | 기억만으로 그린 지폐 그림 (디테일은 없지만 "ONE DOLLAR, 가운데 인물" 같은 핵심 특징은 다 있음) |

- 핵심: **픽셀 단위의 디테일을 생성하는 건 대개 불필요**하고, pretext task로 **high-level semantic feature**를 배우는 게 목적임

### 7-4. Supervised vs Self-Supervised Workflow

```
[Supervised]       Images → 사람이 수동 annotation(병목) → Labels(Cat, Dog…) → (X,Y) → ConvNet → Learned Representations → Transfer
[Self-Supervised]  Images → 자동 생성 (데이터 속성 이용) → Labels(0°, 90°, 180°…) → (X,Y) → ConvNet → Learned Representations → Transfer
```

**2단계 구조**
1. **Self-supervised Pretext Task Training**: label 없는 대규모 데이터셋으로 encoder(ConvNet) 사전 학습
2. **Knowledge Transfer → Supervised Downstream Task Training**: label 있는 (적은) 데이터셋으로 downstream task 학습

**SSL 방법의 3가지 큰 분류**
- Handcrafted pretext tasks (사람이 설계한 과제: 흑백→컬러 등)
- Contrastive Learning (대조 학습)
- Clustering

### 7-5. SSL 평가 방법
- **pretext task 자체의 성능에는 관심이 없음** (회전을 완벽히 맞추는지는 중요하지 않음)
- **실제 문제인 downstream target task에서의 성능이 중요함**
- 평가 절차:
  1. 많은 unlabeled 데이터로 self-supervised learning → 좋은 **feature extractor** (예: ConvNet) 획득 (예: 회전 예측 90°)
  2. feature extractor 위에 **얕은 network(예: linear classifier)** 를 붙여서, **적은 양의 labeled 데이터**로 target task 학습 (예: "bird")
  3. target task(classification, detection 등)에서 성능 평가

### 7-6. 더 넓은 그림
- Computer vision (오늘 주제), Language modeling, Speech synthesis (WaveNet), Robot / RL 등에서 모두 사용
- **GPT-3**: pretext task = **문장에서 다음 단어 예측** → 데이터 labeling이 필요 없음 → 언어의 구문 구조 등의 특성을 학습함

---

## 8. 이미지에서의 SSL ① — 이미지 변형 기반 Pretext Tasks

| Pretext task | 방법 | label |
|---|---|---|
| **Colorization** | 흑백 이미지 → 컬러 복원 | 원본 컬러 |
| **Inpainting** | 가려진 영역 복원 | 원본 픽셀 |
| **Jigsaw Puzzle** | 섞인 patch의 순서 맞히기 | 원래 순서 |
| **Relative position** | 가운데 patch 기준으로 다른 patch의 상대 위치 맞히기 | 위치 번호 |
| **Rotation** | 회전 각도 맞히기 | 0°/90°/180°/270° |

### 8-1. Rotation Prediction (RotNet, Gidaris et al. 2018)
- **가설**: 물체가 원래 어떻게 생겨야 하는지에 대한 **"visual commonsense"** 가 있어야만 회전 각도를 맞힐 수 있음
  - → DNN 모델이 객체를 이루는 픽셀들이 어떻게 분포되어 있어야 하는지를 아는 visual commonsense를 갖도록 학습함
- 입력 이미지 전체를 0°, 90°, 180°, 270°로 회전시키고 → 어떤 회전이 적용됐는지 맞히는 **4-way classification**

**결과 ① Semi-supervised (CIFAR-10)**
- CIFAR-10 전체로 SSL 학습 → conv1 + conv2 freeze → conv3 + linear layer만 **label된 일부 데이터**로 학습
- label 데이터가 적을수록(20~1000개) SSL 방식이 순수 supervised보다 정확도가 훨씬 높음

**결과 ② Transfer (ImageNet으로 SSL → Pascal VOC 2007로 fine-tune, AlexNet)**

| 사전 학습 | Classification (%mAP, all) | Detection (%mAP) | Segmentation (%mIoU) |
|---|---|---|---|
| ImageNet labels (full supervision) | 79.9 | 56.8 | 48.0 |
| Random (사전 학습 없음) | 53.3 | 43.4 | 19.8 |
| **RotNet (회전 예측 SSL)** | **72.97** | **54.4** | **39.1** |

- → 회전 예측으로 학습하고 적은 데이터로 fine-tuning 해도 **supervised와 비슷한 성능**을 낼 수 있음

### 8-2. Jigsaw Puzzle (Noroozi & Favaro, 2016)
- 이미지를 3×3 = 9개 patch로 나누고 섞음 → 원래 순서(어떤 permutation인지)를 맞힘
- **총 permutation 개수: 9! = 362,880** → 너무 많으므로 미리 정해둔 permutation 세트(그림 기준 100개) 중 어느 것인지 분류하는 문제로 바꿈
- 각 patch는 weight를 공유(shared weights)하는 CNN에 넣고, 결과를 합쳐서 softmax로 분류

| 방법 | Pretraining time | Supervision | Classification | Detection | Segmentation |
|---|---|---|---|---|---|
| Krizhevsky (supervised) | 3 days | 1000 class labels | 78.2% | 56.8% | 48.0% |
| Doersch (relative position) | 4 weeks | context | 55.3% | 46.6% | – |
| Pathak (inpainting) | 14 hours | context | 56.5% | 44.5% | 29.7% |
| **Jigsaw** | 2.5 days | context | **67.6%** | **53.2%** | **37.6%** |

- → jigsaw로 학습해도 supervised와 비슷한 성능을 낼 수 있음

### 8-3. Inpainting (Context Encoders, Pathak et al. 2016)
- 이미지 일부를 지우고 **사라진 픽셀을 예측(복원)** 하도록 학습
- Encoder → (Channel-wise Fully Connected) → Decoder → 복원 결과와 원본의 loss 계산
- **데이터 자체를 이용해 정답을 만들어서 supervised learning을 함 → 이게 Self-Supervised Learning의 핵심**

### 8-4. Colorization / Super-resolution
- **Image Colorization**: 컬러 이미지에 grayscale filter를 적용해 학습 데이터 생성 → CNN Encoder-Decoder가 컬러를 예측 → 실제 컬러와 비교해 loss 계산
- **Image Super-resolution (SRGAN)**: 원본을 2배 작게 만들어 저해상도 입력 생성 → Generator가 고해상도 복원 → 원본과 비교 (L2 + Content Loss) + Discriminator가 진짜(1)/가짜(0) 판별
- (참고) Split-Brain Autoencoder: 입력 채널을 둘로 나눠 서로를 예측하게 하고, 두 feature($F_1$, $F_2$)를 concat해서 사용 → Places 데이터셋 transfer에서 다른 SSL 방법들보다 높은 성능 (supervised보다는 낮음)

### 8-5. 이미지 변형 기반 Pretext task의 한계
- pretext task는 rotation, inpainting, rearrangement, colorization 같은 "visual common sense"에 집중함
- pretext task를 풀기 위해 모델은 자연 이미지에 대한 좋은 feature(객체 카테고리의 semantic representation 등)를 배우게 됨
- pretext task 성능 자체가 아니라 downstream task(classification, detection, segmentation)에 얼마나 유용한지가 중요함
- **문제점**
  1. 개별 pretext task를 일일이 고안하는 게 번거로움 (tedious)
  2. 학습된 representation이 **특정 pretext task에 묶여서(tied) 일반적이지 않을 수 있음**
- → **더 일반적인 pretext task를 만들 수 없을까? → Contrastive Learning**

---

## 9. 이미지에서의 SSL ② — Contrastive Representation Learning (대조 학습)

### 9-1. 아이디어
- 같은 고양이 이미지를 가리고, 회전하고, 조각내고, 흑백으로 만든 것들은 모두 **같은 객체(same object)** → 서로 **끌어당김(attract)**
- 강아지 이미지는 **다른 객체(different object)** → **밀어냄(repel, 쫓아 버리다)**
- 즉, **Positive pair끼리는 거리를 좁히고, Negative pair끼리는 거리를 멀리 띄워 놓는 것**이 학습 원리임

**Pretext task 방식 vs Contrastive Learning**
- 공통점: label(정답)이 없는 데이터셋의 일반적인 특징을 배우는 머신러닝 기법
- 차이점: **pretext task를 구축하는 방법**
- **Contrastive Learning도 Self-Supervised Learning의 일종임**

### 9-2. 정식화 (Formulation)
- $x$: reference(anchor) 샘플, $x^+$: positive 샘플 (같은 이미지의 변형), $x^-$: negative 샘플 (다른 이미지)
- 원하는 것:

$$\text{score}(f(x), f(x^+)) \gg \text{score}(f(x), f(x^-))$$

- $f(\cdot)$: **Encoder (DNN, 특징 추출기)** — 이게 **학습 대상**임 (CNN 기반 Image Encoder)
- **score**: 두 feature vector가 얼마나 비슷한지 나타내는 값 → 비슷한 이미지면 높은 값
  - 예: **cosine similarity**, 또는 거리(MSE 등)에 마이너스를 붙인 값 (거리는 가까울수록 작으므로 부호를 뒤집어야 "비슷하면 높은 값"이 됨)
- 즉, positive pair에는 높은 score, negative pair에는 낮은 score를 내는 encoder $f$를 학습시키는 것
- 학습된 인코더는 **같은 이미지(의 변형)는 비슷한 feature vector를 생성하고, 다른 이미지는 feature space에서 거리가 먼 feature vector를 출력**함

### 9-3. Cosine Similarity

$$\text{similarity} = \cos(\theta) = \frac{A \cdot B}{\lVert A \rVert \lVert B \rVert} = \frac{\sum_{i=1}^{n} A_i B_i}{\sqrt{\sum_{i=1}^{n} A_i^2}\sqrt{\sum_{i=1}^{n} B_i^2}}$$

- 범위: $-1 \le \cos\theta \le 1$
- 두 vector 사이 각도 $\theta$가 작으면(같은 방향) 1에 가깝고, 각도가 크면 작은 수가 됨
- 예: $A = (1, 0),\ B = (1, 1)$ → $\frac{1}{1 \times \sqrt2} \approx 0.707$ (45°)

### 9-4. InfoNCE Loss — Positive 1개, Negative N−1개

$$L = -\mathbb{E}_X\left[\log \frac{\exp(s(f(x), f(x^+)))}{\exp(s(f(x), f(x^+))) + \sum_{j=1}^{N-1} \exp(s(f(x), f(x_j^-)))}\right]$$

- **분자**: positive pair의 score
- **분모**: positive score + N−1개 negative pair score의 합
- **의미**: 전체 score 합 중에서 **positive score가 차지하는 비율**을 계산함 → 하나의 샘플 이미지에 대해 하나의 positive와 여러 negative의 score를 모두 합친 뒤 positive의 비율을 계산
- **어디서 본 형태?** → **N-way softmax classifier의 Cross Entropy loss**와 같음 = **N개 샘플 중에서 positive 샘플을 찾도록 학습**하는 것
- **loss가 0이 되는 경우?** → 비율이 1, 즉 **분모 ≈ 분자** (negative score가 거의 0에 가까워서 positive가 전부를 차지할 때) → $-\log(1) = 0$
- 비율이 작을수록 $-\log(x)$가 커지므로 loss가 큼
- **Negative 샘플 개수가 많을수록(N이 클수록) 학습 정확도 성능이 좋아짐**

### 9-5. Triplet Loss — Positive 1개, Negative 1개

$$\text{Loss} = \sum_{i=1}^{N}\left[\ \underbrace{\lVert f_i^a - f_i^p \rVert_2^2}_{\text{작아지도록}} - \underbrace{\lVert f_i^a - f_i^n \rVert_2^2}_{\text{커지도록 (앞에 minus)}} + \alpha\ \right]_+$$

- $a$: anchor, $p$: positive, $n$: negative
- $[z]_+ = \max(z, 0)$ → 음수면 0 (이미 충분히 잘 분리돼 있으면 더 학습할 게 없음)
- $\alpha$: **margin** — negative가 positive보다 최소 $\alpha$만큼은 더 멀어야 함
- 같은 표현: $L_{triplet} = [d_p - d_n + \alpha]_+$ ($d_p$: anchor–positive 거리, $d_n$: anchor–negative 거리)
- **작은 숫자 예시**: $d_p = 1,\ d_n = 3,\ \alpha = 0.5$ → $1 - 3 + 0.5 = -1.5$ → loss = 0 / $d_p = 2,\ d_n = 2$ → $0.5$ → 학습 필요
- 예: 얼굴 인식 (FaceNet) — 같은 사람의 다른 사진(anchor, positive)은 가깝게, 다른 사람(negative)은 멀게
- 세 이미지 모두 **같은 weight를 공유하는 CNN**에 통과시켜 embedding을 구함
- Self-supervised 상황에서는 **특정 이미지를 여러 변형으로 바꿔가며** positive를 만들고, 아예 다른 이미지를 negative로 써서 vector 간 거리를 학습함

| | InfoNCE Loss | Triplet Loss |
|---|---|---|
| 샘플 구성 | Positive 1개, **Negative 여러 개** | Positive 1개, **Negative 1개** |
| 측정 | similarity(score)의 softmax 비율 | 거리(L2)의 차이 + margin |

### 9-6. Supervised Contrastive Learning (참고)
- (a) **Supervised Cross Entropy**: label + softmax loss로 학습
- (b) **Self-Supervised Contrastive**: data augmentation + contrastive loss로 class에 대한 representation 학습
- (c) **Supervised Contrastive**: 2단계
  - Stage 1 (pretext task): **label을 이용해** contrastive loss에 쓸 이미지를 고름 (같은 class = positive)
  - Stage 2 (fine-tuning): 학습된 representation을 freeze하고, linear layer 위에서 softmax loss로 분류기 학습
  - → label과 contrastive loss의 장점을 결합

### 9-7. SimCLR (A **Sim**ple Framework for **C**ontrastive **L**earning of Visual **R**epresentations) — Google, ICML 2020
- 저자: Ting Chen, Simon Kornblith, Mohammad Norouzi, **Geoffrey Hinton**
- **이슈**: label 없이 학습 데이터를 구축할 때, mini-batch로 학습시키면서 **negative 샘플을 어떤 방식으로 sampling하고, sampling할 데이터 set을 어떻게 유지하나?**

**구조**

```
이미지 X ─┬─ Augmentation t  → x_i → Encoder f → h_i (Representation) → Projection g → z_i ─┐
          └─ Augmentation t' → x_j → Encoder f → h_j (Representation) → Projection g → z_j ─┴─ Maximize Similarity
```

- 같은 이미지에 **서로 다른 augmentation 2개**를 적용 → 이 둘이 positive pair (attract)
- **같은 mini-batch 안의 다른 이미지들의 변형은 모두 negative** (repel) → 별도로 negative를 관리할 필요 없음
- Encoder $f$ (CNN, 예: ResNet) 뒤에 **Projection head $g$ (MLP)** 를 붙여 contrastive loss 계산
- 학습 후 **downstream task에는 projection 전의 $h$ (representation)** 를 사용함

**결과**
- **Batch size가 클수록 좋음** (256 → 8192로 갈수록 성능 향상) → 한 batch 안 negative가 많아지기 때문
- **학습 시간(epoch)이 길수록 좋음** (100 → 1000 epoch)
- 단점: negative를 많이 확보하려면 엄청 큰 batch가 필요함 → 메모리/GPU 부담

### 9-8. MoCo (Momentum Contrast) — 참고
- 핵심 가설: 좋은 feature는 **풍부한 negative 샘플을 담은 큰 dictionary**로 배울 수 있고, 동시에 dictionary key를 만드는 **encoder는 학습 중에도 최대한 일관되게** 유지돼야 함
- 이전 batch들의 feature를 **queue(dictionary)** 에 쌓아 negative로 재사용 → batch 크기와 무관하게 negative를 많이 확보
- key encoder는 momentum update(천천히 변하게)로 일관성 유지
- → SimCLR의 "큰 batch 필요" 문제를 해결하는 방향

---

## 10. NLP에서의 SSL

### 10-1. 기본 구조
- self-supervised 방법의 핵심은 **pretext task**: 데이터 자체로 label을 만들어서, unsupervised 문제를 supervised 방법으로 풂
- pretext task로 학습한 representation을 downstream supervised task의 **출발점**으로 사용함

```
Raw Text → [Pre-text task: Self-Supervised Learning] → [Downstream task: Supervised Learning]
```

- 예: "A flash flood watch will be in effect all ???" → day / **night** ✓ / hour / week / month / … / giraffe 중 맞히기
- 텍스트는 대부분 **raw text로 self-supervised 사전 학습**을 해놓고, 원하는 task 데이터로 supervised 학습(fine-tuning)을 함

### 10-2. Large Language Model과 SSL
- 텍스트에 대해 **다음 단어 맞추기, 가운데 단어 맞추기** 같은 학습을 시키다 보면 **언어의 특성이 학습됨**
- 이렇게 학습시켜 놓은 모델이 **LLM (Large Language Model)**
- LLM은 언어의 특성을 학습해 놓은 것 = "이런 단어들이 나오면 그다음 단어는 뭐다"를 **통계적으로 학습**시켜 놓은 것

### 10-3. ELMo / GPT / BERT

| 모델 | 구조 | 방향 | 특징 |
|---|---|---|---|
| **ELMo** (2018) | Bidirectional **LSTM** | 양방향 | pre-training 후 **task-specific architecture**를 따로 만들어야 함 |
| **GPT** (2018, Generative Pre-trained Transformer) | **Transformer Decoder** (masked self-attention) | **왼쪽→오른쪽 단방향** (unidirectional) | **task-agnostic** architecture + fine-tuning (구조는 최소한만 변경) |
| **BERT** (2018, Bidirectional Encoder Representations from Transformers) | **Transformer Encoder** (self-attention) | **양방향** — sequence 양쪽(과거와 미래) 정보 모두 사용 | GPT에 bidirectional 개념 추가. GPT처럼 fine-tuning을 쓰지만 **pretext task가 다름** |

- 외우기: **GPT = Decoder = 다음 단어 예측(단방향) / BERT = Encoder = 빈칸 단어 예측(양방향)**

### 10-4. NLP Pretext Task 11가지

| # | Pretext task | 방법 | 사용 모델 |
|---|---|---|---|
| ① | **Center Word Prediction** | window 안의 주변 단어로 **가운데 단어** 예측 (예: "A ___ brown" → quick) | Word2Vec **CBOW** |
| ② | **Neighbor Word Prediction** | 가운데 단어로 **주변 단어** 예측 | Word2Vec **Skip-gram** |
| ③ | **Neighbor Sentence Prediction** | 연속된 3문장에서 가운데 문장으로 **이전·다음 문장 생성** | (Skip-Thought) |
| ④ | **Auto-regressive Language Modeling** | 이전 단어들로 **다음 단어** 예측. 코퍼스에 이미 다음 단어가 있으므로 수동 label 불필요 (Nothing → is → impossible) | **GPT** |
| ⑤ | **Masked Language Modeling** | 문장의 단어를 랜덤하게 [MASK]로 가리고 예측. auto-regressive와 달리 **앞뒤 문맥을 모두** 사용 | **BERT** |
| ⑥ | **Next Sentence Prediction (NSP)** | 두 문장이 **이어지는 문장인지** 분류 (연속 문장 → yes, 다른 문서의 랜덤 문장 → no). NLI·QA 같은 문장 관계 이해 향상 목적. 이후 연구에서 효과가 의문시됨 | **BERT** |
| ⑦ | **Sentence Order Prediction (SOP)** | 연속된 두 문장이 **올바른 순서인지** 분류 (순서를 바꾼 쌍 → no) | **ALBERT** (NSP 대체) |
| ⑧ | **Sentence Permutation** | 문장들의 위치를 섞고 **원래 순서 복원** | **BART** |
| ⑨ | **Document Rotation** | 랜덤 토큰을 rotation point로 잡아 그 토큰이 맨 앞이 되도록 문서를 회전 → **원래 문서 복원**. 문서의 시작점을 식별하도록 학습 | **BART** |
| ⑩ | **Emoji Prediction** | 트윗의 이모지를 label로 써서 텍스트로 **이모지 예측**. 12억 개 트윗으로 사전 학습 후 감정 분석, 혐오 발언·모욕 탐지에 fine-tune | **DeepMoji** |
| ⑪ | **Gap Sentence Prediction** | 문서의 **중요한 문장들을 mask**하고, 빠진 문장들을 이어서 생성. **추상적 요약(abstractive summarization)** 성능 향상을 위해 설계 | (PEGASUS) |

### 10-5. 이미지 SSL ↔ 텍스트 SSL 대응

| 이미지 | 텍스트 | 공통 아이디어 |
|---|---|---|
| Inpainting, Masked Image Modeling (MAE) | Masked Language Modeling (BERT) | 가리고 복원하기 |
| Jigsaw, Relative position | Sentence Permutation, SOP | 순서/위치 맞히기 |
| Rotation prediction | Document Rotation | 변형 전 원래 상태 맞히기 |
| Contrastive (SimCLR, MoCo) | 문장 수준 대조 학습 (Sentence-BERT), 이미지-텍스트 (CLIP) | 가까운 건 가깝게, 다른 건 멀게 |

---

## 11. 데이터 양에 따른 모델 선택

- **매우 적은 데이터** → traditional ML (Random Forest, XGBoost 등)
- **그보다 조금 더 많은 데이터** → **inductive bias가 높은** 딥러닝 모델 (CNN, GNN, RNN 등)
  - inductive bias: 모델 구조에 미리 넣어둔 가정 (예: CNN은 "가까운 픽셀끼리 관련 있다", RNN은 "순서가 중요하다") → 데이터가 적어도 잘 학습됨
- **매우 많은 데이터** → **Transformer 기반 모델** (BERT, ViT, GPT 등) — 가정이 적은 대신 데이터가 많을수록 성능이 계속 올라감
- 그래프상 위치: 대부분의 개인(Most of You)은 데이터가 적은 구간, 중견 기업은 CNN 계열이 유리한 구간, 빅테크(Industry Giants)만 Transformer가 압도하는 구간에 있음
- → 그래서 개인/일반 회사는 **빅테크가 SSL로 학습시킨 대형 모델을 가져다 fine-tuning** 하는 게 현실적임

---

## 12. 예상 시험 문제

**Q1. SGD의 문제점 3가지와 각각을 해결하는 방법은?**
> ① Poor conditioning(지그재그로 느림) → Momentum / AdaGrad·RMSProp ② Local minima·Saddle point(gradient ≈ 0에서 멈추거나 매우 느림) → Momentum의 관성 ③ Mini-batch로 인한 noisy gradient → Momentum으로 smoothing

**Q2. Momentum과 Nesterov Momentum의 차이는?**
> Momentum은 현재 위치에서 gradient를 구한 뒤 velocity를 더해 이동함. Nesterov는 velocity만큼 먼저 이동한 위치(look-ahead)에서 gradient를 구해 갈 방향을 결정함 → correction term 덕분에 overshooting이 덜함.

**Q3. AdaGrad가 오래 학습하면 생기는 문제와 RMSProp의 해결책은?**
> 과거 gradient 제곱을 계속 누적하므로 분모가 커져 step size가 0에 가까워지고 학습이 멈춤. RMSProp은 누적합 대신 decay_rate를 쓴 지수이동평균으로 과거 값의 일정 비율만 반영해서 해결함.

**Q4. Adam에서 bias correction이 필요한 이유는?**
> first/second moment가 0에서 시작하므로 초기 추정값이 0쪽으로 치우쳐 너무 작음. $(1-\beta^t)$로 나눠서 초기에는 값을 키우고, t가 커지면 1로 나누는 것과 같아져 원래 moment로 진행함.

**Q5. Training error와 validation error의 gap을 줄이는 방법을 분류해서 쓰라.**
> 여러 모델: Model Ensemble (Snapshot Ensemble). 하나의 모델: Cyclic LR, Polyak Averaging, Regularization(regularization term, Dropout, Batch Normalization, Data Augmentation, DropConnect, Fractional Max Pooling, Stochastic Depth).

**Q6. Dropout이 overfitting을 막는 이유 2가지와 test 시 처리 방법은?**
> ① 특정 feature에 종속되지 않고 여러 feature에 dependency를 분산시킴(co-adaptation 방지) ② parameter를 공유하는 수많은 sub-network의 ensemble을 하나의 모델에서 학습하는 효과. Test 시에는 dropout 없이 activation에 keep 확률 p를 곱해서 학습 때의 기대값과 스케일을 맞춤.

**Q7. Regularization 방법들의 공통 패턴은?**
> Training 시 random noise(randomness)를 추가하고, Testing 시 그 noise에 대해 marginalize(평균)함.

**Q8. Overfitting이 일어나는 이유와 방지 방법 2가지는?**
> network capacity에 비해 학습 데이터 수가 적기 때문. ① Regularization ② Transfer Learning.

**Q9. ImageNet CNN을 이용한 transfer learning이 효과적인 이유는?**
> ImageNet은 1000 class 객체를 분류할 수 있는 visual feature를 추출하도록 학습되어 있어서, 이 feature를 이용한 분류기만 학습해도 다른 종류의 이미지 분류에 효과적으로 사용할 수 있음.

**Q10. 데이터 양과 데이터 유사도에 따른 transfer learning 전략은?**
> 유사+적음: 맨 위 linear classifier만 / 유사+많음: 몇 개 layer fine-tune / 다름+적음: 여러 stage feature에서 linear classifier 시도 / 다름+많음: 더 많은 layer fine-tune. Fine-tune 시 LR은 원래의 1/10 정도.

**Q11. Self-Supervised Learning이란? Pretext task와 downstream task를 설명하라.**
> label 없는 데이터에서 데이터 자체로 정답(label)을 자동 생성하는 pretext task를 만들어 학습함으로써 좋은 representation을 얻는 방법. Pretext task는 feature 학습을 위한 구실 과제(회전 예측, jigsaw, 다음 단어 예측 등)이고, downstream task는 실제로 풀고 싶은 문제(분류, 검출 등). 평가는 pretext task 성능이 아니라 downstream task 성능으로 함.

**Q12. Generative learning과 Self-supervised learning의 차이는?**
> 둘 다 label 없이 학습하지만, generative는 데이터 분포 $p_{data}(x)$를 모델링해 실제 같은 데이터를 생성하는 게 목표이고, self-supervised는 pretext task를 통해 downstream에 유용한 high-level semantic feature를 배우는 게 목표임.

**Q13. Contrastive learning의 학습 원리와 학습 대상은?**
> positive pair(같은 이미지의 변형)끼리는 feature space에서 거리를 좁히고 negative pair(다른 이미지)끼리는 멀리 띄움. 학습 대상은 이미지를 인코딩하는 encoder(DNN)의 weight임.

**Q14. InfoNCE loss의 의미와 loss가 0이 되는 조건, N을 키우면?**
> 전체 score 합 중 positive score의 비율에 $-\log$를 취한 것 = N-way softmax의 cross entropy (N개 중 positive 찾기). 분모 ≈ 분자일 때(negative score가 무시할 만큼 작을 때) 0. negative 개수 N이 클수록 성능이 좋아짐.

**Q15. InfoNCE loss와 Triplet loss의 차이는?**
> InfoNCE는 positive 1개 + negative 여러 개, similarity의 softmax 비율 사용. Triplet은 positive 1개 + negative 1개, anchor와의 L2 거리 차이에 margin α를 더한 hinge 형태.

**Q16. GPT와 BERT의 차이는?**
> GPT는 Transformer decoder(masked self-attention) 기반의 단방향(왼→오) 모델로 auto-regressive LM(다음 단어 예측)으로 사전 학습함. BERT는 Transformer encoder(self-attention) 기반의 양방향 모델로 Masked LM(+NSP)으로 사전 학습함.

---

## 13. 자기 점검 체크리스트

**Optimization**
- [ ] loss space가 무엇이고 무엇에 의해 결정되는지 설명할 수 있다
- [ ] gradient descent 식에서 minus를 붙이는 이유를 안다
- [ ] Batch / Mini-batch / SGD의 차이를 안다
- [ ] Poor conditioning에서 지그재그가 생기는 이유를 뉴런 예시로 설명할 수 있다
- [ ] Local minima와 saddle point의 차이, 고차원에서 saddle point가 흔하다는 것을 안다
- [ ] Momentum 식과 ρ(friction)의 의미를 설명할 수 있다
- [ ] Nesterov가 momentum과 어떻게 다른지(look-ahead) 설명할 수 있다
- [ ] AdaGrad의 element-wise scaling과 step size 감소 문제를 설명할 수 있다
- [ ] RMSProp이 AdaGrad를 어떻게 개선했는지 안다
- [ ] Adam = Momentum + RMSProp, bias correction 이유, 기본 hyperparameter를 안다
- [ ] "절대값 기반 vs 상대값(비율) 기반" 두 계열로 알고리즘을 분류할 수 있다

**Regularization**
- [ ] Early stopping 시점(validation loss가 다시 증가)을 안다
- [ ] Model ensemble, snapshot ensemble, cyclic LR, Polyak averaging을 설명할 수 있다
- [ ] L2(weight decay) / L1 / Elastic net 식을 쓸 수 있다
- [ ] Regularization 공통 패턴(train: noise 추가 / test: marginalize)을 안다
- [ ] Dropout의 동작, 효과 2가지, test time scaling 이유를 계산 예시로 설명할 수 있다
- [ ] Data augmentation 종류(flip, crop/scale, color jitter 등)를 안다
- [ ] Regularization 6가지 방법 표(randomness 추가 방법)를 채울 수 있다
- [ ] Skip connection이 loss space에 미치는 영향을 안다

**Transfer Learning**
- [ ] Overfitting 원인과 방지 방법 2가지를 안다
- [ ] 아래층(generic) / 위층(specific) 차이를 안다
- [ ] 데이터 양 × 유사도 2×2 전략표를 채울 수 있다
- [ ] Feature extraction / Fine-tuning / Full fine-tuning을 구분할 수 있다
- [ ] ImageNet 기반 transfer learning이 효과적인 이유를 쓸 수 있다

**Self-Supervised Learning**
- [ ] SSL의 정의, pretext task / downstream task의 의미를 안다
- [ ] Generative vs Self-supervised 차이를 설명할 수 있다
- [ ] SSL 평가 방법(linear classifier on frozen feature)을 안다
- [ ] Rotation, Jigsaw(9! permutation), Inpainting, Colorization pretext task를 설명할 수 있다
- [ ] 이미지 변형 기반 pretext task의 한계 2가지를 안다
- [ ] Contrastive learning 원리와 학습 대상(encoder)을 설명할 수 있다
- [ ] InfoNCE loss 식의 의미, loss = 0 조건, N의 영향을 안다
- [ ] Triplet loss 식과 margin α의 역할을 안다
- [ ] SimCLR 구조(augmentation 2개, encoder, projection head)와 batch size 영향을 안다
- [ ] ELMo / GPT / BERT 차이(구조, 방향)를 안다
- [ ] NLP pretext task 11가지와 사용 모델을 연결할 수 있다
- [ ] 데이터 양에 따른 모델 선택(ML → CNN/RNN → Transformer)과 inductive bias를 설명할 수 있다