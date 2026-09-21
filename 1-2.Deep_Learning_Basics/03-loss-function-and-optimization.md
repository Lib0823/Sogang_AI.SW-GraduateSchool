# 딥러닝 기초 3주차 — Loss Functions and Optimization

> 강의자료: Lecture 3 (Loss Functions and Optimization) 전체 + Lecture 4 (Backpropagation and Neural Networks) 도입부
> 핵심 흐름: **Score 계산 → Loss로 W의 좋고 나쁨 측정 → Loss가 작아지는 방향으로 W 업데이트(Gradient Descent) → 여러 층이면 Backpropagation**

---

## 0. 지난 시간 복습

### 0.1 이미지 인식이 어려운 이유
- Viewpoint, Illumination, Deformation, Occlusion, Clutter, Intraclass Variation 등 변형이 너무 많음
- "눈이 두 개, 귀가 뾰족하면 고양이" 같은 **Rule-based 방식은 변형을 다 커버할 수 없음**
- 그래서 **Data-driven approach**로 감 → 데이터를 보고 분류기를 만드는 것이 Machine Learning임

### 0.2 kNN
- Nearest Neighbor: 학습 데이터 전부와 비교해서 가장 가까운 것의 class를 따라감
- k-Nearest Neighbor: 가장 가까운 k개를 찾아서 그들의 class(다수결)를 따라감
- 데이터 분할: train / validation / test (hyperparameter k는 validation으로 결정)

### 0.3 Linear Classifier
$$f(x, W) = Wx + b$$

- CIFAR-10 이미지 1장 = 32×32×3 = **3072차원 공간의 한 점**
- 3072차원 벡터 $\langle x_1, \dots, x_{3072} \rangle$ (이미지)를 10차원 벡터 $\langle s_1, \dots, s_{10} \rangle$ (score)로 mapping하는 함수를 만드는 것
- mapping 함수는 입력에 대한 1차 함수 $(W \cdot x + b)$ → W의 shape은 10×3072
- 한 축(픽셀 값)이 가질 수 있는 값: $2^8 = 256$ → 서로 다른 이미지 개수: $(2^8)^{3072}$

### 0.4 이번 시간 TODO
1. **Loss function 정의**: 현재 W가 학습 데이터에 대해 얼마나 좋은지(나쁜지)를 수치화
   - 바람직한 mapping 함수 = k번째 class 이미지가 들어오면 **상대적으로** $s_k$는 높고 나머지 score는 낮게 나오는 것
2. **Optimization**: 모든 학습 데이터에 대해 loss를 minimize하는 (W, b)를 효율적으로 찾는 방법

---

## 1. Loss Function 개요

- (W, b) = mapping function = classifier
- **Loss = 내가 원하는 값(정답)과 현재 계산된 값 사이의 차이**
- **학습 = Loss가 작아지는 방향으로 W를 바꿔나가는 것**

데이터셋 $\{(x_i, y_i)\}_{i=1}^{N}$ ($x_i$: 이미지, $y_i$: 정수 label)에 대해 전체 loss는 각 샘플 loss의 평균임:

$$L = \frac{1}{N} \sum_{i} L_i(f(x_i, W), y_i)$$

→ 개별 샘플의 loss $L_i$를 구하는 대표적인 방법 두 가지
- ① **SVM Loss** (Hinge loss, Max-margin loss)
- ② **Softmax Loss** (Cross-entropy loss)

---

## 2. Multiclass SVM Loss (Hinge Loss)

### 2.1 아이디어
- 정답 class의 score $s_{y_i}$가 다른 class의 score $s_j$보다 **일정 값(margin, Δ) 이상 크면 loss = 0**
- 그렇지 않으면 그 부족한 만큼 $(s_j + 1) - s_{y_i}$를 loss로 봄
- 어떤 이미지의 loss = 그 이미지가 **속하지 않는 class들의 loss를 전부 합한 값**
- "아슬아슬하게 높은 건 높은 게 아니다. **확실하게** 높아야 한다" → 이게 margin의 의미
  - 정답 score = 20, 다른 class score = 20 이면 엄밀히는 이긴 게 아님 → 최소 +1(margin)은 차이가 나야 loss가 없음

### 2.2 수식
$$L_i = \sum_{j \neq y_i} \begin{cases} 0 & \text{if } s_{y_i} \geq s_j + 1 \\ s_j - s_{y_i} + 1 & \text{otherwise} \end{cases} = \sum_{j \neq y_i} \max(0,\ s_j - s_{y_i} + 1)$$

- $s = f(x_i, W)$: score 벡터
- 그래프 모양(x축 $s_{y_i}$, $s_j$ 고정): $s_{y_i}$가 $s_j + 1$ 이상이 되면 loss가 0으로 평평해지는 "경첩(hinge)" 모양 → **Hinge loss**

### 2.3 계산 예제 (3 class, 3 이미지)

| | cat 이미지 | car 이미지 | frog 이미지 |
|---|---|---|---|
| cat score | **3.2** | 1.3 | 2.2 |
| car score | 5.1 | **4.9** | 2.5 |
| frog score | -1.7 | 2.0 | **-3.1** |
| **Loss** | **2.9** | **0** | **12.9** |

- cat 이미지: $\max(0, 5.1 - 3.2 + 1) + \max(0, -1.7 - 3.2 + 1) = 2.9 + 0 = 2.9$
- car 이미지: $\max(0, 1.3 - 4.9 + 1) + \max(0, 2.0 - 4.9 + 1) = 0 + 0 = 0$
- frog 이미지: $\max(0, 2.2 + 3.1 + 1) + \max(0, 2.5 + 3.1 + 1) = 6.3 + 6.6 = 12.9$
- 전체 loss: $L = (2.9 + 0 + 12.9) / 3 = \mathbf{5.27}$
  → 현재 (W, b)가 학습 데이터에 대해 얼마나 좋은 mapping 함수인지를 나타내는 값

