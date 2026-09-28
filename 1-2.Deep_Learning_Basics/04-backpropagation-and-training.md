# 딥러닝 기초 4주차 — Backpropagation & Training Neural Networks (Part 1)

> 과목: 딥러닝 기초 (낭종호 교수) / 2026-2학기
> 범위: Lecture 4 *Backpropagation and Neural Networks* (전체) + Lecture 5 *Training Neural Networks, Part 1* (전체)
> 참고 교재: Stanford CS231n (2017) Lecture 4, Lecture 6

---

# Part A. Lecture 4 — Backpropagation and Neural Networks

## 1. 지금까지의 흐름 (Where we are)

| 식 | 의미 |
|---|---|
| $s = f(x; W) = Wx$ | score function (linear classifier) |
| $L_i = \sum_{j \ne y_i} \max(0,\ s_j - s_{y_i} + 1)$ | SVM (hinge) loss |
| $L = \frac{1}{N}\sum_{i=1}^{N} L_i + \sum_k W_k^2$ | data loss + L2 regularization |
| want $\nabla_W L$ | 목표: loss를 W에 대해 미분한 gradient를 구하는 것 |

- **Backpropagation**: chain rule을 재귀적으로(recursive) 적용해서 **식(expression)의 gradient를 계산하는 방법**이다.
- $\nabla f(x)$: 각 변수에 대해 함수가 **얼마나 빠르게 변하는지(rate of change)** 를 나타냄
  - 각 변수에 대한 도함수(derivative)는 **그 변수 값에 대해 전체 식이 얼마나 민감한지(sensitivity)** 를 알려줌
- 기호 읽는 법
  - $\nabla$ : **nabla** (나블라) — gradient 기호
  - $\partial$ : **del** (또는 partial) — 편미분 기호. $\frac{\partial z}{\partial x}$는 "partial derivative of z with respect to x"

### 1-1. Gradient 계산 방법 두 가지

$$\frac{df(x)}{dx} = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$$

| 방법 | 속도 | 정확도 | 구현 |
|---|---|---|---|
| **Numerical gradient** (h를 작게 잡고 직접 계산) | 느림 | 근사값 | 쉬움 |
| **Analytic gradient** (미분 공식으로 유도) | 빠름 | 정확 | 실수하기 쉬움 (error-prone) |

- **실전**: analytic gradient로 구현하고, numerical gradient로 구현이 맞는지 검증함 → **gradient check**
- Vanilla Gradient Descent

```python
while True:
    weights_grad = evaluate_gradient(loss_fun, data, weights)
    weights += - step_size * weights_grad   # parameter update
```

---

## 2. Linear Classifier → Neural Network

| | 식 | 구조 |
|---|---|---|
| (Before) Linear score function | $f = Wx$ | x → s |
| (Now) 2-layer Neural Network | $f = W_2 \max(0, W_1 x)$ | x(3072) → h(100) → s(10) |

- CIFAR-10 기준: 입력 x는 32×32×3 = **3072차원**, hidden h는 **100개**, 출력 s는 클래스 **10개**
- **h**: 100개의 template에 대한 **intermediate score**임
  - 입력 이미지가 중간 template 100개 각각과 얼마나 잘 match되는지를 나타내는 값
- **W2**: 이 100개의 score를 **weighted sum**해서 최종 class score를 만듦
- W1의 각 행은 이미지처럼 시각화해 볼 수 있음(visible), W2는 보통 시각적으로 해석하기 어려움(non-visible)
- 핵심: **simple한 function을 여러 개 stacking해서 더 복잡한 non-linear function을 만든다** (multiple stages of hierarchical computation with non-linearity between them)

### 2-1. max(비선형 함수)가 없으면?

$$W_2 \times (W_1 \times x) = (W_2 W_1) x = W' x$$

- 두 행렬의 곱은 **하나의 행렬로 합쳐짐** → 층을 아무리 많이 쌓아도 결국 **linear function 하나**와 같음
- 그래서 층과 층 사이에 반드시 **non-linear activation function**이 있어야 층을 쌓는 의미가 생김

---

## 3. 왜 비선형 활성화 함수와 여러 층(Deep)이 필요한가

### 3-1. 표현력의 차이

| 구조 | 만들 수 있는 결정 경계 | 한계 |
|---|---|---|
| 선형 단일층 | 직선(초평면)만 가능 | XOR처럼 직선으로 나눌 수 없는 문제를 못 풂 |
| 비선형 활성화 + 은닉층 1개 | 곡선 경계 가능 | 아주 복잡한 형태는 여전히 어려움 |
| 은닉층 2개 이상 | 여러 곡선을 조합한 복잡한 경계 | — |
| 더 많은 층 | 아주 복잡하고 비선형적인 경계까지 표현 | — |

### 3-2. 층이 하는 일 — 공간의 변형

- 각 층은 데이터를 **조금씩 변형(transform)** 시킴
- 원래 입력 공간에서는 섞여 있던 데이터(예: 동심원 형태)가 층을 지날 때마다 변형되어, **마지막 층에서는 linear classifier만으로도 분리 가능한 형태**가 됨
- 입력 패턴 자체가 단순하면 얕은 구조로도 충분하지만, 복잡한 패턴은 여러 층의 변형이 필요함

### 3-3. 계층적 특징 추출 (Hierarchical feature)

| 층 | 학습하는 특징 | 예 (고양이 이미지) |
|---|---|---|
| 낮은 층 | 간단한 패턴 | 선, 모서리, 밝기 변화 |
| 중간 층 | 조합된 패턴 | 눈, 귀, 털 질감 |
| 높은 층 | 추상적인 개념 | "고양이"라는 전체 형태 |

- 여러 층은 복잡한 문제를 **단계적으로 분해**해서 해결하는 역할을 함

### 3-4. 역사적 배경

- **여러 층을 쌓자는 아이디어는 1960년대에 이미 나왔음**
- 하지만 층을 여러 개 뒀을 때 **어떻게 학습시킬 것인가**가 해결되지 않아 발전이 멈춤
- 1980~90년대에 backpropagation으로 multi-layer network를 학습시키려 했지만, activation function으로 **sigmoid**를 쓰면서 층이 깊어지면 앞쪽 층이 학습되지 않는 문제(**vanishing gradient**)에 막힘 → 5장 참고
- **2012년(AlexNet) 이후** ReLU, 좋은 초기화, Batch Normalization 등 **층을 깊게 쌓아도 학습이 되는 기법들**이 개발되면서 deep neural network가 널리 쓰이기 시작함