### 2.4 SVM Loss 관련 Q&A (시험 대비)

| 질문 | 답 |
|---|---|
| Q1. car 이미지에서 car score(4.9)가 조금 바뀌면? | **변화 없음**. 이미 다른 class보다 margin 이상 크기 때문 |
| Q2. loss의 min/max는? | **Min = 0** (정답 score가 모든 class보다 margin 이상 클 때), **Max = ∞** |
| Q3. 초기화 시 W가 작아서 모든 s ≈ 0이면 loss는? | **(class 수) − 1**. 각 항이 $\max(0, 0 - 0 + 1) = 1$이고 정답 제외 C−1개를 더하므로. 학습 초기 sanity check 용도 |
| Q4. 정답 class($j = y_i$)까지 포함해서 합하면? | 모든 loss가 1씩 커짐(min이 1이 됨). 정답 class를 빼는 이유는 **최소 loss를 0으로 만들기 위해서** |
| Q5. sum 대신 mean을 쓰면? | 달라지는 것 없음. **loss 값의 scale만** 바뀜 |
| Q6. $\max(0, s_j - s_{y_i} + 1)^2$ 을 쓰면? | **다른 loss function**이 됨. 차이가 크면 훨씬 더 큰 벌점을 주는 non-linear 방식으로 good/bad (W, b)를 판별 |

### 2.5 margin "1"에 대해
- loss는 **상대적인 값(difference)** 으로 계산함 → score의 절대값이 아니라 차이가 중요
- W가 scale-up되면 score 차이도 같이 커지므로 "1"은 상대적으로 매우 작은 수가 될 수 있음 → margin 값 자체는 크게 의미가 없고 W의 크기와 함께 봐야 함 (→ 3장 Regularization으로 연결)

### 2.6 Vectorized 구현
```python
def L_i_vectorized(x, y, W):
    scores = W.dot(x)
    margins = np.maximum(0, scores - scores[y] + 1)
    margins[y] = 0          # 정답 class는 예외 처리
    loss_i = np.sum(margins)
    return loss_i
```
- 전체를 vector 연산으로 한 번에 처리한 뒤, **예외(정답 class 항)만 따로 0으로 처리**하는 패턴
- CIFAR-10의 경우 scores의 shape: **(10, 1)**

---

## 3. Regularization

### 3.1 문제 제기: L = 0인 W는 유일한가?
- **아님.** L = 0인 W를 찾았다면 **2W도 L = 0**임
  - car 이미지 예: W 기준 $\max(0, 1.3 - 4.9 + 1) + \max(0, 2.0 - 4.9 + 1) = 0$
  - 2W 기준 $\max(0, 2.6 - 9.8 + 1) + \max(0, 4.0 - 9.8 + 1) = 0$
- 그럼 loss를 0으로 만드는 W가 여러 개일 때 **어떤 W가 좋은 W인가?**
- 목적은 training 데이터의 loss를 줄이는 게 아니라 **test 데이터(unknown 데이터)에 대한 loss를 줄이는 W를 찾는 것**임

### 3.2 W의 크기가 크면 생기는 문제
$$\begin{bmatrix}1&2\\3&4\end{bmatrix}\begin{bmatrix}2\\3\end{bmatrix}=\begin{bmatrix}8\\18\end{bmatrix}, \quad \begin{bmatrix}2&4\\6&8\end{bmatrix}\begin{bmatrix}2\\3\end{bmatrix}=\begin{bmatrix}16\\36\end{bmatrix}$$

- W 안의 숫자가 크면 score 값도 크게 나오고 score 차이도 커짐 → W가 특정 학습 데이터에 과하게 fitting됨
- W에 0이 많으면 W가 0인 차원의 입력은 score에 **반영이 안 됨** → 특정 차원 데이터만 보고 판단함
- **좋은 W = 모든 차원의 데이터를 골고루 반영하는, 작은 숫자들이 고르게 퍼져 있는 W**
  - 예: [1000, 5]보다 [15, 5]처럼 작고 고르게 퍼진 값이 좋음

### 3.3 Full Loss = Data Loss + Regularization Loss
$$L(W) = \underbrace{\frac{1}{N} \sum_{i=1}^{N} L_i(f(x_i, W), y_i)}_{(1)\ \text{Data loss}} + \underbrace{\lambda R(W)}_{(2)\ \text{Regularization loss}}$$

- (1) Data loss: 학습 데이터에 대한 score가 정답과 얼마나 차이 나는지 (모델 예측이 학습 데이터에 맞도록)
- (2) Regularization loss: **W 자체가 얼마나 좋은(simple한) 형태인지** → 학습 데이터에 너무 딱 맞지 않도록 막아줌
- $\lambda$ = regularization strength (**hyperparameter**)

### 3.4 Occam's Razor
> "Among competing hypotheses, the simplest is the best" — William of Ockham

- 곡선: 학습 데이터에는 perfect하지만 test 데이터에는 error가 많음 (overfitting)
- 직선: 학습 데이터에 약간 error가 있지만 단순해서 더 **generalize**되어 있음 → 미래에 들어오는 데이터에 더 잘 맞을 수 있음
- → 될 수 있으면 **"Simple"한 W를 사용**하자. 그래야 test data 성능이 좋음

### 3.5 λ의 효과

| λ | 효과 | training error | validation error |
|---|---|---|---|
| 작게 | W가 학습 데이터에 **overfitting** | 작아짐 | 커짐 |
| 크게 | **generalization** 됨 | 커짐 | 작아짐 |

- 단, λ 비중을 **너무 크게** 두면 data loss(score)는 신경 안 쓰고 W를 작게 만드는 데만 집중하게 됨 → **분류기가 제대로 동작하지 않음**
- 즉 generalization = 학습 데이터에 딱 맞추지 않고 범용적으로 **일부러 덜 맞추게** 만드는 것