> 실습 도구: TensorFlow Playground (https://playground.tensorflow.org/) — 층 수, 뉴런 수, activation, learning rate 등을 바꿔 가며 결정 경계가 어떻게 만들어지는지 직접 확인할 수 있음

---

## 4. 2-layer Neural Network 전체 구현 (NumPy)

```python
import numpy as np
from numpy.random import randn

N, D_in, H, D_out = 64, 1000, 100, 10
x, y = randn(N, D_in), randn(N, D_out)
w1, w2 = randn(D_in, H), randn(H, D_out)

for t in range(2000):
    # Forward pass
    h = 1 / (1 + np.exp(-x.dot(w1)))      # hidden: sigmoid
    y_pred = h.dot(w2)                    # output: activation 없음
    loss = np.square(y_pred - y).sum()    # loss = Σ(pred_y - y)²
    print(t, loss)

    # Backward pass
    grad_y_pred = 2.0 * (y_pred - y)
    grad_w2 = h.T.dot(grad_y_pred)
    grad_h  = grad_y_pred.dot(w2.T)
    grad_w1 = x.T.dot(grad_h * h * (1 - h))   # sigmoid 미분 = h(1-h)

    # Update (learning rate = 1e-4)
    w1 -= 1e-4 * grad_w1
    w2 -= 1e-4 * grad_w2
```

### 4-1. 행렬 크기

| 변수 | shape | 의미 |
|---|---|---|
| x | 64 × 1000 | batch size 64, 입력 차원 1000 |
| w1 | 1000 × 100 | |
| h | 64 × 100 | hidden 뉴런 100개 |
| w2 | 100 × 10 | |
| y_pred, y | 64 × 10 | 출력 10차원 |

- **Output layer에는 activation function이 없음** (regression 형태의 L2 loss 사용)

### 4-2. Backward 각 줄의 의미

| 코드 | 유도 |
|---|---|
| `grad_y_pred = 2.0*(y_pred - y)` | $\frac{\partial}{\partial \hat y}(\hat y - y)^2 = 2(\hat y - y)$ |
| `grad_w2 = h.T.dot(grad_y_pred)` | $\hat y = h W_2$ → $\frac{\partial L}{\partial W_2} = h^T \frac{\partial L}{\partial \hat y}$ |
| `grad_h = grad_y_pred.dot(w2.T)` | $\frac{\partial L}{\partial h} = \frac{\partial L}{\partial \hat y} W_2^T$ (h로 gradient 전달) |
| `grad_w1 = x.T.dot(grad_h*h*(1-h))` | sigmoid 통과: $\sigma' = h(1-h)$를 원소별로 곱한 뒤 $x^T$와 곱함 |

### 4-3. 생각해 볼 질문

**Q1. Batch size가 2배(64 → 128)로 커지면 저장 용량은 얼마나 늘어나나?**
- 한 번에 메모리에 올려야 하는 값: x, h, y (activation)
  - batch 64: $64 \times 1000 + 64 \times 100 + 64 \times 10 = 64 \times 1110 = 71{,}040$개
  - batch 128: $128 \times 1110 = 142{,}080$개 → **activation 저장 용량은 batch size에 비례해서 2배**가 됨
- 반면 **weight(w1: 1000×100, w2: 100×10 = 101,000개)는 batch size와 무관**하게 그대로임

**Q2. 어떤 w는 batch 안의 64개 입력 각각에 대해 Δw가 만들어진다. 어떻게 update하나?**
- `x.T.dot(...)`의 행렬곱이 **64개 sample에서 나온 Δw를 모두 더해 줌**
- 위 코드는 loss를 합(sum)으로 정의했기 때문에 gradient도 합이 됨
- 보통은 loss를 $\frac{1}{N}\sum$ (평균)으로 정의하므로 gradient도 **batch 평균(average)** 이 됨 → 평균을 쓰면 batch size가 바뀌어도 learning rate를 크게 바꾸지 않아도 됨

---

## 5. Neuron 모델과 Activation Function

### 5-1. 생물학적 뉴런과의 대응

| 생물학적 뉴런 | 인공 뉴런 |
|---|---|
| dendrite (입력 신호 수신) | 입력 $x_i$ |
| synapse (연결 강도) | weight $w_i$ |
| cell body (신호 합산) | $\sum_i w_i x_i + b$ |
| axon (출력) | $f(\sum_i w_i x_i + b)$ |

- $f$가 **activation function**이며, **non-linearity를 주기 위해** 사용함
- 예: 입력 (22, 0, +1)에 weight를 곱해 더한 값이 −0.49 → $\sigma(-0.49) \approx 0.38$ → "생존 확률 38%" 같은 식으로 출력을 해석할 수 있음

### 5-2. 주요 Activation Function

| 이름 | 식 | 출력 범위 |
|---|---|---|
| Sigmoid | $\sigma(x) = \frac{1}{1+e^{-x}}$ | (0, 1) |
| tanh | $\tanh(x)$ | (−1, 1) |
| ReLU | $\max(0, x)$ | [0, ∞) |
| Leaky ReLU | $\max(0.1x, x)$ (보통 0.01x도 사용) | (−∞, ∞) |
| Maxout | $\max(w_1^T x + b_1,\ w_2^T x + b_2)$ | (−∞, ∞) |
| ELU | $x\ (x \ge 0)$, $\alpha(e^x - 1)\ (x < 0)$ | (−α, ∞) |

- 각 함수의 장단점은 Part B 1장에서 자세히 다룸

### 5-3. Feed-forward 계산 (3-layer NN)

```python
f = lambda x: 1.0/(1.0 + np.exp(-x))   # activation: sigmoid
x  = np.random.randn(3, 1)              # 입력 (3x1)
h1 = f(np.dot(W1, x) + b1)              # hidden layer 1 (4x1)
h2 = f(np.dot(W2, h1) + b2)             # hidden layer 2 (4x1)
out = np.dot(W3, h2) + b3               # output (1x1)
```

- **인접한 layer의 뉴런들끼리만 연결**되어 있음 → 행렬곱(matrix multiplication)으로 한 번에 계산 가능
- **같은 layer 안의 뉴런들끼리는 연결되지 않음**

**Summary**
- 뉴런을 **fully-connected layer** 단위로 배치함
- layer라는 추상화 덕분에 **vectorized code(행렬곱)** 로 효율적으로 계산할 수 있음
- Neural network는 이름과 달리 실제 뇌와 같지는 않음 (not really *neural*)

---

## 6. Backpropagation — 다층 신경망의 학습

### 6-1. 왜 Backpropagation이 필요한가

- 학습의 목표: **입력이 들어왔을 때 원하는 출력이 나오도록 하는 W 세트를 구하는 것**
- 입력 → 출력을 계산하고, 출력과 정답의 차이를 계산한 것이 **loss**
- loss가 작아지는 방향으로 W를 고쳐야 하는데:

| 가중치 | 오류와의 관계 | gradient 계산 |
|---|---|---|
| **출력층과 직접 연결된 W** (예: $w_6, w_7$) | 출력 오류 $\delta = \hat y - y$에 직접 영향 | 바로 계산 가능 |
| **직접 연결되지 않은 W** (예: 입력층의 $w_1$) | 은닉층 1 → 은닉층 2 → … → 출력층까지 여러 경로를 거쳐 영향 | 한 번에 알 수 없음 |

- 직접 연결되지 않은 W에 대한 오류는 **뒤(출력층)에서부터 간접적으로 전달받아** 계산해야 함 → 이것이 **backpropagation(역전파)**
- Backpropagation = **출력 뉴런과 직접 연결되어 있지 않은 weight(connection)에 대한 loss gradient 계산 방법**

### 6-2. 기본 아이디어 — "책임 분배"

- 회사에 손실이 났을 때, **최종 결과의 문제를 각 부서와 담당자의 영향 정도에 따라 거꾸로 추적**하는 것과 같음
- 손실에 **가장 영향을 많이 미친(책임이 큰) 가중치는 많이 바꾸고**, 영향이 작은 가중치는 조금만 바꿈
- 모든 가중치를 똑같이 바꾸는 것이 아니라, **각 가중치가 오류에 미친 영향(gradient)만큼** 조정함

### 6-3. 다층 신경망 학습의 전체 과정

**① 모델 구조**: 각 층의 계산

$$z^{(l)} = W^{(l)} a^{(l-1)} + b^{(l)}, \qquad a^{(l)} = \varphi(z^{(l)}), \qquad a^{(0)} = x,\ a^{(L)} = \hat y$$

**② Forward pass (순전파)**: 입력 x를 네트워크에 통과시켜 예측값 $\hat y$ 계산

**③ Loss 계산**: 예측값과 정답의 차이
- 분류 문제: Softmax + Cross-Entropy, $L = -\sum_{k=1}^{m} y_k \log(\hat y_k)$ ($y$: one-hot 정답, $\hat y$: softmax 확률)
- 그 외 SVM loss, L2 loss 등 사용

**④ Backward pass (역전파)**: loss의 gradient를 출력층 → 입력층 방향으로 chain rule을 이용해 계산

$$\delta^{(l)} = \frac{\partial L}{\partial z^{(l)}} = \left(W^{(l+1)}\right)^T \delta^{(l+1)} \odot \varphi'(z^{(l)})$$

$$\frac{\partial L}{\partial W^{(l)}} = \delta^{(l)} \left(a^{(l-1)}\right)^T, \qquad \frac{\partial L}{\partial b^{(l)}} = \delta^{(l)}$$

- $\left(W^{(l+1)}\right)^T \delta^{(l+1)}$: 다음 층에서 전달된 gradient
- $\varphi'(z^{(l)})$: 활성화 함수의 미분
- $\odot$: 원소별 곱 (Hadamard product)

**⑤ Weight update (경사하강법)**

$$W^{(l)} \leftarrow W^{(l)} - \eta \frac{\partial L}{\partial W^{(l)}}, \qquad b^{(l)} \leftarrow b^{(l)} - \eta \frac{\partial L}{\partial b^{(l)}}$$

- 새로운 가중치 = 기존 가중치 − **학습률(η)** × **기울기**
  - 기울기의 **반대 방향**으로 이동 → loss가 줄어드는 방향
  - 학습률: 얼마나 크게 수정할지 결정 (예: 0.01)
  - 기울기: 이 가중치가 loss에 얼마나 영향을 주었는지

**⑥ 반복**: mini-batch 단위로 순전파 → loss → 역전파 → 업데이트를 여러 epoch 동안 반복하면 loss가 점점 줄어듦 (예: 처음엔 $\hat y = 0.3$ → 나중엔 $\hat y = 0.98$로 정답에 가까워짐)

- Softmax loss나 SVM loss 등으로 loss를 계산하고, 이것이 작아지는 방향으로 backpropagation하며 update를 계속 반복하는 것이 **학습(training)** 임
- 학습 데이터 전체를 한 번만이 아니라 여러 번(예: 100 epoch) 반복해서 보여줘야 **평균적으로 loss가 작아지는 W 세트**를 구할 수 있음

---

## 7. Backpropagation 수치 예제 (가중치 update 계산)

### 7-1. 문제 설정

- 입력 $x = 1.0$, 정답 $y = 0$
- 은닉층 뉴런 2개($h_1, h_2$), 출력층 뉴런 1개
- 활성화 함수: sigmoid $\sigma(z)$ (은닉층, 출력층 모두)
- 손실 함수: $L = \frac{1}{2}(\hat y - y)^2$
- 초기 가중치: $w_1 = 0.5,\ w_2 = -0.4$ (입력→은닉), $w_3 = 0.7,\ w_4 = 0.2$ (은닉→출력), bias 없음
- 학습률 $\eta = 0.1$

```
         w1=0.5 → (h1) ─ w3=0.7 ─┐
x=1.0 ─┤                          ├→ (ŷ)
         w2=-0.4 → (h2) ─ w4=0.2 ─┘
```

### 7-2. 순전파

| 계산 | 값 |
|---|---|
| $h_1 = \sigma(0.5 \times 1.0) = \sigma(0.5)$ | 0.622 |
| $h_2 = \sigma(-0.4 \times 1.0) = \sigma(-0.4)$ | 0.401 |
| $z_{out} = 0.7 \times 0.622 + 0.2 \times 0.401$ | 0.516 |
| $\hat y = \sigma(0.516)$ | **0.626** |
| $L = \frac{1}{2}(0.626 - 0)^2$ | **0.196** |

### 7-3. 역전파 — 출력층에서 시작해 오류를 나누어 전달

**① 출력층의 오류 신호**

$$\delta_{out} = \frac{\partial L}{\partial z_{out}} = (\hat y - y)\cdot \hat y(1 - \hat y) = 0.626 \times 0.626 \times 0.374 = 0.147$$

**② 은닉층으로 오류 전달** — 각 은닉 노드는 자신이 출력에 미친 영향(w × 활성화 함수의 기울기)만큼 오류를 받음

$$\delta_{h_1} = (w_3 \cdot \delta_{out}) \cdot h_1(1 - h_1) = 0.7 \times 0.147 \times 0.622 \times 0.378 = 0.024$$
$$\delta_{h_2} = (w_4 \cdot \delta_{out}) \cdot h_2(1 - h_2) = 0.2 \times 0.147 \times 0.401 \times 0.599 = 0.007$$

**③ 각 가중치의 기울기 (책임 분담)**

| 가중치 | 기울기 식 | 값 |
|---|---|---|
| $w_3$ | $\delta_{out} \times h_1 = 0.147 \times 0.622$ | 0.091 |
| $w_4$ | $\delta_{out} \times h_2 = 0.147 \times 0.401$ | 0.059 |
| $w_1$ | $\delta_{h_1} \times x = 0.024 \times 1.0$ | 0.024 |
| $w_2$ | $\delta_{h_2} \times x = 0.007 \times 1.0$ | 0.007 |

### 7-4. 가중치 업데이트 ($w_{new} = w_{old} - \eta \frac{\partial L}{\partial w}$)

| 가중치 | 업데이트 | 새로운 값 |
|---|---|---|
| $w_1$ | $0.5 - 0.1 \times 0.024$ | 0.4976 |
| $w_2$ | $-0.4 - 0.1 \times 0.007$ | −0.4007 |
| $w_3$ | $0.7 - 0.1 \times 0.091$ | 0.6909 |
| $w_4$ | $0.2 - 0.1 \times 0.059$ | 0.1941 |

### 7-5. 결과 확인

- 업데이트된 가중치로 다시 순전파하면 $\hat y_{new} \approx 0.624$ (이전 0.626 → 정답 0 쪽으로 감소)
- 한 번의 update로 변화량은 작지만, 이를 반복하면 loss가 점점 줄어듦
- **관찰 포인트**
  - 출력 오류 0.147이 각 연결의 영향도(w)와 활성화 함수의 기울기에 따라 은닉층으로 나뉘어 전달됨
  - $w_3$(0.7)가 $w_4$(0.2)보다 크므로 $h_1$ 쪽이 더 큰 오류(0.024 > 0.007)를 받음 → **출력에 더 큰 영향을 준 연결일수록 더 크게 조정됨**
  - 입력층 쪽 가중치($w_1, w_2$)의 기울기가 출력층 쪽($w_3, w_4$)보다 작음 → sigmoid 미분(최대 0.25)이 곱해지면서 앞쪽으로 갈수록 기울기가 작아지는 **vanishing gradient의 예고편**

---

## 8. Computational Graph

- **Node**: 연산(computation)
- **Edge**: 데이터 흐름(data flow)
- Computational graph로 표현하면 **임의의 식(expression)에 대해 gradient를 구할 수 있음**
  - Linear classifier: $x, W \to (*) \to s \to$ hinge loss $\to (+) \leftarrow R(W)$ $\to L$
  - AlexNet 같은 복잡한 CNN도 input image → weights → loss로 이어지는 하나의 거대한 computational graph임

### 8-1. 간단한 예제: $f(x, y, z) = (x + y)z$

- 입력: $x = -2,\ y = 5,\ z = -4$
- 중간 변수: $q = x + y$, $f = qz$

| 순전파 | 값 |
|---|---|
| $q = x + y$ | 3 |
| $f = q \cdot z$ | −12 |

| 국소 미분 (local gradient) |
|---|
| $\frac{\partial q}{\partial x} = 1,\ \frac{\partial q}{\partial y} = 1$ |
| $\frac{\partial f}{\partial q} = z,\ \frac{\partial f}{\partial z} = q$ |

| 역전파 (chain rule) | 값 |
|---|---|
| $\frac{\partial f}{\partial f}$ | 1 |
| $\frac{\partial f}{\partial z} = q$ | 3 |
| $\frac{\partial f}{\partial q} = z$ | −4 |
| $\frac{\partial f}{\partial x} = \frac{\partial f}{\partial q}\frac{\partial q}{\partial x} = -4 \times 1$ | −4 |
| $\frac{\partial f}{\partial y} = \frac{\partial f}{\partial q}\frac{\partial q}{\partial y} = -4 \times 1$ | −4 |

- **의미**: $\frac{\partial f}{\partial x} = -4$ → 현재 입력값에서 **x가 1 증가하면 f는 −4(z의 값)의 비율로 변함**. 즉 x, y, z가 변할 때 f가 어떤 비율로 변하는지를 알려주는 것이 편미분임

### 8-2. Local gradient × Upstream gradient

노드 $f$가 입력 $x, y$를 받아 $z$를 출력할 때:

$$\underbrace{\frac{\partial L}{\partial x}}_{\text{downstream}} = \underbrace{\frac{\partial L}{\partial z}}_{\text{upstream gradient}} \cdot \underbrace{\frac{\partial z}{\partial x}}_{\text{local gradient}}$$

- **Upstream gradient** $\frac{\partial L}{\partial z}$: 뒤(출력 쪽)에서 전달되어 온 gradient
- **Local gradient** $\frac{\partial z}{\partial x}$: 이 노드 자체의 입력에 대한 미분. 입력이 어떻게 계산되었는지(노드의 수식)만 알면 구할 수 있음
- 각 노드는 **자기 local gradient만 알면 되고**, 받은 upstream gradient에 곱해서 앞쪽으로 넘겨주기만 하면 됨 → 아무리 복잡한 네트워크도 단순한 노드들의 반복으로 gradient를 계산할 수 있음

### 8-3. Sigmoid 뉴런 예제

$$f(w, x) = \frac{1}{1 + e^{-(w_0 x_0 + w_1 x_1 + w_2)}}$$

- 입력: $w_0 = 2,\ x_0 = -1,\ w_1 = -3,\ x_1 = -2,\ w_2 = -3$

**자주 쓰는 도함수**

| 함수 | 도함수 |
|---|---|
| $f(x) = e^x$ | $\frac{df}{dx} = e^x$ |
| $f_a(x) = ax$ | $\frac{df}{dx} = a$ |
| $f(x) = \frac{1}{x}$ | $\frac{df}{dx} = -\frac{1}{x^2}$ |
| $f_c(x) = c + x$ | $\frac{df}{dx} = 1$ |

**순전파 / 역전파 값** (뒤에서부터 계산)

| 노드 | 순전파 출력 | 역전파 gradient | 계산 (local × upstream) |
|---|---|---|---|
| $1/x$ | 0.73 | 1.00 | 시작점 |
| $+1$ | 1.37 | −0.53 | $-\frac{1}{1.37^2} \times 1.00$ |
| $\exp$ | 0.37 | −0.53 | $1 \times (-0.53)$ |
| $\times(-1)$ | −1.00 | −0.20 | $e^{-1} \times (-0.53) = 0.37 \times (-0.53)$ |
| $+$ (최종 합) | 1.00 | 0.20 | $-1 \times (-0.20)$ |
| $w_0 x_0$ | −2.00 | 0.20 | add gate는 그대로 전달 |
| $w_1 x_1$ | 6.00 | 0.20 | |
| $w_2$ | −3.00 | 0.20 | |

**곱셈 노드의 입력별 gradient**

| 변수 | gradient | 계산 |
|---|---|---|
| $w_0$ | −0.20 | $x_0 \times 0.2 = -1 \times 0.2$ |
| $x_0$ | 0.40 | $w_0 \times 0.2 = 2 \times 0.2$ |
| $w_1$ | −0.40 | $x_1 \times 0.2 = -2 \times 0.2$ |
| $x_1$ | −0.60 | $w_1 \times 0.2 = -3 \times 0.2$ |
| $w_2$ | 0.20 | |

- **$w$에 대한 gradient**: W를 update하는 데 사용함
- **$x$에 대한 gradient**: 아래(앞쪽) node의 gradient를 구하는 데 사용함 (x가 이전 뉴런의 출력이라면 그 뉴런으로 계속 전달됨)

### 8-4. Sigmoid gate — 노드를 묶어서 한 번에 미분

$$\sigma(x) = \frac{1}{1+e^{-x}}$$

$$\frac{d\sigma(x)}{dx} = \frac{e^{-x}}{(1+e^{-x})^2} = \left(\frac{1 + e^{-x} - 1}{1+e^{-x}}\right)\left(\frac{1}{1+e^{-x}}\right) = \big(1 - \sigma(x)\big)\sigma(x)$$

- $\times(-1) \to \exp \to +1 \to 1/x$ 네 개의 노드를 **sigmoid gate 하나로 grouping**하고 직접 미분하면 한 번에 계산 가능
- 예제: $\sigma(1) = 0.73$ → $(0.73)(1 - 0.73) = 0.2$ → 네 노드를 하나씩 거쳐 구한 값(0.20)과 같음
- 즉 **가장 간단한 node들과 chain rule로 gradient를 구할 수도 있고, 간단한 node들을 grouping해서 그 group을 직접 미분할 수도 있음**

### 8-5. Backward flow의 패턴

예제: $x = 3,\ y = -4,\ z = 2,\ w = -1$, $f = 2\left(xy + \max(z, w)\right)$

| 노드 | 순전파 | 역전파 |
|---|---|---|
| $xy$ | −12 | 2.00 |
| $\max(z, w)$ | 2 | 2.00 |
| $+$ | −10 | 2.00 |
| $\times 2$ | −20 | 1.00 |
| $x$ | 3 | −8 ($= y \times 2$) |
| $y$ | −4 | 6 ($= x \times 2$) |
| $z$ | 2 | 2 (max로 선택됨) |
| $w$ | −1 | 0 (선택되지 않음) |

| Gate | 역할 | 동작 |
|---|---|---|
| **add gate** | gradient **distributor** | upstream gradient를 모든 입력에 **그대로 똑같이 분배** |
| **max gate** | gradient **router** | 최댓값으로 선택된 입력에만 gradient를 전달, 나머지는 0 |
| **mul gate** | gradient **switcher** | 입력 x의 gradient = (다른 입력 y) × upstream. 서로 **값을 바꿔서** 곱함 |

### 8-6. Gradients add at branches

- 한 노드 $f$의 출력이 **여러 노드($g_1, g_2$)로 연결**되는 경우, $f$의 upstream gradient는 **양쪽에서 오는 gradient를 합함**
- 이유: x가 양쪽 모두에 영향을 미쳤기 때문임

$$\frac{\partial f}{\partial x} = \sum_i \frac{\partial f}{\partial g_i} \times \frac{\partial g_i}{\partial x}$$

- 지금까지는 x가 scalar인 경우였고, x가 vector인 경우에는 gradient가 **Jacobian 행렬**이 됨 (다음 강의에서 확장)

### 8-7. Summary

- Neural net은 매우 크기 때문에 **모든 파라미터의 gradient 공식을 손으로 쓰는 것은 비현실적**임
- **Backpropagation** = computational graph를 따라 **chain rule을 재귀적으로 적용**해서 모든 입력/파라미터/중간값의 gradient를 계산하는 것
- 구현은 그래프 구조를 유지하며, 각 노드는 **forward() / backward() API**를 구현함
  - **forward**: 연산 결과를 계산하고, **gradient 계산에 필요한 중간값을 메모리에 저장**함
  - **backward**: chain rule을 적용해 loss의 입력에 대한 gradient를 계산함
- 이것이 PyTorch, TensorFlow 같은 프레임워크의 자동 미분(autograd)이 동작하는 원리임

---

# Part B. Lecture 5 — Training Neural Networks, Part 1

## 0. 개요

### 0-1. Mini-batch SGD

Loop:
1. 데이터에서 **batch를 sampling**함
2. 그래프(네트워크)에 **forward** prop해서 loss를 구함
3. **backprop**으로 gradient를 계산함
4. gradient를 이용해 파라미터를 **update**함

### 0-2. 신경망 학습에서 다룰 것

| 단계 | 내용 |
|---|---|
| 1. One time setup | activation functions, preprocessing, weight initialization, regularization, gradient checking |
| 2. Training dynamics | babysitting the learning process, parameter updates, hyperparameter optimization |
| 3. Evaluation | model ensembles |

**Part 1 범위**: Activation Functions → Data Preprocessing → Weight Initialization → Batch Normalization → Babysitting the Learning Process → Hyperparameter Optimization

---

## 1. Activation Functions

- 뉴런에서 activation function은 **non-linearity를 도입하기 위해** 사용함
- 비선형 함수를 쓰는 이유는 **복잡한 mapping**을 하기 위해서임 (Part A 2-1: 비선형 함수가 없으면 층을 쌓아도 선형 함수 하나와 같음)

### 1-1. Sigmoid

$$\sigma(x) = \frac{1}{1 + e^{-x}}, \qquad x = \sum_i w_i x_i + b$$

- 숫자를 **[0, 1] 범위로 압축(squash)** 함
- x가 큰 양수면 $\sigma(x) \to 1$, 큰 음수면 $\sigma(x) \to 0$
- 역사적으로 인기가 있었던 이유: 뉴런의 **포화되는 "firing rate"** 로 해석하기 좋음
  - 사람의 감각 세포가 어떤 자극 이상이면 반응이 똑같고, 어떤 자극 이하면 반응이 없는 것을 흉내낸 것임

**미분**

$$\frac{d\sigma(x)}{dx} = \sigma(x)\big(1 - \sigma(x)\big), \qquad 0 < \sigma'(x) \le 0.25$$

- 최댓값 0.25는 $x = 0$일 때 ($\sigma(0) = 0.5$ → $0.5 \times 0.5 = 0.25$)

#### 문제점 1: Saturated neurons "kill" the gradients (Vanishing gradient)

$$\frac{\partial L}{\partial x} = \underbrace{\frac{\partial \sigma}{\partial x}}_{\text{local gradient}} \cdot \underbrace{\frac{\partial L}{\partial \sigma}}_{\text{upstream gradient}}$$

- x가 −10이나 10처럼 **포화 영역(saturation)** 에 있으면 local gradient $\sigma'(x) \approx 0$
- upstream gradient가 아무리 커도 **아래로 내려가는 gradient는 0**이 됨 → 이 뉴런 아래의 weight는 update되지 않음
- 직관적으로: 포화된 뉴런은 **입력이 조금 바뀌어도 출력이 거의 변하지 않음** (민감도가 거의 0)
  - 예: $z = 4.8$ → $a \approx 0.99$, $z = -4.6$ → $a \approx 0.01$, 둘 다 $\sigma'(z) \approx 0$

**깊은 신경망에서 gradient가 지수적으로 작아지는 과정**

$$\frac{\partial L}{\partial W_1} = \frac{\partial L}{\partial a_L} \cdot \prod_{l=1}^{L} \sigma'(z_l) \cdot \frac{\partial z_1}{\partial W_1}$$

- 역전파 시 각 층마다 sigmoid의 미분값(**최대 0.25**)이 **연쇄적으로 곱해짐**
- 즉 sigmoid를 activation으로 쓰면 upstream gradient가 무엇이든 **최대 0.25를 곱해서** 아래 층으로 내려보냄
- 예: 10개 층을 지나며 각 층에서 $\sigma' = 0.25$(최댓값)라고 해도 $(0.25)^{10} \approx 9.5 \times 10^{-7}$
- **결과**
  - 입력층에 가까운 **초반 층의 가중치가 거의 update되지 않음**
  - 학습이 매우 느리거나 멈춤. 특히 RNN처럼 긴 시퀀스를 처리하는 모델에서 더 심각함
- 1980~90년대에 multi-layer neural network를 학습시키려 했을 때 층을 몇 개만 쌓아도 앞쪽 층이 학습되지 않았던 원인이 바로 이것임. 당시에는 원인을 분석하지 못하고 "깊은 네트워크는 학습이 안 된다"며 연구가 멈춤 → 이것이 **vanishing gradient problem**

**해결 방법**
1. **다른 activation function 사용**: ReLU, Leaky ReLU 등 포화 영역이 없는 함수
2. **정규화 기법**: Batch Normalization, Layer Normalization (activation 값이 포화 영역으로 가지 않도록)
3. **가중치 초기화**: Xavier(tanh, sigmoid), He(ReLU) 초기화

#### 문제점 2: Sigmoid outputs are not zero-centered (항상 양수) → 학습에 시간이 많이 걸림

뉴런의 입력 $x_i$가 **항상 양수**라면 (= 아래 layer가 sigmoid를 써서 출력이 $0 < x_i < 1$인 경우):

$$f = \sum_i w_i x_i + b, \qquad \frac{\partial L}{\partial w_i} = \frac{\partial L}{\partial f} \cdot \frac{\partial f}{\partial w_i} = \frac{\partial L}{\partial f} \cdot x_i$$

- $\frac{\partial f}{\partial w_i} = x_i$ (mul gate: 다른 입력 값) → **항상 양수**
- $\frac{\partial L}{\partial f}$는 위 layer에서 온 gradient로 양수 또는 음수인데, **모든 $w_i$가 같은 값을 공유**함
- 따라서 **모든 $w_i$의 gradient 부호가 같음** (전부 양수 또는 전부 음수)
  - $\frac{\partial L}{\partial f} > 0$ → 모든 w의 gradient가 +
  - $\frac{\partial L}{\partial f} < 0$ → 모든 w의 gradient가 −
- 2차원 예시($w_1, w_2$)에서 update 가능한 방향은 **"둘 다 증가" 또는 "둘 다 감소"** 사분면뿐임
- 최적 w가 "$w_1$ 감소, $w_2$ 증가" 방향에 있다면 한 번에 갈 수 없고 **zig-zag path**로 돌아가야 함
  - 예: (3, 4) → (1, 5)로 가려면 (−2, +1) 이동이 필요하지만 이 방향은 불가능 → (−2, 0) 방향 이동 후 (0, +1) 방향 이동처럼 나눠서 가야 함
- 그래서 학습이 느려짐 → **입력 데이터도 zero-mean으로 만드는 것이 좋은 이유**이기도 함

> **Quiz: zig-zag 경로가 수평/수직이 아닌(대각선인) 이유는?**
> 수평/수직으로 움직이려면 한쪽 gradient가 0이어야 하는데, 이는 해당 입력 $x_i$가 0일 때만 가능함. Sigmoid 출력은 $\sigma(-1000) \approx 0$처럼 0에 가까워질 수는 있어도 보통은 0이 아니므로, 실제 update는 허용된 사분면 안에서 **대각선 방향**으로 움직이며 zig-zag를 그림.

#### (보충) 문제점 3: exp() 연산 비용

- $e^{-x}$ 계산이 곱셈/비교 연산보다 비쌈 (ReLU에 비해 계산량이 많음)

### 1-2. tanh(x)

- 숫자를 **[−1, 1] 범위로 압축**함
- **zero-centered** (장점) → sigmoid의 문제점 2 해결
- 여전히 **포화 영역에서 gradient를 죽임** (단점) → 문제점 1은 그대로
- 사실 $\tanh(x) = 2\sigma(2x) - 1$로, sigmoid를 zero-centered로 옮기고 늘린 형태임

### 1-3. ReLU (Rectified Linear Unit)

$$f(x) = \max(0, x), \qquad \frac{\partial f}{\partial x} = \begin{cases} 0 & (x < 0) \\ 1 & (x > 0) \end{cases}$$

**장점**
- **양수 영역에서 포화되지 않음** (does not saturate in + region)
- 계산이 매우 효율적임 (비교 연산 하나)
- 실제로 sigmoid/tanh보다 **훨씬 빠르게 수렴**함 (예: 6배)
- 생물학적으로도 sigmoid보다 더 그럴듯함
- **2012년 AlexNet부터 사용**됨. 현재 가장 많이 쓰는 activation function

**왜 vanishing gradient가 해결되나?**
- Sigmoid는 upstream gradient에 **최대 0.25를 곱해서** 내려보냄
- ReLU는 x > 0이면 upstream gradient에 **1을 곱해서, 즉 그대로** 내려보냄 → 층이 깊어져도 gradient가 줄어들지 않음

**단점**
- **not zero-centered**: 출력이 항상 0 이상 → sigmoid의 문제점 2(zig-zag)가 그대로 있음
- **음수 영역(x < 0)에서 gradient가 0** → 입력 영역의 절반에서 gradient를 죽임

#### Dead ReLU

- 데이터 분포(data cloud) 전체에 대해 입력이 음수가 되는 ReLU 뉴런은 **절대 활성화되지 않고(never activate) → 절대 update되지 않음(never update)**
- 원인: 잘못된 초기화, 또는 **learning rate가 너무 커서** weight가 크게 튀어 버린 경우
- 대응: ReLU 뉴런의 **bias를 약간 양수(예: 0.01)로 초기화**하기도 함

### 1-4. Leaky ReLU / PReLU

| 이름 | 식 | 특징 |
|---|---|---|
| Leaky ReLU | $f(x) = \max(0.01x, x)$ | 음수 영역에도 작은 기울기(0.01) |
| Parametric Rectifier (PReLU) | $f(x) = \max(\alpha x, x)$ | $\alpha$를 **파라미터로 두고 backprop으로 학습** |

- 포화되지 않음, 계산 효율적, sigmoid/tanh보다 빠르게 수렴(예: 6배)
- **죽지 않음 (will not "die")** → Dead ReLU 문제 완화

### 1-5. ELU (Exponential Linear Units)

$$f(x) = \begin{cases} x & (x > 0) \\ \alpha(e^x - 1) & (x \le 0) \end{cases}$$

- ReLU의 장점을 모두 가짐
- 출력 평균이 **0에 더 가까움** (closer to zero mean outputs)
- Leaky ReLU와 달리 음수 영역에 **포화 영역**이 있어 노이즈에 좀 더 강건함(robust)
- 단점: **exp() 계산 필요**

### 1-6. Maxout "Neuron" [Goodfellow et al., 2013]

$$\max(w_1^T x + b_1,\ w_2^T x + b_2)$$

- "dot product → nonlinearity"라는 기본 형태를 따르지 않음
- ReLU와 Leaky ReLU를 **일반화**한 형태 (예: $w_1 = 0, b_1 = 0$이면 ReLU)
- 선형 영역만 있음 → **포화되지 않고, 죽지 않음**
- 문제: 뉴런당 **파라미터 수가 2배**가 됨

### 1-7. 실전 가이드 (TLDR)

- **ReLU를 사용하라.** 단, learning rate를 조심해서 설정할 것 (너무 크면 dead ReLU)
- Leaky ReLU / Maxout / ELU도 시도해 볼 만함
- tanh도 써볼 수는 있지만 큰 기대는 하지 말 것
- **Sigmoid는 쓰지 말 것** (hidden layer 기준. 이진 분류의 출력층 확률 등은 예외)

---

## 2. Data Preprocessing

### 2-1. 왜 전처리가 필요한가

- 차원(feature)별로 숫자가 **비슷한 scale, 비슷한 분포**를 가져야 분류나 계산을 할 때 의미 있는 계산을 할 수 있음
  - 예: 키(cm, 140~200)와 연봉(만원, 수천~수만)을 그대로 쓰면 큰 값을 가진 feature가 학습을 지배함
- **Before normalization**: classification loss가 weight 변화에 매우 민감함 → 최적화하기 어려움
  - 데이터가 원점에서 멀리 떨어져 있으면 결정 경계가 조금만 회전해도 분류 결과가 크게 바뀜
- **After normalization**: weight의 작은 변화에 덜 민감함 → **최적화하기 쉬움**

### 2-2. Zero-centering과 Normalization

- 데이터 행렬 $X$: $N \times D$ (각 행이 하나의 sample, 예: $D = 32 \times 32 \times 3$)

```python
X -= np.mean(X, axis=0)   # zero-centered: 차원(열)별 평균을 뺌
X /= np.std(X, axis=0)    # normalized: 차원별 표준편차로 나눔
```

| 단계 | 결과 |
|---|---|
| original data | 원점에서 떨어져 있고 축마다 scale이 다름 |
| zero-centered data | 평균이 원점(0)으로 이동 |
| normalized data | 각 차원의 scale(분산)이 비슷해짐 |

- Zero-centering은 1-1의 문제점 2(입력이 모두 양수 → zig-zag)를 막아 줌
- 그 밖에 **PCA**(데이터를 주성분 축으로 회전해 차원 간 상관관계 제거)와 **Whitening**(PCA 후 각 축의 분산을 1로 맞춤)도 있음
- **이미지의 경우**: 보통 zero-centering만 함 (각 픽셀 scale이 이미 [0, 255]로 비슷하므로 normalization이나 PCA/whitening은 잘 하지 않음)
  - 평균 이미지 전체(32×32×3)를 빼기(AlexNet) 또는 채널별 평균(3개 값)을 빼기(VGGNet)

### 2-3. 일반적인 데이터 전처리 항목

| 문제 | 전처리 |
|---|---|
| 특징(변수)의 **scale이 달라서** 학습이 불안정함 | 정규화/표준화로 비슷한 범위로 맞춤 |
| **이상치(Outlier)** 가 학습을 방해함 | 이상치 제거 또는 적절한 범위로 조정 |
| **결측치(Missing Value)** 가 있음 | 제거하거나 평균값/최빈값/모델 기반 예측으로 채움 |
| **범주형 데이터** (예: 날씨 맑음/흐림/비) | 원-핫 인코딩, 레이블 인코딩 등으로 수치 변환 |
| 데이터 **형식이 제각각** (이미지 크기, 텍스트, 불규칙 시계열) | 크기 통일(예: 224×224), 토큰화+수치 변환(임베딩), 리샘플링 |

- 좋은 전처리를 하면 **더 빠르게 수렴**하고, **일반화 성능**(새로운 데이터에 대한 성능)도 좋아짐

---

## 3. Weight Initialization

- 학습 전에 각 연결 가중치를 어떤 값으로 설정할지가 **학습 가능성과 수렴 속도**에 큰 영향을 줌

| 초기값 | 현상 |
|---|---|
| 너무 큰 값 | 층이 깊어질수록 activation 분포가 넓어지고 비선형 함수가 **포화**되어 학습이 불안정해짐 (기울기 폭발/소실) |
| 너무 작은 값 | 층이 깊어질수록 activation이 0 근처로 모여 **기울기가 거의 0** → 학습이 진행되지 않음 (기울기 소실) |
| 적절한 값 | 층이 깊어져도 activation 분포의 형태와 범위가 비슷하게 유지됨 → 안정적으로 학습됨 |

### 3-1. W = 0으로 초기화하면?

- **모든 뉴런이 똑같은 일을 함 (All neurons will do the same thing)**
- 모든 뉴런이 같은 출력을 내고 같은 gradient를 받아 같은 방향으로 update됨 → 뉴런을 여러 개 둔 의미가 없음 (**symmetry 문제**)
- 따라서 **random 값으로 초기화**해서 대칭을 깨야 함

### 3-2. 첫 번째 아이디어: 작은 random 값

```python
W = 0.01 * np.random.randn(D, H)   # 평균 0, 표준편차 0.01인 Gaussian
```

- 작은 네트워크에서는 괜찮지만, **깊은 네트워크에서는 문제**가 생김

### 3-3. 실험: 10-layer tanh 네트워크 (layer당 뉴런 500개)

$$x_i = \tanh\Big(\sum_j w_{i,j} \times x_j\Big), \qquad -1 < x_j < 1$$

**(1) W = 0.01 × randn → 모든 activation이 0이 됨**

| layer | activation 표준편차 |
|---|---|
| input | 약 1.0 |
| hidden 1 | 0.21 |
| hidden 2 | 0.048 |
| hidden 3 | 0.011 |
| … | … |
| hidden 10 | 약 0.000000 |

- **Forward**: 절댓값 1보다 작은 값에 0.01 규모의 w를 계속 곱하니까, 위 layer로 갈수록 activation 값이 **0으로 수렴**함
- **Backward**: $W \times X$ gate에서
  - W에 대한 gradient = $x \times$ upstream → **x가 거의 0이므로 W의 gradient도 거의 0** → weight가 update되지 않음
  - x에 대한 gradient = $w \times$ upstream → w가 작은 값이므로 **아래로 내려가는 gradient가 점점 작아짐**

**(2) W = 1.0 × randn → 거의 모든 뉴런이 포화됨**

- 표준편차 1 규모의 w 500개에 $x_j$를 곱해 더하면 합의 절댓값이 커짐 → tanh 출력이 **−1 또는 1로 완전히 포화**됨
- 포화 영역에서 tanh의 local gradient가 0 → **gradient가 모두 0**이 됨

**(3) Xavier initialization [Glorot et al., 2010]**

```python
W = np.random.randn(fan_in, fan_out) / np.sqrt(fan_in)
```

- activation 분포가 층을 지나도 적당한 범위(표준편차 0.63 → 0.49 → … → 0.23)로 유지됨 → **합리적인 초기화**
- **원리**
  - 랜덤 초기화된 뉴런 출력의 분산은 **입력 개수(fan-in)에 비례해서 커짐**: $\text{Var}\left(\sum_{j=1}^{n} w_{i,j} x_j\right) = n \cdot \text{Var}(w)\,\text{Var}(x)$
  - 연결된 입력 뉴런이 많을수록 $\sum_j w_{i,j} x_j$의 분산이 커지므로 정규화가 필요함
  - weight를 **fan-in의 제곱근으로 나누면** $\text{Var}(w) = 1/n$ → 각 뉴런 출력의 분산이 1로 유지됨
  - 즉, **"weight의 초기값을 (연결된 입력 뉴런 개수)의 제곱근으로 나누어 지정하자"** → 입력 뉴런 개수에 상관없이 $\sum_j w_{i,j} x_j$가 일정한 범위의 값을 가짐
- 수식 유도는 **선형 activation을 가정**함 (tanh는 0 근처에서 거의 선형이므로 잘 맞음)
- 원 논문 버전은 backward까지 고려해 $W \sim \mathcal{N}\left(0, \frac{2}{n_{in} + n_{out}}\right)$을 사용함
- 주로 **tanh, sigmoid**와 함께 사용

### 3-4. ReLU에는 다른 초기화가 필요함 — He initialization

```python
W = np.random.randn(fan_in, fan_out) / np.sqrt(fan_in / 2)   # He (Kaiming) init
```

- ReLU는 **음수 절반을 0으로 만들기 때문에 출력 분산이 절반**이 됨
- Xavier를 ReLU에 쓰면 층을 지날수록 activation이 0 쪽으로 몰려 분포가 무너짐
- 분산을 2배로 보정: $W \sim \mathcal{N}\left(0, \frac{2}{n_{in}}\right)$ → 층이 깊어져도 분포가 유지됨
- 깊은 ReLU 네트워크에서 Xavier는 학습이 거의 진행되지 않지만, **초기값만 He로 바꿨는데 잘 수렴함**

### 3-5. 초기화 방법 정리

| 방법 | 분포 | 주로 쓰는 activation | 비고 |
|---|---|---|---|
| 0으로 초기화 | — | 사용하지 않음 | 모든 뉴런이 동일하게 학습됨 |
| 작은 random | $\mathcal{N}(0, 0.01^2)$ | — | 깊은 네트워크에서 기울기 소실 |
| **Xavier (Glorot)** | $\mathcal{N}\left(0, \frac{1}{n_{in}}\right)$ 또는 $\mathcal{N}\left(0, \frac{2}{n_{in}+n_{out}}\right)$ | tanh, sigmoid | 입력/출력 분산을 비슷하게 유지 |
| **He (Kaiming)** | $\mathcal{N}\left(0, \frac{2}{n_{in}}\right)$ | ReLU | ReLU의 분산 절반 감소를 보정 |

- 깊은 네트워크(예: 20층)에서 학습 loss 비교: 큰 값(발산) < 작은 값(매우 느림) < Xavier(안정적 수렴) < He(더 빠른 수렴, ReLU 기준)

---

## 4. Batch Normalization [Ioffe and Szegedy, 2015]

### 4-1. 기본 아이디어

- **"Unit gaussian activation을 원하나? 그럼 그냥 그렇게 만들어라."** (you want unit gaussian activations? just make them so.)
- 입력은 전처리로 정규화했다 하더라도, **layer를 지남에 따라 activation 값들은 정규화가 안 될 수 있음**
- 정규화가 안 되면 처리(학습)하기 어려우니까 **중간중간 정규화를 시켜서 다음 layer로 넘겨주자**는 것이 기본 아이디어임
- 왜 activation 값을 정규화하나?
  - classification loss가 weight 변화에 매우 **민감(sensitive)** 하기 때문
  - 정규화하면 **최적화하기 쉬움** (easy to optimize)
- 이런 기법들이 발견되면서 **깊은 네트워크(DNN)도 학습이 잘 되게** 됨

### 4-2. 문제: Internal Covariate Shift (내부 공변량 이동)

- 학습이 진행되면서 **앞쪽 층의 가중치가 계속 변하기 때문에**, 다음 층의 입력 데이터 분포(평균, 분산)가 계속 달라짐
- 각 층은 매번 달라지는 분포에 적응해야 하므로 **학습이 불안정하고 느려짐**
- 이는 **training과 testing의 데이터 분포가 다른 문제**와 비슷함 (covariate shift를 네트워크 내부 층 단위로 본 것)
- 좌굴(buckling) 비유: 긴 기둥 위쪽에 하중이 걸리면 아래쪽의 작은 흔들림(perturbation)이 위쪽에서 큰 변형으로 이어짐 → 깊은 네트워크에서도 **앞쪽 층의 작은 변화가 뒤쪽 층에서 큰 분포 변화**로 이어짐
- 그 결과 loss 함수의 형태가 길고 좁아져 최적점까지 가는 경로가 zig-zag가 되고, 학습이 느려지며 지역 최적점에 빠질 가능성도 커짐

### 4-3. 계산 방법

현재 **mini-batch 학습 데이터(예: 16~32개)** 에 대해 **각 뉴런의 activation 값을 normalize**함

1. 각 차원(뉴런)마다 **독립적으로** empirical mean과 variance를 계산 ($N \times D$ 행렬에서 열 방향)
2. 정규화

$$\hat x^{(k)} = \frac{x^{(k)} - E[x^{(k)}]}{\sqrt{\text{Var}[x^{(k)}]}}$$

**전체 알고리즘**

- Input: mini-batch의 x 값 $\mathcal{B} = \{x_1, \dots, x_m\}$, 학습할 파라미터 $\gamma, \beta$
- Output: $\{y_i = \text{BN}_{\gamma, \beta}(x_i)\}$

| 단계 | 식 |
|---|---|
| mini-batch mean | $\mu_\mathcal{B} = \frac{1}{m}\sum_{i=1}^{m} x_i$ |
| mini-batch variance | $\sigma_\mathcal{B}^2 = \frac{1}{m}\sum_{i=1}^{m}(x_i - \mu_\mathcal{B})^2$ |
| normalize | $\hat x_i = \frac{x_i - \mu_\mathcal{B}}{\sqrt{\sigma_\mathcal{B}^2 + \epsilon}}$ |
| scale and shift | $y_i = \gamma \hat x_i + \beta \equiv \text{BN}_{\gamma,\beta}(x_i)$ |

- $\epsilon$: 분모가 0이 되는 것을 막는 아주 작은 값
- $\gamma$(scale), $\beta$(shift): **학습되는 파라미터** (초기값 $\gamma = 1,\ \beta = 0$)

### 4-4. 왜 γ, β가 필요한가

- 문제: **tanh layer의 입력이 꼭 unit gaussian이어야 하나?**
- tanh의 입력이 항상 평균 0, 분산 1일 필요는 없음 → **원하는 형태의 Gaussian 분포(평균, 분산)로 학습을 통해 바꾸자**
  - 예: tanh 입력을 linear(포화되지 않는) 영역에 둘지, 일부러 포화 영역을 쓸지를 네트워크가 스스로 정함
- $\gamma = \sqrt{\text{Var}[x^{(k)}]}$, $\beta = E[x^{(k)}]$로 학습되면 **정규화를 원래대로 되돌릴 수도 있음** → 정규화 후에도 뉴런이 유연하게 표현력을 가질 수 있음

### 4-5. 위치

- 보통 **Fully Connected layer 또는 Convolutional layer 뒤, nonlinearity(activation) 앞**에 넣음

```
FC → BN → tanh → FC → BN → tanh → ...
Conv → BN → ReLU → Maxpool → ...
```

- MatConvNet 등에서는 BN(moments μ, σ) + scale/bias(γ, β)를 하나의 블록으로 구현함

### 4-6. 계산 예제 (은닉층 1, batch size B = 4, 뉴런 4개)

은닉층 1의 출력 $H^1$ (행 = 샘플, 열 = 뉴런)

| | 뉴런 1 | 뉴런 2 | 뉴런 3 | 뉴런 4 |
|---|---|---|---|---|
| 샘플 1 | 0.2 | 1.0 | 0.0 | 2.1 |
| 샘플 2 | 0.4 | 0.8 | 0.1 | 1.9 |
| 샘플 3 | 0.1 | 1.1 | 0.2 | 2.4 |
| 샘플 4 | 0.3 | 0.9 | 0.0 | 2.0 |

**① 뉴런별 배치 통계** (열 방향: 같은 뉴런의 B개 값)

| | 뉴런 1 | 뉴런 2 | 뉴런 3 | 뉴런 4 |
|---|---|---|---|---|
| $\mu_j$ | 0.25 | 0.95 | 0.075 | 2.10 |
| $\sigma_j$ | 0.112 | 0.112 | 0.083 | 0.187 |

**② 정규화** $\hat H_{i,j} = \frac{H_{i,j} - \mu_j}{\sqrt{\sigma_j^2 + \epsilon}}$, **③ scale & shift** $Y_{i,j} = \gamma_j \hat H_{i,j} + \beta_j$ ($\gamma = 1, \beta = 0$일 때)

| | 뉴런 1 | 뉴런 2 | 뉴런 3 | 뉴런 4 |
|---|---|---|---|---|
| 샘플 1 | −0.45 | 0.45 | −0.90 | 0.00 |
| 샘플 2 | 1.34 | −1.34 | 0.30 | −1.07 |
| 샘플 3 | −1.34 | 1.34 | 1.51 | 1.60 |
| 샘플 4 | 0.45 | −0.45 | −0.90 | −0.53 |

- 각 뉴런의 값이 **평균 0, 분산 1**로 정규화되어 비슷한 범위를 갖게 됨
- 정리: BN은 **한 층에서 같은 뉴런(특정 채널)의 출력값을, 한 batch에 있는 모든 샘플에 대해 모아서** 평균과 분산을 계산하고 정규화함
  - 정규화하는 범위: **'배치 내 샘플들' × '같은 층의 같은 뉴런'**
- GPU로 학습하는 경우 mini-batch 안의 학습 데이터가 **모두 함께 입력**되므로 batch 단위 통계를 바로 계산할 수 있음

### 4-7. 효과

- 네트워크를 통한 **gradient 흐름이 좋아짐** (improves gradient flow)
- **더 큰 learning rate를 사용**할 수 있음
- **초기화에 대한 강한 의존성이 줄어듦**
- 일종의 **regularization** 효과가 있어 dropout의 필요성을 조금 줄여 줌 (mini-batch 통계를 쓰기 때문에 작은 노이즈가 생겨 과적합이 줄어듦)
- 결과적으로 학습이 **더 빠르고 안정적**이며 더 좋은 성능을 얻기 쉬움

### 4-8. (보충) Test 시의 BN

- test 때는 batch가 없거나 1개일 수 있으므로 mini-batch 통계를 쓰지 않음
- 학습 중에 계산해 둔 **평균과 분산의 이동 평균(running average)** 을 고정된 값으로 사용함

### 4-9. Normalization 방법들

Feature map tensor의 축: **N**(batch), **C**(channel), **H, W**(공간)

| 방법 | 같은 평균/분산으로 정규화하는 범위 | 주 사용처 |
|---|---|---|
| **Batch Norm** | 같은 채널(C)에 대해 **batch 전체(N) × H × W** | CNN |
| **Layer Norm** | 한 샘플 안의 **모든 채널(C) × H × W** | RNN, Transformer |
| **Instance Norm** | 한 샘플의 **한 채널(H × W)** 만 | 스타일 변환 |
| **Group Norm** | 한 샘플 안에서 **채널을 그룹으로 묶어** 그룹 × H × W | batch가 작을 때 |
| **Switchable Norm** | BN + IN + LN을 **가중 결합**, 비율을 학습 | — |

- 같은 channel에 있는 activation 값들 = **같은 filter의 출력 값들** = 특정 특징이 얼마나 있는지를 나타내는 값들
- 예: data1~3 (batch 3개), 채널 C1~C3, 각 채널에 뉴런 x1~x6이 있을 때
  - **Batch Norm**: 채널 C1에 대해 [data1의 x1~x6, data2의 x1~x6, data3의 x1~x6]을 한 그룹으로 정규화 → **batch 방향**
  - **Layer Norm**: data1에 대해 [C1의 x1~x6, C2의 x1~x6, C3의 x1~x6]을 한 그룹으로 정규화 → **샘플 하나 안에서**
- BN 공식 요약

$$\text{BN}(\mathbf{h}; \gamma, \beta) = \beta + \gamma \frac{\mathbf{h} - \hat E(\mathbf{h})}{\sqrt{\widehat{\text{Var}}(\mathbf{h}) + \epsilon}}$$

  - $\mathbf{h}$: 이전 layer의 출력, $\hat E(\mathbf{h})$: h의 평균, $\widehat{\text{Var}}(\mathbf{h})$: h의 분산, $\epsilon$: 안정화용 작은 값
  - 분수 부분이 h를 평균 0, 분산 1로 정규화하고, $\gamma, \beta$가 정규화된 분포를 scale/shift함 (학습되는 파라미터)

---

## 5. Babysitting the Learning Process

학습 과정을 "아기 돌보듯" 지켜보면서 문제를 조기에 발견하는 절차임

**Step 1. 데이터 전처리**: zero-center, normalize (2장)

**Step 2. 아키텍처 선택**: 예) CIFAR-10 이미지 3072 입력 → hidden 50개 → 출력 10개 (클래스당 하나)