### 3.6 Regularization 종류

| 종류 | 수식 | 의미 |
|---|---|---|
| **L2 regularization** (Weight Decay) | $R(W) = \sum_k \sum_l W_{k,l}^2$ | W의 모든 원소를 제곱해서 더함. element 값들이 **얼마나 잘 spread되었나** |
| **L1 regularization** | $R(W) = \sum_k \sum_l \lvert W_{k,l} \rvert$ | model complexity를 **non-zero element 개수**로 봄 (sparse한 W 유도) |
| Elastic net (L1 + L2) | $R(W) = \sum_k \sum_l \beta W_{k,l}^2 + \lvert W_{k,l} \rvert$ | 둘의 조합 |
| Max norm regularization | | 이후 강의 |
| Dropout | | 이후 강의 |
| Fancier | Batch normalization, stochastic depth | 이후 강의 |

### 3.7 L2 Regularization 예제
- $x = [1, 1, 1, 1]$
- $w_1 = [1, 0, 0, 0]$, $w_2 = [0.25, 0.25, 0.25, 0.25]$
- $w_1^T x = w_2^T x = 1$ → **data loss(score)는 동일**
- $R(w_1) = 1^2 = 1$, $R(w_2) = 0.25^2 \times 4 = 0.25$ → **regularization loss는 $w_2$가 더 작음**
- 따라서 **$w_2$가 더 좋은(simple, generalized) W**임
  - 이유: $w_1$은 입력의 첫 번째 차원 값 하나로 score가 결정되지만, $w_2$는 **입력 데이터의 모든 차원 값을 반영**해서 score를 계산하기 때문

---

## 4. Softmax Loss (Cross-Entropy Loss)

### 4.1 아이디어
- SVM loss는 score 자체를 보고 margin으로 loss를 구함
- Softmax loss는 **score를 확률 분포로 바꾼 뒤, 정답 확률 분포와 예측 확률 분포 사이의 차이**를 loss로 봄
- score = **unnormalized log probabilities** of the classes 로 해석
- Softmax Classifier = Multinomial Logistic Regression

### 4.2 Softmax 함수
$$P(Y = k \mid X = x_i) = \frac{e^{s_k}}{\sum_j e^{s_j}}, \quad s = f(x_i; W)$$

- 입력 데이터 $x_i$가 k class에 속한다고 분류될 (현재 W로 계산된) **확률**
- 결과는 0 ~ 1 사이 값이고 합이 1인 확률 분포가 됨

**왜 지수함수 $e^x$를 쓰나**
1. **미분이 쉬움** ($\frac{d}{dx}e^x = e^x$) → gradient 계산(역전파)에 유리
2. **큰 값은 더 크게, 작은 값은 더 작게** → class 간 구별을 극단적으로 뚜렷하게 만듦
   - 입력 차이가 k 나면 softmax 확률 비율은 $e^k$배 차이 남
   - 예: $(3, 1, 1, 1) \rightarrow (0.7, 0.1, 0.1, 0.1)$. 3이 전체에서 차지하는 비중은 0.5인데 softmax 후에는 0.7이 됨

### 4.3 Loss 정의 (Negative Log Likelihood)
정답 class의 log likelihood를 maximize = negative log likelihood를 minimize

$$L_i = -\log P(Y = y_i \mid X = x_i) = -\log\left(\frac{e^{s_{y_i}}}{\sum_j e^{s_j}}\right)$$

- softmax 출력은 $0 \le x \le 1$ 이므로 $-\log(x)$ 그래프에서 **0 < x ≤ 1 구간만** 고려하면 됨
  - 정답 확률 → 1 이면 loss → 0
  - 정답 확률 → 0 이면 loss → ∞

### 4.4 Cross Entropy와의 관계
두 확률 분포 사이의 불일치(dissimilarity)를 재는 척도:

$$H(p, q) = -\sum_x p(x) \log q(x)$$

- p: 정답(true) 분포, q: 모델이 예측한(estimated) 분포
- 분류 문제에서 p는 **one-hot** (정답만 1, 나머지 0) → 정답 class 항만 남음

$$H(p, q) = -1 \times \log \frac{e^{s_k}}{\sum_j e^{s_j}} \quad \text{(정답 class의 예측 확률만 고려)}$$

**예제 (4 class)**
- p (정답) = $\langle 0, 1, 0, 0 \rangle$, q (예측) = $\langle 0.2, 0.5, 0.1, 0.2 \rangle$
- $H = -(0 \times \log 0.2 + 1 \times \log 0.5 + 0 \times \log 0.1 + 0 \times \log 0.2) = -\ln 0.5 \approx 0.693$
- → **2개 확률 분포 사이의 cross-entropy(dissimilarity)를 minimize하자** 가 Softmax loss의 목표

**예제 (정답이 one-hot이 아닌 경우)**
- 주머니에 빨강 8, 초록 1, 노랑 1 → 실제 분포 = {0.8, 0.1, 0.1}
- 모델 A 예측 {0.2, 0.2, 0.6}: $H = -[0.8 \ln 0.2 + 0.1 \ln 0.2 + 0.1 \ln 0.6] \approx 1.5$
- 모델 B 예측 {0.7, 0.2, 0.1}: $H = -[0.8 \ln 0.7 + 0.1 \ln 0.2 + 0.1 \ln 0.1] \approx 0.68$
- 실제 분포에 가까운 모델 B의 cross entropy가 더 작음

### 4.5 계산 예제 (cat 이미지)

| | score (unnormalized log prob.) | exp (unnormalized prob.) | normalize (prob.) |
|---|---|---|---|
| cat (정답) | 3.2 | 24.5 | **0.13** |
| car | 5.1 | 164.0 | 0.87 |
| frog | -1.7 | 0.18 | 0.00 |

- $L_i = -\ln(0.13) \approx \mathbf{2.04}$ (밑이 10인 log로 계산하면 0.89)
- 딥러닝에서 log는 보통 **자연로그(ln)** 기준임

### 4.6 Softmax Loss 관련 Q&A

| 질문 | 답 |
|---|---|
| Q1. $L_i$의 min/max는? | **Min = 0**: 분자 = 분모인 경우. 정답 class만 score가 매우 크고 나머지는 상대적으로 무시 가능한 경우 (예: 정답 ⟨0,0,1,0⟩, 예측 score ⟨0,0,500,0⟩ → 확률 ≈ ⟨0,0,1,0⟩). 이론적으로는 0에 한없이 가까워질 뿐 정확히 0은 안 됨 |
| | **Max = ∞**: 정답 class score가 상대적으로 엄청 작아 예측 확률이 거의 0인 경우 (예: 예측 score ⟨500,500,0.5,500⟩ → 확률 ≈ ⟨0.33,0.33,0,0.33⟩) |
| Q2. 초기화 시 W가 작아서 모든 s ≈ 0이면 loss는? | $-\log \frac{e^0}{\sum_j e^0} = -\log \frac{1}{C} = \log C$ (C: class 수). CIFAR-10이면 $\ln 10 \approx 2.3$ → 학습 시작 시 sanity check |

### 4.7 SVM vs Softmax 한 장 비교 예제
$W$ (3×4), $x_i = [-15, 22, -44, 56]$, $b = [0.0, 0.2, -0.3]$, 정답 $y_i = 2$

- score = $Wx_i + b = [-2.85,\ 0.86,\ 0.28]$ → 정답 class score = **0.28**
- **Hinge loss (SVM)**: $\max(0, -2.85 - 0.28 + 1) + \max(0, 0.86 - 0.28 + 1) = 0 + 1.58 = \mathbf{1.58}$
- **Cross-entropy loss (Softmax)**:
  - exp: [0.058, 2.36, 1.32] → normalize: [0.016, 0.631, 0.353]
  - $L_i = -\ln(0.353) \approx \mathbf{1.04}$ (밑이 10이면 0.452)

---

## 5. SVM Loss vs Softmax Loss

$$\text{Softmax: } L_i = -\log\left(\frac{e^{s_{y_i}}}{\sum_j e^{s_j}}\right) \qquad \text{SVM: } L_i = \sum_{j \neq y_i} \max(0,\ s_j - s_{y_i} + 1)$$

**Q. 데이터 포인트를 살짝 흔들어서 score가 조금 바뀌면 loss는?**
(scores = [10, -2, 3], [10, 9, 9], [10, -100, -100], 정답 $y_i = 0$)
- **SVM Loss: 변하지 않음.** 정답 score가 이미 다른 class보다 margin 이상 크기 때문 (정답 score가 10 → 11이 돼도 그대로 0)
- **Softmax Loss: 계속 변함.** 항상 다른 class와의 상대적 비율을 보기 때문

**차이점의 본질: score S를 어떻게 해석하느냐**

| | SVM Loss | Softmax Loss |
|---|---|---|
| score 해석 | class score | 각 class의 (unnormalized) log probability |
| 목표 | 정답 score가 다른 class보다 **margin만큼만** 더 크게 | 정답 class의 log probability를 **계속** 높임 |
| 다른 class score | margin보다 작기만 하면 **실제 값은 신경 안 씀** | 다른 class score가 변하면 정답 확률도 변함. **항상 상대 비율을 고려** |
| 한 줄 요약 | "margin 넘으면 만족" | "확률 1이 될 때까지 불만족" |

- loss 계산 방법은 이 두 가지 외에도 여러 가지가 있음 (Multiclass SVM만 해도 Weston Watkins 1999, One vs. All, Structured SVM 등의 formulation이 있음)

### Recap
- 데이터셋 (x, y)가 있고
- score function $s = f(x; W) = Wx$ 가 있고
- loss function (Softmax 또는 SVM)이 있음
- **Full loss**: $L = \frac{1}{N} \sum_{i=1}^{N} L_i + R(W)$
- 흐름: $x_i, W$ → score function → $f(x_i, W)$ → data loss ($y_i$와 비교) + regularization loss (W) → L

→ 그럼 **best W는 어떻게 찾나?** → Optimization

**Linear classifier의 한계**: 결정 경계가 직선(초평면)이라 class 영역이 선형으로 나뉘지 않는 데이터는 정확히 못 나눔 → Non-linear function(Neural Network)이 필요한 이유

---

## 6. Optimization

### 6.1 Mapping 함수와 Loss의 관계
- Mapping function
  - ① Linear function: $Wx$
  - ② Non-linear function: (deep) Neural Network ($W_1, W_2, W_3, \dots$)
- SVM/Softmax loss = mapping function의 **현재 parameter**로 산출된 분류 성능이 얼마나 좋은지 측정하는 방법
- **(Fully-Connected) Single Layer Neural Network** 로 보면
  - 입력 뉴런 $x_1 \sim x_{3072}$ 각각이 출력 뉴런 $s_1 \sim s_{10}$ 전부와 $W_{k,l}$로 연결됨
  - 출력 뉴런의 값 = 연결된 입력 × W를 모두 더한 값 (= 뉴런의 activation 값)
  - 행렬로 쓰면 $W_{10 \times 3072} \times x_{3072} = s_{10}$

### 6.2 Loss Space
- **Q. CIFAR-10 문제에서 loss space는 몇 차원인가?** (입력 X에 대해 loss를 결정하는 파라미터는?)
  - loss는 W에 의해 결정됨 → W의 원소 개수 **10 × 3072개 축** + **loss 값 축 1개** → **(10 × 3072) + 1 차원**
- 이 고차원 loss space(산악 지형)에서 **가장 낮은 곳(loss 최소)을 찾는 것**이 Optimization임
- W 안의 숫자가 너무 많아서 모든 조합을 다 해볼 수는 없음