**Step 3. Loss가 합리적인지 확인 (sanity check)**

```python
model = init_two_layer_model(32*32*3, 50, 10)          # input, hidden, classes
loss, grad = two_layer_net(X_train, model, y_train, 0.0)   # regularization 끔
print(loss)   # 2.3026
```

- regularization을 끈 상태에서 초기 loss가 약 **2.3**이면 정상 → 10 class softmax에서 초기에는 모든 클래스 확률이 약 1/10이므로 $L = -\ln(1/10) = \ln 10 \approx 2.303$
- regularization을 켜면 loss가 약간 올라가야 정상임

**Step 4. 아주 작은 데이터로 overfit 해보기**

- 학습 데이터 20개만 떼어서 regularization 없이 학습 → **loss가 매우 작아지고 train accuracy 1.00**이 나오면 정상
- 작은 데이터에서도 overfit이 안 되면 모델/코드에 문제가 있는 것

**Step 5. Loss curve 모니터링**

| learning rate | loss curve 모양 |
|---|---|
| very high | loss가 발산(폭증)함 |
| high | 빨리 떨어지다가 높은 값에서 멈춤 |
| low | 거의 직선처럼 천천히 떨어짐 |
| **good** | 빠르게 떨어진 뒤 낮은 값으로 계속 수렴 |