### 6.3 Strategy #1: Random Search (매우 나쁜 방법)
```python
bestloss = float("inf")
for num in xrange(1000):
    W = np.random.randn(10, 3073) * 0.0001   # 랜덤 파라미터 생성 (bias 포함 3073)
    loss = L(X_train, Y_train, W)             # 전체 학습 데이터에 대한 loss
    if loss < bestloss:
        bestloss = loss
        bestW = W
```
- 랜덤하게 W를 1000번 만들어서 가장 loss가 작은 걸 고름
- test 정확도 **15.5%** (랜덤 추측 10%보다 약간 나은 수준, SOTA는 ~95%) → 성능이 별로임

### 6.4 Strategy #2: Follow the Slope (경사를 따라 내려가기)
- 눈 가리고 산에서 내려가는 상황: 발밑의 **경사가 내려가는 방향**으로 한 발씩 이동
- 1차원 미분:
$$\frac{df(x)}{dx} = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$$
- 다차원에서 **gradient** = 각 차원 방향의 편미분(partial derivative)을 모은 벡터
- 임의 방향으로의 기울기 = 그 방향 벡터와 gradient의 **dot product**
- **가장 가파르게 내려가는 방향 = negative gradient**

### 6.5 Numerical Gradient
W의 각 원소에 아주 작은 h(=0.0001)를 더해 loss 변화량으로 기울기를 근사함

| | current W | W + h (1st dim) | W + h (2nd dim) | W + h (3rd dim) |
|---|---|---|---|---|
| 1st | 0.34 | **0.3401** | 0.34 | 0.34 |
| 2nd | -1.11 | -1.11 | **-1.1099** | -1.11 |
| 3rd | 0.78 | 0.78 | 0.78 | **0.7801** |
| loss | 1.25347 | 1.25322 | 1.25353 | 1.25347 |
| gradient | | $\frac{1.25322 - 1.25347}{0.0001} = \mathbf{-2.5}$ | $\frac{1.25353 - 1.25347}{0.0001} = \mathbf{0.6}$ | $\frac{1.25347 - 1.25347}{0.0001} = \mathbf{0}$ |

- 해석: 1번째 원소를 키우면 loss가 줄어듦(-2.5), 2번째는 키우면 loss가 늘어남(0.6), 3번째는 영향 없음(0)
- 문제: 원소가 30,720개면 loss를 30,720번 계산해야 함 → **느림**, 그리고 h가 0이 아니므로 **근사값**

### 6.6 Analytic Gradient
- loss는 결국 **W의 함수**임:
$$L = \frac{1}{N} \sum_{i=1}^{N} L_i + \sum_k W_k^2, \quad L_i = \sum_{j \neq y_i} \max(0, s_j - s_{y_i} + 1), \quad s = f(x; W) = Wx$$
- 원하는 것은 $\nabla_W L$ = **W가 변함에 따라 L이 어떻게 변하나**
- 미적분(Calculus, 뉴턴·라이프니츠)으로 dW 식을 직접 유도하면 한 번에 정확한 gradient를 구할 수 있음

### 6.7 Numerical vs Analytic

| | Numerical gradient | Analytic gradient |
|---|---|---|
| 정확도 | approximate (근사) | exact (정확) |
| 속도 | slow | fast |
| 구현 | easy to write | error-prone (유도·구현 실수 가능) |

- **In practice**: 항상 analytic gradient를 쓰되, 구현이 맞는지 numerical gradient로 검증함 → **Gradient Check**

### 6.8 Gradient Descent
```python
# Vanilla Gradient Descent
while True:
    weights_grad = evaluate_gradient(loss_fun, data, weights)
    weights += - step_size * weights_grad   # parameter update
```
- **새 W = 기존 W − learning rate × gradient**
- gradient 반대 방향(loss가 줄어드는 방향)으로 조금씩 이동
- step_size = **learning rate (lr)**, 대표적인 hyperparameter

**Learning rate 크기의 영향** ($f(x) = x^2 \sin x$ 예)
- 적당히 작음(0.005): 곡선을 따라 차근차근 내려가서 최소점에 **수렴(Convergence)**
- 너무 큼(0.05): 최소점 근처에서 왔다갔다 튐 → 제대로 수렴 못 하고 **발산(Divergence)** 위험

### 6.9 Local Minimum과 Saddle Point
- loss space는 울퉁불퉁한 지형이라 **재수 없으면 Local Minimum(골짜기)에 빠질 수밖에 없음**
- **Global Minimum**: 전체에서 가장 낮은 점 (진짜 원하는 곳)
- **Local Minimum**: 주변보다는 낮지만 전체 최저는 아닌 점 → gradient = 0이라 빠져나오지 못함
- **Saddle Point**: 한 방향으로는 내려가고 다른 방향으로는 올라가는 말 안장 모양 → gradient ≈ 0이라 멈춰버림

**핵심 정리**
- 학습 데이터 전체에 대한 loss를 최소로 하는 W를 모든 조합으로 찾을 수는 없음 (W가 너무 많음)
- 그래서 쓰는 방법 = **랜덤한 위치에서 시작해서 loss가 작아지는 방향으로 계속 이동**
- 이건 **Optimum(최적해)을 찾는다는 보장이 없는 방법**이고, 실제로는 **Sub-optimum**을 찾는 것임
- 이를 보완하려고 Momentum, NAG, AdaGrad, AdaDelta, RMSProp, Adam 같은 개선된 optimizer들이 나옴 (Momentum은 관성으로 local minimum/saddle point를 넘어가고 SGD의 지그재그 진동을 줄여줌)

---

## 7. Batch / Stochastic / Mini-batch Gradient Descent

### 7.1 왜 필요한가
$$L(W) = \frac{1}{N} \sum_{i=1}^{N} L_i(x_i, y_i, W) + \lambda R(W)$$
$$\nabla_W L(W) = \frac{1}{N} \sum_{i=1}^{N} \nabla_W L_i(x_i, y_i, W) + \lambda \nabla_W R(W)$$