**Step 6. Accuracy 모니터링**

| 현상 | 해석 | 대응 |
|---|---|---|
| train과 validation accuracy의 **gap이 큼** | **overfitting** | regularization 강도를 높임 |
| **gap이 없음** | 모델이 충분히 학습하지 못함 | model capacity를 늘림 |

**Step 7. Weight update 비율 모니터링**

```python
param_scale = np.linalg.norm(W.ravel())
update = -learning_rate * dW          # simple SGD update
update_scale = np.linalg.norm(update.ravel())
W += update
print(update_scale / param_scale)     # want ~1e-3
```

- (update 크기) / (weight 크기) 비율이 **약 0.001** 정도가 되는 것이 좋음
- 너무 크면 learning rate가 큰 것이고, 너무 작으면 learning rate가 작은 것임

---

## 6. Hyperparameter Optimization

### 6-1. Hyperparameter란

- **학습할 때 사람이 정하고 변경시킬 수 있는 값들** (weight처럼 학습으로 구해지는 값이 아님)
- hyperparameter를 조합해서 학습을 시키며, **어떻게 바꿔야 loss가 가장 작은 W를 구할 수 있는지를 search**해야 함
- 조정 대상
  - network architecture (layer 수, 뉴런 수 = 모델 크기)
  - **learning rate**, decay schedule, update type
  - regularization (L2 / Dropout 강도)
  - batch size, epoch 수
- 비유: DJ가 믹서의 여러 노브를 돌리는 것과 같고, 이때 음악 = loss function임

### 6-2. Epoch과 Learning rate

- **Epoch**: 학습 데이터 **전체를 한 번 다 보여주고** loss에 따라 W를 update(반영)한 것
- **Learning rate**: W가 전체 loss에 얼마나 영향을 미쳤나(gradient)를 바탕으로 W를 update할 때, **gradient를 어떤 비율로 반영할 것인가**
  - 예: gradient가 100일 때 그대로 반영하면 w를 100만큼 바꿈, learning rate 0.001을 곱하면 $100 \times 0.001 = 0.1$만큼만 바꿈
  - **W를 너무 크게 바꾸면 학습이 되지 않음** (최솟값을 지나쳐서 발산)

### 6-3. Coarse → Fine search

- **Cross-validation을 단계적으로 진행**함
  - **1단계 (coarse)**: 몇 epoch만 돌려서 어떤 파라미터가 되는지 대략 파악
  - **2단계 (fine)**: 좋은 범위로 좁혀서 더 오래 돌리며 세밀하게 search
  - 필요하면 반복

```python
# coarse search (5 epochs)
for count in range(100):
    reg = 10 ** uniform(-5, 5)
    lr  = 10 ** uniform(-3, -6)
    ...
# 좋은 결과가 나온 범위로 좁혀서 fine search
    reg = 10 ** uniform(-4, 0)
    lr  = 10 ** uniform(-3, -4)
```