- N이 크면 전체 합을 매번 계산하는 게 너무 비쌈 (Full sum expensive)
- → **minibatch**로 일부만 뽑아 합을 근사함. 보통 **32 / 64 / 128** (많이 쓰는 범위 32 ~ 256)

```python
# Vanilla Minibatch Gradient Descent
while True:
    data_batch = sample_training_data(data, 256)   # 256개 샘플
    weights_grad = evaluate_gradient(loss_fun, data_batch, weights)
    weights += - step_size * weights_grad
```

### 7.2 세 가지 방식 = W를 업데이트하는 주기의 차이

| 방식 | gradient 계산 단위 | 업데이트 주기 | 특징 |
|---|---|---|---|
| **Batch GD** | 모든 학습 데이터의 gradient를 구해 합산 | 학습 데이터 **전체**에 대해 1회 | 궤적이 매끄럽고 안정적, 메모리 많이 필요, 업데이트가 느림 |
| **Stochastic GD (SGD)** | 학습 데이터 **1개** | 학습 데이터 1개마다 1회 | 빠르지만 궤적이 심하게 흔들림(fluctuation) |
| **Mini-batch GD** | 학습 데이터의 **일부(mini-batch)** | mini-batch마다 1회 | 메모리 적게 쓰고 흔들림도 적음. batch size는 HW(GPU 메모리)에 따라 결정 |

- 예: 학습 데이터 100만 개 → Batch는 100만 개 보고 **1번** 업데이트, SGD는 **100만 번** 업데이트

**Q. CIFAR-10 학습 데이터 50,000개를 1번씩(1 epoch) 학습시키면 W는 몇 번 update되나?**
- (a) Batch GD: **1번**
- (b) Mini-batch GD (size 500): 50,000 / 500 = **100번**
- (c) Stochastic GD: **50,000번**

### 7.3 Trade-off
- **Epoch당 계산 자원(Computational resource per epoch)**: Stochastic < Mini-batch < Batch (한 번에 보는 데이터가 많을수록 큼)
- **좋은 W, b를 찾는 데 필요한 epoch 수**: Stochastic < Mini-batch < Batch (업데이트를 자주 할수록 적은 epoch로 도달)
- gradient는 하나의 데이터(혹은 mini-batch)에 대해 계산하지만, loss는 전체 데이터에 대한 것을 줄이는 게 목표임 → SGD/Mini-batch는 전체 gradient의 **근사**라서 궤적이 흔들림

---

## 8. Snapshot Ensemble과 Cyclic Learning Rate (참고)
- 독립적인 모델 여러 개를 학습시키는 대신, **하나의 모델을 학습하는 도중의 여러 snapshot**을 ensemble로 사용
- Standard LR schedule: 하나의 minimum으로 쭉 수렴
- **Cyclic LR schedule** (Cosine annealing with restart): learning rate를 주기적으로 다시 키워서 현재 local minimum을 빠져나와 다른 minimum으로 이동 → 각 minimum에서의 모델(snapshot)을 모아 ensemble
- 참고 논문: Loshchilov & Hutter, "SGDR: Stochastic gradient descent with restarts" (2016) / Huang et al., "Snapshot ensembles: train 1, get M for free" (ICLR 2017)

---

## 9. Image Features vs ConvNets

### 9.1 Feature Transform의 동기
- 원래 좌표 (x, y)에서는 빨강/파랑 점이 동심원 모양이라 **linear classifier로 분리 불가**
- 극좌표 변환 $f(x, y) = (r(x, y), \theta(x, y))$ 를 적용하면 **linear classifier로 분리 가능**
- → 원본 픽셀 대신 **특징(feature)을 뽑아서** 분류기에 넣자는 아이디어

### 9.2 Hand-crafted Feature 예시
- **Color Histogram**: 각 픽셀의 색(hue)을 구간(bin)별로 세서 히스토그램 생성
- **HoG (Histogram of Oriented Gradients)**: 이미지를 8×8 픽셀 영역으로 나누고, 영역마다 edge 방향을 9개 bin으로 양자화
  - 예: 320×240 이미지 → 40×30 bin, bin당 9개 숫자 → feature vector = 30 × 40 × 9 = **10,800개** 숫자
- **Bag of Words (BoW)**
  - Step 1: 이미지들에서 random patch를 뽑아 clustering → "visual words" **codebook** 생성
  - Step 2: 각 이미지를 codebook의 visual word 등장 빈도 히스토그램으로 encoding

### 9.3 기존 방식 vs CNN

| | 기존 방식 | CNN (ConvNets) |
|---|---|---|
| Feature Extraction | 사람이 설계한 **Hand-craft** 방법 (BoW, HoG, Color Histogram) | **학습으로 생성** |
| Classifier | 학습으로 생성 | 학습으로 생성 |
| 학습 범위 | classifier만 training | 이미지 → score **전체(end-to-end)** training |
| 한계 | feature가 학습 데이터의 특성을 반영하지 못함 | |

- 핵심 차이: **어떤 특징을 끄집어낼지를 학습을 통해 알아낸다는 것**
- 옛날 Rule-based/Hand-craft 방식은 사람이 직접 특징을 정의했음

---

## 10. Neural Network 학습과 Backpropagation 도입

### 10.1 왜 Backpropagation이 필요한가
- 학습의 기본 흐름: 입력에 W를 곱해 score 계산 → 원하는 값과의 차이(loss) 계산 → 그 차이가 작아지는 방향으로 W 수정
- **출력층에 직접 연결된 W**는 score에 직접 영향을 주므로 loss에 얼마나 영향을 줬는지 바로 계산 가능
- 하지만 층이 여러 개면 **아래(앞쪽) layer의 W는 loss에 얼마나 영향을 줬는지 직접 계산할 수 없음**
- → 출력층의 오류를 **뒤(입력 방향)로 전달**하면서 각 W의 영향도(gradient)를 계산하는 방법이 필요 = **(Error) Backpropagation**
  - "Error back propagation" = 에러가 작아지는 방향으로 W를 고치기 위해 에러를 뒤로 전파한다는 의미