- **log space에서 최적화하는 것이 좋음** (`10 ** uniform(...)`): learning rate나 regularization은 0.0001, 0.001, 0.01처럼 **자릿수(scale) 단위로** 효과가 달라지기 때문
- 예: 50개 hidden 뉴런의 2-layer NN에서 fine search 후 validation accuracy **53%** → 비교적 좋은 결과

### 6-4. Random Search vs Grid Search [Bergstra and Bengio, 2012]

| | Grid Search | Random Search |
|---|---|---|
| 방식 | 정해진 조합(fixed set of combination)을 격자로 시도 | 범위 안에서 무작위로 시도 |
| 9번 시도 시 중요한 파라미터 값 | **3개**만 확인 | **9개** 서로 다른 값 확인 |

- 실제로는 hyperparameter 중 **중요한 것과 중요하지 않은 것**이 섞여 있음
- Grid는 중요하지 않은 파라미터를 바꾸는 데 시도를 낭비하지만, Random은 중요한 파라미터를 더 다양하게 탐색함 → **3×3번보다 random 9번이 더 좋음**
- 그림의 녹색 라인 = 중요한 파라미터 값에 따른 **loss(성능)** 곡선

---

## 7. Train / Validation / Test 데이터

### 7-1. 데이터 분할

- 학습 데이터와 테스트 데이터를 나누고, 학습 데이터에서 다시 validation을 떼어냄
- 예: **Training 70% / Validation 15% / Test 15%** (학습용 70%를 쓰고, 나머지 30%를 다시 validation과 test로 나눔)
- 일반적으로 Train 60~70%, Validation 10~20%, Test 10~20%

| 구분 | 사용 시점 | 목적 | 사용 횟수 |
|---|---|---|---|
| **Train** | 모델 학습 | 가중치 학습 | 여러 번 |
| **Validation** | 모델 개발 과정 | 여러 모델/hyperparameter 중 가장 좋은 것 선택 | 여러 번 |
| **Test** | 최종 평가 | 선택된 모델의 **일반화 성능 추정** | **단 한 번** |

### 7-2. 전체 흐름

1. 여러 모델/hyperparameter로 학습 (Train 데이터)
2. Validation 데이터로 성능을 비교해 가장 좋은 모델 선택 (예: Model 1 85%, **Model 2 92%**, Model 3 87% → Model 2 선택)
3. 선택된 최종 모델을 **Test 데이터로 한 번만 평가** (예: 90%)

### 7-3. 왜 Validation과 Test를 분리하나

- Test 데이터를 보면서 모델을 여러 번 수정하면, 모델이 **Test 데이터의 특성에 맞춰져 버림** (데이터 누수, 과적합된 모델 선택)
  - 예: Test 정확도를 보며 모델 A(82%) → B(85%) → C(87%) → D(89%)로 계속 고침 → Test에 "우연히 잘 맞는" 모델을 고른 것일 수 있음
- 이 경우 Test 성능이 **실제보다 과대평가**되고, 새로운 데이터에 대한 성능은 떨어질 수 있음
- Validation 데이터에 맞춰 hyperparameter를 고른 모델은 **validation에 딱 맞춰진 모델**이므로, validation 성능 역시 실제 성능을 보장하지 못함 → 그래서 **개발 과정에 전혀 쓰지 않은 test 데이터**가 따로 필요함
- 학습이 끝난 모델의 실제 성능은 **test 데이터로 측정**함

**생각해 볼 질문 (Loss space)**
- 학습의 목적이 **loss가 최소가 되는 weight(loss 공간의 가장 깊은 점)를 찾는 것**인가?
- 그 점을 찾으면 실제 응용에서도 학습할 때의 성능(validation 성능)을 보장하는가?
- → 학습 데이터에 대한 loss 최소점이 곧 일반화 성능 최고점은 아님. 그래서 validation으로 멈출 시점과 모델을 고르고, test로 최종 확인함

### 7-4. K-fold Cross Validation

- 데이터를 k개(예: 4개)로 나누고, 각 fold를 돌아가며 test(validation)로 쓰고 나머지로 학습 → k개의 결과를 평균
- 데이터가 적을 때 유용함
- **Nested split**: outer split으로 Test set을 먼저 떼어내고, 남은 outer training set을 다시 inner split으로 training/validation으로 나눠 학습·튜닝·평가를 반복한 뒤, 최종 성능은 test set으로 추정함

### 7-5. Overfitting과 Early Stopping

- 학습을 계속하면 **training error는 계속 줄어들지만**, validation error는 어느 시점부터 **다시 커짐**
  - 학습 데이터에 없는 데이터에 대해서는 **오히려 성능이 나빠지는 현상**이 일어남