### 10.2 목표
$$s = f(x; W) = Wx, \quad L_i = \sum_{j \neq y_i} \max(0, s_j - s_{y_i} + 1), \quad L = \frac{1}{N} \sum_{i=1}^{N} L_i + \underbrace{\sum_k W_k^2}_{\text{L2 Reg.}}$$

- 원하는 것: $\nabla_W L$
- Backpropagation = **chain rule을 재귀적으로 적용**해서 식(expression)의 gradient를 계산하는 방법
- $\nabla f(x)$: 해당 변수에 대한 함수의 변화율. 각 변수에 대한 미분값 = 전체 식이 그 변수 값에 얼마나 **민감한지(sensitivity)**
- 기호: $\nabla$ = nabla (gradient, 편미분들을 모은 벡터), $\partial$ = del (편미분 기호)

### 10.3 Backpropagation 4단계
1. **순전파 (Forward pass)**: 입력을 신경망에 넣어 예측값 계산 (입력 → 출력)
2. **손실 계산**: 예측값과 정답의 차이를 손실함수로 계산
   - 예: $L = (\hat{y} - y)^2$, $\hat{y} = 0.7$, $y = 1$ → $L = (0.7 - 1)^2 = 0.09$
3. **역전파 (Backward pass)**: 손실이 각 가중치에 얼마나 영향을 받는지(기울기, $\partial L / \partial w$)를 **출력층에서 입력층 방향으로** chain rule로 계산
   $$\frac{\partial L}{\partial w} = \frac{\partial L}{\partial a} \cdot \frac{\partial a}{\partial z} \cdot \frac{\partial z}{\partial w}$$
4. **가중치 업데이트 (경사하강법)**
   $$w_{new} = w_{old} - \eta \frac{\partial L}{\partial w} \quad (\eta: \text{학습률, 예: } 0.01)$$
   - 학습률 = 얼마나 크게 수정할지, 기울기 = 이 가중치가 손실에 얼마나 영향을 줬는지
- 1~4를 많은 데이터에 대해 수천~수만 번 반복하면 손실이 줄고 예측이 정답에 가까워짐 (예: 고양이 확률 0.3 → 0.98)

**핵심 아이디어**
- "어떤 가중치가 얼마나 책임이 있는지"를 계산해서 **그 책임만큼** 가중치를 수정하는 것
- 모든 가중치를 똑같이 바꾸는 게 아니라, **출력에 더 큰 영향을 준 연결일수록 더 크게 조정**됨
- 비유: 회사에서 문제가 생겼을 때 최종 결과의 문제를 **각 부서와 담당자의 영향 정도에 따라 거꾸로 추적**하는 것

### 10.4 역전파 계산 예제 ("오류 나누기")

**문제 설정**
- 입력 $x = 1.0$, 정답 $y = 0$
- 은닉층 뉴런 2개($h_1, h_2$), 출력층 1개
- 활성화 함수: sigmoid $\sigma(z)$, 손실함수: $L = \frac{1}{2}(\hat{y} - y)^2$
- 초기 가중치: $w_1 = 0.5$ ($x \to h_1$), $w_2 = -0.4$ ($x \to h_2$), $w_3 = 0.7$ ($h_1 \to \hat{y}$), $w_4 = 0.2$ ($h_2 \to \hat{y}$)

**① 순전파**
- $h_1 = \sigma(0.5 \times 1.0) = \sigma(0.5) = 0.622$
- $h_2 = \sigma(-0.4 \times 1.0) = \sigma(-0.4) = 0.401$
- $z_{out} = 0.7 \times 0.622 + 0.2 \times 0.401 = 0.516$
- $\hat{y} = \sigma(0.516) = \mathbf{0.626}$
- $L = \frac{1}{2}(0.626 - 0)^2 = 0.196$

**② 출력층의 오류 (기울기)** — sigmoid 미분 $\sigma'(z) = \sigma(z)(1 - \sigma(z))$ 사용
$$\delta_{out} = \frac{\partial L}{\partial z_{out}} = (\hat{y} - y) \cdot \hat{y}(1 - \hat{y}) = 0.626 \times 0.626 \times 0.374 = 0.147$$

**③ 오류를 은닉층으로 나누어 전달**
- 각 은닉 노드는 **자신이 출력에 미친 영향(w × 활성화 함수의 기울기)만큼** 오류를 받음
- $\delta_{h_1} = (w_3 \times \delta_{out}) \times h_1(1 - h_1) = (0.7 \times 0.147) \times 0.622 \times 0.378 = 0.024$
- $\delta_{h_2} = (w_4 \times \delta_{out}) \times h_2(1 - h_2) = (0.2 \times 0.147) \times 0.401 \times 0.599 = 0.007$

**④ 각 가중치의 기울기 (책임 분담)**
- $\frac{\partial L}{\partial w_3} = \delta_{out} \times h_1 = 0.147 \times 0.622 = 0.091$
- $\frac{\partial L}{\partial w_4} = \delta_{out} \times h_2 = 0.147 \times 0.401 = 0.059$
- $\frac{\partial L}{\partial w_1} = \delta_{h_1} \times x = 0.024$
- $\frac{\partial L}{\partial w_2} = \delta_{h_2} \times x = 0.007$

**⑤ 가중치 업데이트** ($\eta = 0.1$)

| 가중치 | 기울기 | 업데이트 | 새로운 값 |
|---|---|---|---|
| $w_1$ | 0.024 | $0.5 - 0.1 \times 0.024$ | 0.498 |
| $w_2$ | 0.007 | $-0.4 - 0.1 \times 0.007$ | -0.401 |
| $w_3$ | 0.091 | $0.7 - 0.1 \times 0.091$ | 0.691 |
| $w_4$ | 0.059 | $0.2 - 0.1 \times 0.059$ | 0.194 |