- 따라서 validation error가 최소인 지점에서 **학습을 멈춰야** 성능이 좋음 → **Early Stopping**
  - 예: "Best Validation Performance is 26.6393 at epoch 9" → 9 epoch에서 멈춘 모델을 선택
- 학습 중에는 **항상 validation 성능을 함께 측정(test)** 해야 함
- 학습 데이터로 쓰이지 않은 validation 데이터의 accuracy는 train accuracy만큼 계속 늘어나지 않음

### 7-6. Underfitting / Overfitting과 모델 복잡도

| | Under-fitting | Appropriate-fitting | Over-fitting |
|---|---|---|---|
| 모델 | 너무 단순함 | 적절함 | 너무 복잡함 |
| 결정 경계 | 데이터의 분산을 설명 못함 | 일반적인 패턴을 잡음 | 학습 데이터에 억지로 맞춤 (too good to be true) |
| Train error | 높음 | 낮음 | 매우 낮음 |
| Validation/Test error | 높음 | **최소 (Best Fit)** | 높아짐 |

- **모델 크기(파라미터 개수)를 크게 하면** 학습 데이터에 너무 맞춰져서 **training error는 줄어들지만 validation error는 커짐** → overfitting
- Model complexity(또는 hidden node 수, 학습 iteration)가 커질수록 training error는 계속 감소하고, test error는 U자 형태를 그림 → U자의 바닥이 **Best Fit**

---

## 8. 참고 자료 — 예상 문제

**문제.** 그림 (가)는 sigmoid 함수가 zero-centered되어 있지 않기 때문에 발생하는 문제(zig-zag path)를 설명한 그림이다.

(나) Weight Update 수식: $\underbrace{\frac{\partial L}{\partial w_i}}_{(1)} = \underbrace{\frac{\partial L}{\partial f}}_{(2)} \cdot \underbrace{\frac{\partial f}{\partial w_i}}_{(3)}$

(다) Vanishing Gradient 관련 수식: $\underbrace{\frac{\partial L}{\partial x}}_{(1)} = \underbrace{\frac{\partial \sigma}{\partial x}}_{(2)} \cdot \underbrace{\frac{\partial L}{\partial \sigma}}_{(3)}$

**(a) 여기서 zero-centered되지 않았다는 것의 의미를 설명하라.**
- Sigmoid 함수의 출력 값은 **항상 양수**임. 즉 음수가 없음 (출력 범위 (0, 1), 평균이 0이 아님)

**(b) 이런 이유로 weight update가 모두 증가 혹은 감소하는 방향으로 움직인다. 그 이유를 (나)의 (1), (2), (3)의 의미와 함께 설명하라.**
- (1): update되는 **weight 양** (각 $w_i$의 gradient)
- (2): **위 layer에서 전달된 gradient 양** (양수 또는 음수, 모든 $w_i$가 공유)
- (3): $x_i$, 즉 **뉴런의 입력 값** (아래 layer sigmoid의 출력이므로 **항상 양수**)
- (3)이 항상 양수이기 때문에 모든 $w_i$가 (2)의 부호를 그대로 따름 → 모든 weight의 gradient가 전부 양수이거나 전부 음수 → update 방향이 제한되어 zig-zag path가 생김

**(c) (다) 수식은 입력 x에 따라 아래 layer로 back propagation하는 gradient 양을 계산하는 식이다. ReLU를 activation 함수로 사용하는 경우(sigmoid와 비교하여) neural network가 deep하여도 vanishing gradient 현상이 일어나지 않는 이유를 (1), (2), (3)의 의미와 함께 설명하라.**
- (1): 아래 layer로 전달되는 gradient 양
- (2): activation 함수의 **local gradient**
- (3): 위 layer에서 전달된 **upstream gradient**
- Sigmoid: $0 < \frac{\partial\, \text{Sigmoid}(x)}{\partial x} \le 0.25$ → 상위 layer의 gradient에 **최대 0.25를 곱해서** 하위 layer로 전달하므로, 층이 깊어질수록 gradient가 지수적으로 작아짐. 특히 x가 큰 값(|x| > 10)이면 (2)가 0이 되어 gradient가 사라짐 (vanishing gradient)
- ReLU: $\frac{\partial\, \text{ReLU}(x)}{\partial x} = 0\ (x < 0),\ 1\ (x > 0)$ → x가 양수인 경우 상위 layer의 gradient에 **1을 곱해서 그대로** 하위 layer로 전달하므로, 층이 깊어져도 gradient가 줄어들지 않음

---

## 9. 핵심 공식 정리

| 항목 | 공식 |
|---|---|
| Chain rule (노드 단위) | $\frac{\partial L}{\partial x} = \frac{\partial L}{\partial z} \cdot \frac{\partial z}{\partial x}$ (upstream × local) |
| Branch에서 합산 | $\frac{\partial f}{\partial x} = \sum_i \frac{\partial f}{\partial g_i}\frac{\partial g_i}{\partial x}$ |
| 층별 오류 신호 | $\delta^{(l)} = (W^{(l+1)})^T \delta^{(l+1)} \odot \varphi'(z^{(l)})$ |
| 가중치 gradient | $\frac{\partial L}{\partial W^{(l)}} = \delta^{(l)}(a^{(l-1)})^T,\ \ \frac{\partial L}{\partial b^{(l)}} = \delta^{(l)}$ |
| Gradient descent | $w \leftarrow w - \eta \frac{\partial L}{\partial w}$ |
| Sigmoid 미분 | $\sigma'(x) = \sigma(x)(1 - \sigma(x)) \le 0.25$ |
| ReLU 미분 | $0\ (x<0),\ 1\ (x>0)$ |
| Vanishing 예시 | $(0.25)^{10} \approx 9.5 \times 10^{-7}$ |
| Xavier init | `randn(fan_in, fan_out) / sqrt(fan_in)` → $\text{Var}(w) = 1/n_{in}$ |
| He init | `randn(fan_in, fan_out) / sqrt(fan_in/2)` → $\text{Var}(w) = 2/n_{in}$ |
| Batch Norm | $\hat x = \frac{x - \mu_\mathcal{B}}{\sqrt{\sigma_\mathcal{B}^2 + \epsilon}},\ \ y = \gamma \hat x + \beta$ |
| 초기 softmax loss (C개 클래스) | $\ln C$ (C = 10 → 2.303) |
| Update/weight 비율 | 약 $10^{-3}$ |

---

## 10. 셀프 체크리스트

**Lecture 4**
- [ ] 2-layer NN $f = W_2\max(0, W_1x)$에서 max가 없으면 왜 linear classifier와 같아지는지 설명할 수 있다
- [ ] 비선형 활성화 + 여러 층이 표현력을 높이는 원리(공간 변형, 계층적 특징)를 설명할 수 있다
- [ ] 2-layer NN NumPy 코드의 backward 4줄을 각각 유도할 수 있다
- [ ] batch size가 2배가 되면 activation 저장 용량은 2배, weight는 그대로임을 설명할 수 있다
- [ ] 직접 연결되지 않은 weight의 gradient를 왜 역전파로 구해야 하는지 설명할 수 있다
- [ ] 7장 수치 예제($\delta_{out}$, $\delta_{h_1}$, $\delta_{h_2}$, 가중치 update)를 직접 계산할 수 있다
- [ ] $f = (x+y)z$ 예제에서 $\partial f/\partial x, \partial f/\partial y, \partial f/\partial z$를 구할 수 있다
- [ ] local gradient × upstream gradient의 의미를 설명할 수 있다
- [ ] sigmoid 뉴런 computational graph에서 각 노드의 gradient를 채울 수 있고, sigmoid gate로 묶어 $0.73 \times 0.27 = 0.2$로 구할 수 있다
- [ ] add / max / mul gate의 backward 패턴(distributor / router / switcher)을 설명할 수 있다
- [ ] branch에서 gradient를 합하는 이유를 설명할 수 있다
- [ ] forward()/backward() API에서 forward가 중간값을 저장하는 이유를 설명할 수 있다

**Lecture 5**
- [ ] sigmoid의 문제점 2가지(+exp 비용)를 설명할 수 있다
- [ ] vanishing gradient가 왜 생기는지 $\sigma' \le 0.25$와 연결해서 설명할 수 있다
- [ ] not zero-centered → 모든 $w_i$의 gradient 부호가 같음 → zig-zag를 수식으로 설명할 수 있다
- [ ] tanh, ReLU, Leaky ReLU, PReLU, ELU, Maxout의 장단점을 비교할 수 있다
- [ ] Dead ReLU가 무엇이고 어떻게 완화하는지 설명할 수 있다
- [ ] zero-centering과 normalization 코드를 쓸 수 있고, 이미지에서는 주로 평균만 빼는 이유를 안다
- [ ] W = 0 초기화의 문제(symmetry)를 설명할 수 있다
- [ ] 0.01×randn / 1.0×randn / Xavier로 초기화했을 때 tanh activation 분포가 어떻게 되는지 설명할 수 있다
- [ ] Xavier에서 $\sqrt{fan\_in}$으로 나누는 이유와 ReLU에서 He($\sqrt{fan\_in/2}$)를 쓰는 이유를 설명할 수 있다
- [ ] Batch Normalization 4단계 식을 쓸 수 있고, γ, β가 필요한 이유를 설명할 수 있다
- [ ] Internal Covariate Shift를 설명할 수 있다
- [ ] 4×4 예제에서 뉴런별(열 방향)로 평균/분산을 구해 정규화할 수 있다
- [ ] Batch / Layer / Instance / Group Norm의 정규화 범위 차이를 설명할 수 있다
- [ ] 10 class에서 초기 loss가 약 2.3이어야 하는 이유를 설명할 수 있다
- [ ] learning rate에 따른 loss curve 모양과 train/val accuracy gap의 의미를 설명할 수 있다
- [ ] hyperparameter를 log space에서 random search하는 것이 좋은 이유를 설명할 수 있다
- [ ] Train / Validation / Test의 역할과 test를 마지막에 한 번만 써야 하는 이유를 설명할 수 있다
- [ ] Early stopping과 모델 크기에 따른 overfitting을 error 곡선으로 설명할 수 있다