**⑥ 결과 확인**
- 업데이트된 가중치로 다시 순전파하면 $\hat{y}_{new} \approx 0.624$ (이전 0.626 → 정답 0 방향으로 작아짐)
- 한 번의 업데이트로는 변화가 작지만, 반복하면 점점 정답에 가까워짐
- 관찰 포인트: $w_3$(기울기 0.091)가 $w_1$(0.024)보다 크게 바뀜 → 출력에 가까운/영향이 큰 연결이 더 많은 책임을 짐

### 10.5 LLM도 같은 방식으로 학습함
- Large Language Model의 맨 끝 출력 뉴런은 보통 **Next Word Prediction**, 즉 다음 단어(토큰)들의 확률 값을 출력함
- 학습 데이터에서 실제 다음 단어는 1, 나머지는 0인 분포를 정답으로 두고 **loss(cross-entropy)를 계산해서 Backpropagation**으로 학습
- 결국 score에 영향을 미친 정도를 계산해서 **그 정도에 비례해서 W를 업데이트**하는 것이고, 지금의 모든 신경망 모델이 이 방법으로 학습함

### 10.6 다음 시간 예정 (Lecture 4 나머지)
- Computational Graph (Node = computation, Edge = data flow)로 임의의 식의 gradient 구하기
- $f(x, y, z) = (x + y)z$ 예제, local gradient × upstream gradient
- Sigmoid gate, add/max/mul gate의 backward 패턴, branch에서 gradient 합산
- 2-layer Neural Network ($f = W_2 \max(0, W_1 x)$) 구현, Activation functions (Sigmoid, tanh, ReLU, Leaky ReLU, Maxout, ELU)

---

## 11. 수식 요약

| 항목 | 수식 |
|---|---|
| Linear classifier | $f(x, W) = Wx + b$ |
| 전체 loss | $L = \frac{1}{N} \sum_i L_i(f(x_i, W), y_i) + \lambda R(W)$ |
| SVM (Hinge) loss | $L_i = \sum_{j \neq y_i} \max(0,\ s_j - s_{y_i} + 1)$ |
| Softmax 확률 | $P(Y = k \mid X = x_i) = \frac{e^{s_k}}{\sum_j e^{s_j}}$ |
| Softmax (Cross-entropy) loss | $L_i = -\log\left(\frac{e^{s_{y_i}}}{\sum_j e^{s_j}}\right)$ |
| Cross entropy | $H(p, q) = -\sum_x p(x) \log q(x)$ |
| L2 regularization | $R(W) = \sum_k \sum_l W_{k,l}^2$ |
| L1 regularization | $R(W) = \sum_k \sum_l \lvert W_{k,l} \rvert$ |
| Elastic net | $R(W) = \sum_k \sum_l \beta W_{k,l}^2 + \lvert W_{k,l} \rvert$ |
| 미분 정의 | $\frac{df(x)}{dx} = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$ |
| Gradient Descent | $W \leftarrow W - \eta \nabla_W L$ |
| Chain rule | $\frac{\partial L}{\partial w} = \frac{\partial L}{\partial a} \cdot \frac{\partial a}{\partial z} \cdot \frac{\partial z}{\partial w}$ |
| Sigmoid 미분 | $\sigma'(z) = \sigma(z)(1 - \sigma(z))$ |
| 초기 loss (sanity check) | SVM: $C - 1$ / Softmax: $\log C$ |

---

## 12. 셀프 체크리스트

- [ ] Loss와 학습의 관계를 한 문장으로 말할 수 있나? (loss가 작아지는 방향으로 W를 바꾸는 것)
- [ ] SVM loss에서 margin의 의미와, 정답 class를 합에서 빼는 이유를 설명할 수 있나?
- [ ] cat/car/frog 예제에서 SVM loss 2.9 / 0 / 12.9 / 평균 5.27을 직접 계산할 수 있나?
- [ ] 초기 W가 작을 때 SVM loss는 C−1, Softmax loss는 log C가 되는 이유를 설명할 수 있나?
- [ ] L = 0인 W가 유일하지 않은 이유(2W)와, 그래서 Regularization이 필요한 이유를 설명할 수 있나?
- [ ] λ를 작게/크게 할 때 training error와 validation error가 어떻게 변하나?
- [ ] L1과 L2 regularization이 각각 어떤 W를 선호하나? $w_1 = [1,0,0,0]$ vs $w_2 = [0.25,0.25,0.25,0.25]$ 에서 L2 기준 어느 쪽이 좋은가?
- [ ] Softmax에서 지수함수를 쓰는 이유 두 가지는?
- [ ] Cross entropy에서 정답이 one-hot이면 왜 정답 class 항만 남나?
- [ ] score 조금 변화 시 SVM loss와 Softmax loss의 반응 차이와 그 이유는?
- [ ] CIFAR-10 linear classifier의 loss space 차원은? ((10 × 3072) + 1)
- [ ] Numerical gradient와 Analytic gradient의 장단점, Gradient check의 의미는?
- [ ] Learning rate가 너무 크면 어떤 일이 생기나?
- [ ] Gradient descent가 optimum을 보장하지 못하는 이유(local minimum, saddle point)는?
- [ ] CIFAR-10 50,000개 1 epoch 기준 Batch / Mini-batch(500) / SGD 업데이트 횟수는? (1 / 100 / 50,000)
- [ ] Hand-crafted feature 방식과 CNN 방식의 차이는?
- [ ] 여러 층 신경망에서 Backpropagation이 필요한 이유는?
- [ ] 10.4 역전파 예제에서 $\delta_{out}$, $\delta_{h_1}$, 각 가중치 기울기를 직접 계산할 수 있나?