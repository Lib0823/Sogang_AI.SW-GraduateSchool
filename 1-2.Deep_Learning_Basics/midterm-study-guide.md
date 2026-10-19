# 딥러닝 기초 중간시험 — 완성 가이드

> **이 파일 하나로 끝냅니다.** 개념 → 기출 → 모범 답안이 전부 들어 있습니다.
> **범위**: **이번 학기에 실제로 배운 1~7주차 내용만** (AI·ML 소개 → K-NN·Linear → Loss·Optimization → Backprop·Training NN 1 → Fancier Optimization·Regularization·Transfer → Self-Supervised Learning)
> **기출**: 중간시험 5회분(2023.10 · 2024.10 · 2025.04 · 2025.10 · 2026.04) 중 **배운 범위의 문항만** + 배웠지만 아직 안 나온 내용의 **예상 문제**
> **분량**: 블록 1~9 = **약 4시간**
> **시험장 지참용 A4 2면**: [midterm-cheat-sheet.md](./midterm-cheat-sheet.md)
>
> 💡 **VSCode에서 `Cmd+Shift+V`(미리보기)로 보세요.** 모범 답안은 `▶`로 접혀 있습니다. 먼저 직접 써 본 뒤 펼치세요.

<br/>

## 0. 이 시험의 성격

**이 교수님은 같은 문제를 거의 그대로 다시 냅니다.** 그리고 **학기마다 진도가 달라서, 그 학기에 안 배운 내용은 나오지 않습니다.** 그래서 이 가이드는 두 종류의 문제로 구성됩니다.

| 표시 | 의미 | 대비 방법 |
|---|---|---|
| 📝 **기출** | 과거 중간에 나왔고 이번 학기에도 배운 내용 | **답안을 거의 외울 것** — 그대로 다시 나올 확률이 높음 |
| 🎯 **예상** | **수업 노트에 있는 내용** 중 과거 시험에 아직 출제되지 않은 것 (주로 6~7주차) | 키워드 수준으로 정리 — 새로 출제될 수 있는 영역 |

> "아직 안 나온" = **시험에 아직 출제되지 않은**이라는 뜻입니다. 🎯 내용도 전부 1~6주차 노트에 있는 내용입니다. 노트에 없는 보충 설명은 본문에 "노트 밖 보충"이라고 따로 표시했습니다.

### 기출 반복 빈도 (배운 범위만)

| 순위 | 주제 | 중간 출제 | 블록 |
|---|---|---|---|
| 1 | **Vanishing Gradient** 정의·해결 / ReLU | **5회** | 1, 6 |
| 2 | **Overfitting** / Train·Val gap / 학습 멈출 시점 | **5회** | 1, 2 |
| 3 | **차원의 저주** | **4회** | 3 |
| 4 | **Transfer Learning** (ImageNet fine-tuning) | 3회 | 3 |
| 5 | 고차원 → 저차원 변환해도 정보가 유지되는 **실제 데이터의 특성** | 3회 | 3 |
| 6 | **K-NN vs Linear** 학습 결과 | 3회 | 4 |
| 7 | 용어: **Program vs ML / Perceptron** | 3회씩 | 1 |
| 8 | **Loss 계산** (Softmax · SVM · 초기 loss) / **L(W)의 (1)(2) 역할** / λ | 4회 | 5 |
| 9 | **Train / Validation / Test** 역할 | 2회 | 2 |
| 10 | **Self-Supervised** (rotation · inpainting · contrastive) | 2회 (2025.10은 25점) | 8 |
| 11 | Backprop computational graph 빈칸 | 1회 | 6 |

> 💡 **같은 가을학기인 2025.10 시험**이 이번 시험과 진도가 가장 비슷합니다. 2025.10은 용어 7종(35점) + λ(10점) + 차원의 저주(10점) + **SSL(25점)** 이었습니다. **7주차 SSL은 반드시 나온다고 보세요.**

**시험 형태**: 전부 서술형 + 간단 계산. 문항당 3~5점짜리 소문항이 많습니다. **계산기 사용 가능.**

### 시간표

| 블록 | 주제 | 주차 | 시간 | 누적 |
|---|---|---|---|---|
| 1 | 단골 용어 서술 7종 | 1주 | 35분 | 0:35 |
| 2 | 학습 실전 — gap · early stopping · λ · train/val/test · hyperparameter | 4~5주 | 25분 | 1:00 |
| 3 | 차원의 저주 · 실제 데이터 특성 · Transfer Learning | 1·2·6주 | 25분 | 1:25 |
| 4 | K-NN · Linear Classifier | 2주 | 25분 | 1:50 |
| 5 | Loss · Regularization · Optimization 기초 | 3주 | 30분 | 2:20 |
| 6 | Backprop · Activation · 초기화 · BN · 전처리 | 4~5주 | 30분 | 2:50 |
| 7 | Fancier Optimization · Dropout · Regularization 표 | 6주 | 25분 | 3:15 |
| 8 | Self-Supervised · Contrastive · NLP SSL | 7주 | 30분 | 3:45 |
| 9 | 최종 점검 — 백지 테스트 | — | 15분 | **4:00** |

### 진행 규칙

```
① 문제를 보면 먼저 답을 종이에 씁니다. 그다음 ▶를 펼쳐 비교합니다.
② 서술형은 "키워드 3개"만 외우세요. 문장은 시험장에서 키워드로 풀어 쓰면 됩니다.
③ 서술형은 "정의 → 원인/이유 → 해결/예시" 3단 구조로 씁니다.
④ 계산 문제는 공식 → 대입 → 답 3줄. (식만 맞아도 부분점수)
⑤ ✍️ 표시는 A4 정리지에 들어간 내용입니다.
```

<br/>

---
---

<br/>

# 블록 1 — 단골 용어 서술 7종 ⏱ 35분 · 1주차

2023.10 · 2024.10 · 2025.10 중간에 **거의 같은 7문항 세트**(문항당 4~5점, 총 28~35점)로 나왔습니다. **시험의 1/3이 이 블록입니다.**

### 📝 1-1. 일반 program vs 기계 학습의 문제 해결 방법 `2023 · 2024 · 2025.10`

| | 입력 | 출력 |
|---|---|---|
| 일반 programming | 입력 데이터 + **program (사람이 작성한 rule)** | 출력 |
| 기계 학습 | 입력 데이터 + **출력 (정답)** | **program (model = 학습된 W)** |

<details>
<summary><b>▶ 모범 답안</b></summary>

- **일반 program**: 사람이 문제를 분석해서 **rule(알고리즘)을 명시적으로 작성**하고, 입력을 그 program에 넣어 출력을 얻는다.
  고양이 인식처럼 rule을 정의하기 어려운 문제(시점·조명·변형·가려짐 등 변형이 무한함)에서는 rule이 쉽게 깨지고(brittle), class마다 rule을 새로 만들어야 해서 확장이 안 된다(not scalable).
- **기계 학습**: 입력과 정답(출력) 쌍으로 된 **학습 데이터를 주면, 기계가 입력과 출력 사이의 관계를 스스로 찾아 program(model, 즉 weight W)을 자동으로 만든다** (data-driven approach).
  `train(images, labels) → model`, `predict(model, image) → label` 두 함수로 구성되며, 학습은 loss가 작아지는 방향으로 W를 조정하는 것이다.

**키워드**: rule을 사람이 작성 vs 데이터로 rule(W)을 자동 생성 / input+program→output vs input+output→program

</details>

### 📝 1-2. Unsupervised Learning의 "Association(연관)" — 슈퍼마켓 구매 리스트 예 `2023 · 2024`

<details>
<summary><b>▶ 모범 답안</b></summary>

- Association은 **정답(label) 없이** 데이터 안에서 **함께 나타나는 항목들 사이의 연관 규칙**을 찾는 비지도 학습이다.
- 예: 슈퍼마켓 고객들의 구매 리스트(장바구니)를 분석하면 "**빵을 산 고객은 우유도 함께 산다**", "기저귀를 사는 고객은 맥주도 산다" 같은 규칙 `{빵} → {우유}` 을 찾을 수 있다.
- 활용: 함께 사는 상품을 **가까이 진열**, **묶음 할인**, **상품 추천**(추천 시스템), 타깃 마케팅.

> 노트에는 "고객들이 어떤 상품을 함께 구매하는가 → 추천"까지만 있습니다. 빵·우유, 기저귀·맥주 예시와 진열·묶음 할인은 보충입니다.

</details>

### 📝 1-3. Classification vs Regression `2023 · 2024`

<details>
<summary><b>▶ 모범 답안</b></summary>

| | Classification (분류) | Regression (회귀) |
|---|---|---|
| 출력 | 미리 정한 **이산적 class(label)** 중 하나 | **연속적인 수치** |
| 예 | 내일 덥다/춥다, 대출 승인/거절 | 내일 기온 몇 도, 대출 가능 금액, 아파트 가격 |
| 평가 | **정확도**(맞힌 비율) | **RMSE** |

- **공통점**: 둘 다 **supervised learning** — 학습 데이터에 입력과 정답(출력)이 모두 있어야 하고, 학습(training) 단계가 있다.

</details>

### 📝 1-4. Unsupervised Learning의 차원 축소를 하는 이유 `2023 · 2024`

<details>
<summary><b>▶ 모범 답안</b></summary>

1. **차원의 저주 해결**: 차원이 d이고 축마다 k칸이면 공간을 채우는 데 **k^d개의 데이터**가 필요하다(6, 36, 216, …). 차원이 높으면 필요한 학습 데이터가 지수적으로 늘어나므로, 차원을 줄여 적은 데이터로도 학습되게 한다.
2. **Overfitting 방지**: 고차원인데 데이터가 적으면 학습 데이터에만 맞는 모델이 되기 쉽다.
3. 그 밖에 **계산량·저장 공간 감소**, **노이즈 제거와 핵심 특징 추출**(의미 있는 압축), **시각화**.
- 방법: PCA, LDA, Isomap, Autoencoder. 예: 3차원 데이터를 2차원 평면에 투영.

</details>

### 📝 1-5. Vanishing Gradient Problem의 정의 및 해결 방법 `2023 · 2024 · 2025.10 · 2026.04` ✍️

```
역전파: ∂L/∂x = (∂σ/∂x) × (∂L/∂σ)
          아래로 보낼 양 = local gradient × 위에서 온 gradient

sigmoid:  σ'(x) = σ(x)(1−σ(x)),  0 < σ' ≤ 0.25  (x=0일 때 최대 0.25)
          → 층마다 최대 0.25를 곱함 → 10층이면 0.25¹⁰ ≈ 9.5×10⁻⁷
          → |x|가 크면(포화 영역) σ' ≈ 0 → gradient가 아예 0
ReLU:     f(x) = max(0, x),  f'(x) = 1 (x>0), 0 (x<0)
          → x>0이면 1을 곱함 = 그대로 전달 → 깊어져도 줄지 않음
```

<details>
<summary><b>▶ 모범 답안</b></summary>

- **정의**: 깊은 신경망을 backpropagation으로 학습할 때, gradient가 출력층에서 입력층 쪽으로 전달되면서 **점점 작아져 0에 가까워지는** 현상. 그 결과 **입력층에 가까운 아래쪽 layer의 weight가 거의 update되지 않아** 학습이 되지 않는다.
- **원인**: 역전파 시 각 층에서 activation 함수의 local gradient를 곱한다. Sigmoid의 미분값은 **최대 0.25**이므로 층마다 최대 0.25가 곱해져 (0.25)ⁿ으로 지수적으로 감소한다. 입력이 크거나 작아 **포화(saturation)** 되면 미분값이 거의 0이 된다.
- **해결 방법**
  1. **ReLU 사용**: x > 0에서 미분값이 1이므로 위에서 온 gradient를 그대로 아래로 전달
  2. **가중치 초기화**: Xavier(sigmoid/tanh), He(ReLU)로 activation이 포화·소멸되지 않게 함
  3. **Batch Normalization**: 각 층의 activation을 평균 0·분산 1로 정규화해 포화 영역으로 가지 않게 함

</details>

### 📝 1-6. Overfitting이 왜 문제인가 / 주요 원인 / 해결 방법 `2023 · 2024 · 2025.10` ✍️

<details>
<summary><b>▶ 모범 답안</b></summary>

- **정의·문제점**: 모델이 **학습 데이터에만 과도하게 맞춰져서**, 학습 데이터 정확도는 높지만 **학습하지 않은 새로운 데이터(test, 실제 응용)에서는 성능이 떨어지는** 현상. 학습의 진짜 목적은 처음 보는 데이터를 잘 맞히는 것(일반화)이므로 실제로 쓸 수 없는 모델이 된다.
- **주요 원인**: **모델 capacity(파라미터 수)에 비해 학습 데이터가 적을 때** 발생. 데이터 차원이 높을 때(차원의 저주), 너무 오래 학습할 때 심해진다.
- **해결 방법**
  1. **학습 데이터를 늘림** — 수집 또는 **data augmentation**(flip, crop, color jitter)
  2. **Regularization** — loss에 λR(W) 추가(L2 weight decay), **Dropout**, Batch Normalization
  3. **Early stopping** — validation error가 다시 증가하기 시작하면 학습을 멈춤
  4. **Transfer learning** — 대규모 데이터로 사전 학습한 모델을 적은 데이터로 fine-tuning
  5. 차원 축소, model ensemble

</details>

### 📝 1-7. Artificial Neuron (Perceptron)의 구조를 그리고 동작 방법 설명 `2023 · 2024 · 2025.10` ✍️

```
 x₁ ──w₁──┐
 x₂ ──w₂──┤
  ⋮       ├──▶ [ Σ wᵢxᵢ + b ] ──▶ [ f (activation) ] ──▶ y
 xₙ ──wₙ──┘           ↑
                      b (bias)
            y = f( Σᵢ wᵢxᵢ + b ) = f(wx + b)
```

<details>
<summary><b>▶ 모범 답안</b></summary>

- **구조** (생물학적 뉴런 모방): 입력 x₁…xₙ(dendrite, 이전 뉴런의 출력) / 연결 강도 **weight w₁…wₙ**(synapse) / 가중합 **Σwᵢxᵢ + b**(cell body) / **activation function f**(sigmoid, ReLU 등) / 출력 y(axon).
- **동작**
  1. 각 입력에 weight를 곱해서 모두 더하고 bias를 더한다 (weighted sum).
  2. 그 값을 **비선형 activation 함수**에 통과시켜 출력 y를 만들고 다음 층으로 보낸다.
  3. 같은 입력이라도 **weight가 출력을 결정**하므로, 원하는 출력이 나오도록 **weight를 찾는 것이 학습**이다 (w ← w − η·∂L/∂w).
- 비선형 f가 없으면 층을 쌓아도 W₂W₁x = W'x로 선형 함수 하나와 같으므로 반드시 비선형 함수가 필요하다.

</details>

## ⚠️ 블록 1 틀리는 지점

1. Vanishing gradient의 원인은 **"sigmoid 미분 최대 0.25"를 숫자까지** 쓰세요.
2. Overfitting은 **"문제점 / 원인 / 해결" 3단**으로 나눠 쓰세요. 문항이 세 가지를 다 묻습니다.
3. Perceptron은 **그림이 필수**입니다.

<br/>

---
---

<br/>

# 블록 2 — 학습 실전 ⏱ 25분 · 4~5주차

### 배우기 — 세 데이터의 역할 ✍️

| 데이터 | 언제 쓰나 | 목적 | 횟수 |
|---|---|---|---|
| **Train** | 학습 중 | weight(W) 학습 | 여러 번 |
| **Validation** | 개발 중 | hyperparameter·모델 **선택**, 멈출 시점 결정 | 여러 번 |
| **Test** | 맨 마지막 | 선택된 모델의 **일반화 성능 측정** | **딱 한 번** |

- **Hyperparameter**: 학습으로 구하지 않고 **사람이 정하는 값** — learning rate, λ, batch size, epoch, layer 수, 뉴런 수, K-NN의 k, distance 종류
- **Learnable parameter**: 학습으로 구하는 값 — **weight, bias** (BN의 γ, β 포함)

```
error
  │ ╲                    ╱ validation  ← 여기서부터 overfitting
  │  ╲       ___....---‾‾
  │   ╲ ___‾‾ ↑
  │    ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾  training (계속 감소)
  └──────────┼───────────── epoch
         Early stopping 지점 (validation error 최소)
```

### 📝 2-1. Train/Val gap 진단 `2025.04 · 2026.04` (5점 × 2)

> DNN 모델 학습 시 다음 현상이 일어난 경우 그 이유 및 **주어진 학습데이터 및 DNN 모델을 수정하지 않고** 해결할 수 있는 방법을 설명하라.
> (가) Training Accuracy는 높은데 Validation Accuracy는 낮은 경우 (차이가 많은 경우)
> (나) Training Accuracy와 Validation Accuracy의 차이가 거의 없는 경우

<details>
<summary><b>▶ 모범 답안</b></summary>

**(가) Overfitting**
- 이유: 모델이 학습 데이터에 과도하게 맞춰져서(모델 capacity에 비해 데이터가 적음) 학습하지 않은 validation 데이터에서는 성능이 떨어진다.
- 해결 (데이터·모델 구조를 바꾸지 않고): **regularization 강도 λ를 키움**(L2 weight decay), **Dropout** 적용·비율 증가, **Early stopping**(validation accuracy가 최고인 epoch에서 멈춤), Batch Normalization, 학습 중 data augmentation.

**(나) Underfitting (학습 부족)** — 두 정확도가 모두 낮은 상태
- 이유: 모델이 학습 데이터의 패턴조차 충분히 학습하지 못했다. regularization이 너무 강하거나, 학습이 덜 되었거나, learning rate가 맞지 않는 경우.
- 해결: **λ를 줄이거나 dropout을 줄임**, **더 많은 epoch 학습**, **learning rate 등 hyperparameter 조정**, 더 좋은 optimizer(Adam) 사용.
  (모델 수정이 허용되면 layer·뉴런 수를 늘려 capacity를 키우는 것이 일반적인 해결책)

</details>

### 📝 2-2. 학습을 멈춰야 할 때 `2025.04 · 2025.10 · 2026.04` (5점)

<details>
<summary><b>▶ 모범 답안</b></summary>

- **Training accuracy는 계속 올라가는데 validation accuracy가 더 이상 오르지 않거나 떨어지기 시작할 때** (= validation loss가 다시 증가하기 시작할 때) 학습을 멈춘다 → **Early stopping**.
- 이 시점 이후로는 학습 데이터에만 맞춰지는 overfitting이 진행되어 새 데이터 성능이 나빠지기 때문이다. validation 성능이 가장 좋았던 epoch의 weight를 최종 모델로 선택한다.

</details>

### 📝 2-3. Train / Validation / Test `2025.04 · 2026.04` (5점 × 3)

> (a) Training Data로 hyperparameter를 바꿔 가며 여러 번 학습하면 매번 Learnable Parameters(Weights) 값이 서로 다르게 된다. 그 이유는?
> (b) 여러 학습 결과 중 어떤 학습 결과를 최종 결과로 선택해야 하는가?
> (c) 최종 성능은 Test Data로 추가 측정한다. Validation Data에 대한 성능이 최종 성능이 될 수 없는 이유는?

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)** Loss space는 울퉁불퉁한 non-convex 지형이고, 학습은 **random 초기 W에서 출발해 gradient 방향으로 조금씩 내려가는** 방법이다. hyperparameter(learning rate, batch size, λ, epoch 등)가 바뀌면 내려가는 **경로가 달라지고**, 초기값·mini-batch 순서·dropout도 매번 random이므로 **서로 다른 local minimum(sub-optimum)에 도달**한다.

**(b)** **Validation data에 대한 성능이 가장 좋은 학습 결과**를 선택한다. training 성능이 가장 좋은 것을 고르면 overfitting된 모델을 고를 수 있다.

**(c)** Validation data는 **모델·hyperparameter를 고르는 데 이미 사용**되었으므로, 선택된 모델은 validation data에 맞춰진 모델이다. 따라서 validation 성능은 **실제보다 과대평가**된다. **개발 과정에서 한 번도 쓰지 않은 test data**로 측정해야 처음 보는 데이터에 대한 진짜 일반화 성능을 알 수 있다 (test는 마지막에 한 번만).

</details>

### 📝 2-4. λ를 크게/작게 할 때 training·validation error `2025.10` (10점)

$$L(W) = \underbrace{\frac{1}{N}\sum_{i=1}^{N} L_i(f(x_i, W), y_i)}_{(1)\ \text{data loss}} + \underbrace{\lambda R(W)}_{(2)\ \text{regularization}}$$

<details>
<summary><b>▶ 모범 답안</b></summary>

| λ | W의 상태 | training error | validation error |
|---|---|---|---|
| **작게** | (1) 위주로 학습 → W가 학습 데이터에 딱 맞춰짐 (overfitting) | **작아짐** | **커짐** |
| **크게** | (2) 때문에 W가 작고 단순해짐 → 일반화 | **커짐** | **작아짐** |
| **너무 크게** | data loss를 무시하고 W를 작게 만드는 데만 집중 → 분류기가 제대로 동작 안 함 (underfitting) | 커짐 | 다시 **커짐** |

- 이유: (1)은 W를 학습 데이터에 맞추는 항, (2)는 W가 학습 데이터에 종속되지 않도록(작고 고르게) 막는 항이다. λ는 둘의 비중을 정하는 hyperparameter이므로 **validation error가 최소가 되는 λ**를 찾는다.

</details>

### 🎯 2-5. Babysitting & Hyperparameter 탐색 `5주차`

<details>
<summary><b>▶ 정리</b></summary>

- **초기 loss sanity check**: regularization 끄고 10 class softmax → 약 **2.3 (= ln 10)** 이면 정상. reg를 켜면 약간 올라가야 정상.
- **작은 데이터(20개)로 overfit 해보기**: train accuracy 1.00이 나와야 코드·모델이 정상.
- **Loss curve**: LR 매우 큼 → 발산 / 큼 → 빨리 떨어지다 높은 값에서 멈춤 / 작음 → 직선처럼 느리게 / 적당 → 빠르게 떨어진 뒤 낮게 수렴
- **Update/weight 비율** ≈ 10⁻³ 이 적당
- **Coarse → fine search**: 몇 epoch로 넓게 → 좋은 범위로 좁혀 오래
- **Log space**에서 탐색 (`10 ** uniform(-5, 5)`): LR·λ는 자릿수 단위로 효과가 달라지기 때문
- **Random search > Grid search**: 중요한 hyperparameter와 안 중요한 것이 섞여 있음. 9번 시도 시 grid는 중요한 파라미터 값을 3개만 보지만 random은 9개를 봄

</details>

## ⚠️ 블록 2 틀리는 지점

1. 2-1 (나)를 "잘 학습된 것"이라고만 쓰지 마세요. 교수님 의도는 **gap 없음 = 충분히 학습 못함(underfitting)** 입니다.
2. 2-3 (b)의 답은 **validation** 최고 성능입니다.
3. "데이터·모델을 수정하지 않고" 조건이 있으면 **"데이터 더 모으기 / layer 늘리기"는 답이 아닙니다.**

<br/>

---
---

<br/>

# 블록 3 — 차원의 저주 · 실제 데이터 특성 · Transfer Learning ⏱ 25분

### 배우기

- **차원의 저주**: 차원 d, 축마다 k칸 → 필요한 데이터 **k^d** (10칸이면 10 → 100 → 1000). 전체의 20%를 담는 영역의 한 변: 1D 0.2 → 2D 0.45 → 3D 0.58 (가까운 이웃을 찾으려면 공간의 대부분을 봐야 함 → "가깝다"가 무의미해짐)
- **Latent vector**: 고차원 입력에서 **핵심 특징만 뽑은 저차원 압축 표현** (엑기스)
- **Foundation model 활용**: 대규모 데이터로 사전 학습한 모델로 고차원 데이터를 의미 있는 저차원 임베딩으로 변환
- 고차원 feature를 **t-SNE로 2차원에 투영하면 비슷한 이미지끼리 모여 있음** (2주차)

### 📝 3-1. 차원의 저주 `2024 · 2025.04 · 2025.10 · 2026.04` (5점) ✍️

> "차원의 저주"란 무엇인지 다음 용어를 이용하여 설명하라. — 고차원, 학습데이터의 양, overfitting, 분류 정확도

<details>
<summary><b>▶ 모범 답안</b></summary>

- 데이터의 **차원(feature 수)이 높아질수록**, 공간을 같은 밀도로 채워 정확하게 일반화하는 데 필요한 **학습 데이터의 양이 지수적으로 증가**하는 현상이다 (축마다 k칸이면 k^d개 필요).
- 학습 데이터의 양은 한정되어 있으므로 **고차원**에서는 데이터가 공간에 듬성듬성(sparse) 분포하게 되고, 데이터 사이 거리 차이도 거의 없어진다.
- 이 상태에서 학습하면 모델이 적은 학습 데이터에만 맞춰지는 **overfitting**이 일어나고, 처음 보는 데이터에 대한 **분류 정확도가 떨어진다**. (보충: 데이터 양이 고정이면 차원을 늘릴수록 정확도는 처음엔 오르다가 어느 순간부터 떨어진다.)
- 해결: 차원 축소, latent vector 사용, 사전 학습된 모델(foundation model)로 저차원 임베딩 변환.

</details>

### 📝 3-2. 고차원 → 저차원 변환과 실제 데이터의 특성 `2024 · 2025.10 · 2026.04` (5점 × 2)

> 딥러닝에서는 고차원 데이터(예: 640×480×3)를 DNN을 통해 저차원 데이터(예: 4096차원)로 변환하여 classification, regression, association 등에 사용한다.
> (a) 고차원 데이터를 직접 여러 응용에 사용하는 경우 발생하는 문제를 총칭하여 무엇이라 하는가?
> (b) (고차원) → (저차원) 변환을 하여도 원래 데이터의 특징을 대부분 유지할 수 있다. 이는 실제 데이터의 어떤 특성에 기인하는가?

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)** **차원의 저주 (Curse of Dimensionality)**

**(b)** 실제 데이터의 고차원 값들이 모두 의미 있는 정보는 아니고, 데이터의 의미를 결정하는 **핵심 특징은 훨씬 적은 수의 차원으로 표현할 수 있다**는 특성 때문이다.
- 고차원 입력에서 **핵심 특징만 뽑아낸 압축 표현(latent vector, "엑기스")** 만으로도 데이터를 구분할 수 있다 (2주차).
- 고차원 feature를 2차원으로 투영해도 **비슷한 데이터끼리 모여 있는** 구조가 유지된다 (2주차 t-SNE).
- (보충) 실제 데이터는 고차원 공간에 고르게(random하게) 퍼져 있지 않고, **훨씬 낮은 차원의 구조 위에 모여 있다**.
- (보충) 예: 이미지에서 **이웃한 픽셀들은 값이 비슷하고 서로 강한 상관관계(중복성, redundancy)** 를 가지므로 921,600개의 숫자가 모두 독립적인 정보가 아니다. 이미지의 내용을 결정하는 실제 요인(물체 종류, 모양, 자세, 조명 등)은 소수이다.

> 💡 이 기출(3회 출제)의 답은 수업 노트에 직접 나오지 않아서, (보충) 두 줄은 노트 밖 설명입니다. 답안에는 노트 표현과 보충 설명을 함께 쓰는 것이 가장 안전합니다.

> 2026.04 3번 (a)는 "feature extractor가 3072-D → 1024-D로 줄여도 정보 손실이 거의 없는 이유"로 물었습니다. 답은 동일합니다.

</details>

### 📝 3-3. Feature Extractor 없이 고차원 입력을 직접 분류기에 넣으면? `2026.04` (5점)

> 3072-D 이미지 → Feature Extractor → 1024-D → Fully-Connected classifier → 10-D. 같은 크기의 학습 데이터로 **Feature Extractor를 통하지 않고 직접 Fully-Connected layer와 연결하여** 학습시키면 test 데이터에 대한 성능은?

<details>
<summary><b>▶ 모범 답안</b></summary>

- **test 성능이 떨어진다.**
- 분류기가 3,072차원 원본 픽셀을 직접 입력받으므로 **학습할 weight 수가 크게 늘어나는데 학습 데이터 양은 같다** → **차원의 저주**: 고차원 공간에서 상대적으로 적은 데이터로 많은 파라미터를 학습하면 학습 데이터에만 맞는 **overfitting**이 일어난다.
- 또 원본 픽셀 값은 시점·조명·위치 변화에 따라 크게 바뀌어 분류에 의미 있는 정보가 아니다(픽셀 거리는 informative하지 않음). Feature extractor는 **분류에 필요한 핵심 특징만 저차원으로 뽑아 주므로** 분류기가 훨씬 쉽게 일반화한다.

</details>

### 📝 3-4. 2차원 t-SNE 그림으로 설명 `2026.04` (5점)

> 그림(640×480×3 → 4096-D feature → PCA/t-SNE → 2-D, 이미지들을 2차원 좌표에 배치한 모자이크)을 이용하여, 2차원으로 줄여도 정보 손실이 적어서 2-D 데이터로도 이미지 classification을 잘 할 수 있음을 설명하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

- 그림은 각 이미지를 DNN으로 **4096차원 feature vector**로 바꾼 뒤, t-SNE로 **2차원 좌표**로 줄여 그 위치에 이미지를 배치한 것이다.
- **비슷한 이미지(같은 종류의 물체, 비슷한 색·장면)끼리 2차원 평면의 같은 영역에 모여 있다.**
- 즉 2차원으로 크게 줄였는데도 "어떤 이미지끼리 비슷한가"라는 **이웃 관계(유사도 구조)가 유지**되었다. 같은 class 이미지들이 덩어리(cluster)를 이루므로, 2차원 좌표만으로도 K-NN이나 간단한 분류기로 class를 구분할 수 있다.
- 가능한 이유는 실제 데이터가 저차원 구조에 모여 있기 때문이다 (3-2 (b)).

</details>

### 배우기 — Transfer Learning (6주차) ✍️

```
ImageNet(1000 class)으로 학습된 network
  아래층 (입력 쪽): edge, color, texture → 어떤 이미지에도 쓰이는 일반적(generic) 특징
  위층   (FC)     : 학습한 task 전용(specific) 특징
→ 새 문제: 아래층 freeze + 마지막 FC만 새로 학습 (데이터 많으면 위쪽 몇 층 fine-tune, LR은 1/10)
```

| | 비슷한 데이터셋 | 매우 다른 데이터셋 |
|---|---|---|
| 데이터 적음 | 맨 위 linear classifier만 학습 | 곤란 — 여러 층의 feature에 classifier 시도 |
| 데이터 많음 | 위쪽 몇 층 fine-tune | 더 많은 층 fine-tune |

| 방식 | 내용 | 적합 |
|---|---|---|
| Feature Extraction | 전부 freeze, **마지막 분류층만** 학습 | 데이터 매우 적음 |
| Fine-tuning (일부) | 앞쪽 freeze, **뒤쪽 층 + 분류층** 학습 | 일반적인 경우 |
| Full Fine-tuning | 사전 학습 weight로 초기화 후 **전체** 학습 | 데이터 충분, 도메인 차이 큼 |

### 📝 3-5. Transfer Learning이 잘 되는 이유 `2025.04 · 2025.10 · 2026.04 (2회)` (5점) ✍️

> 대부분의 이미지 분류 문제에서는 ImageNet을 학습한 CNN을 Fine-tuning하여 이용한다. 이렇게 학습을 하여도 높은 성능을 얻을 수 있는 이유를 설명하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

- ImageNet은 **1000개 class**의 다양한 실사 이미지로 이루어진 대규모 데이터셋이다. 여기서 학습된 network는 **1000 class의 객체를 구분할 수 있는 시각적 특징(visual feature)을 추출하도록** 학습되어 있다.
- 특히 아래층(입력 쪽)은 edge, 색, 질감 같은 **어떤 이미지에도 공통으로 쓰이는 일반적(generic) 특징**을 추출하므로, 새로운 이미지 분류 문제에도 그대로 쓸 수 있다.
- 따라서 새 문제에서는 **이미 좋은 feature extractor를 가진 상태에서 시작**하고, 위쪽 layer(마지막 분류층 등)만 적은 데이터로 학습하면 된다. 학습할 파라미터가 적으므로 **적은 학습 데이터로도 overfitting 없이** 높은 성능을 얻고, 학습 시간도 짧다.
- (X-ray처럼 ImageNet과 매우 다른 데이터는 효과가 줄어 더 많은 층을 fine-tune해야 한다.)

</details>

### 🎯 3-6. Overfitting 방지 방법 2가지 / Transfer Learning이 필요한 이유 `6주차`

<details>
<summary><b>▶ 정리</b></summary>

- Overfitting 원인: **network capacity(파라미터 수)에 비해 학습 데이터가 적음** → 방지: ① **Regularization** ② **Transfer Learning**
- Transfer가 필요한 이유: 의료·산업 등 **label 데이터 부족**, 처음부터 학습하면 **대규모 데이터·긴 시간·고비용 GPU** 필요
- Transfer는 예외가 아니라 표준: Object Detection(ImageNet backbone), Image Captioning(ImageNet CNN + word2vec 단어 벡터)
- 교수님 코멘트: 큰 모델을 처음부터 만들기는 늦었음 → **큰 모델을 가져다 내 데이터로 fine-tuning**이 추세 (Hugging Face, AI Hub)

</details>

## ⚠️ 블록 3 틀리는 지점

1. 차원의 저주는 **주어진 4개 용어를 모두 문장에 넣어야** 만점입니다.
2. 3-2 (b)에 "차원 축소를 해서"라고 쓰면 동어반복입니다. **데이터의 특성(핵심 특징은 적은 차원으로 표현 가능, 상관관계·중복성·저차원 구조)** 을 쓰세요.

<br/>

---
---

<br/>

# 블록 4 — K-NN · Linear Classifier ⏱ 25분 · 2주차

### 배우기 ✍️

```
이미지 1장 차원     W × H × C     (CIFAR-10: 32×32×3 = 3,072 / 640×480×3 = 921,600)
가능한 이미지 수     (2⁸)^(W·H·C) = 256^(W·H·C)   (채널당 8bit = 256가지)
CIFAR-10           10 class, 학습 50,000 / 테스트 10,000

K-NN    train: 학습 데이터 전부 저장 O(1) / predict: 전부와 거리 비교 O(N)
        L1 = Σ|I₁−I₂| (마름모, 축 의존)   L2 = √Σ(I₁−I₂)² (원, 회전 불변)
Linear  f(x,W) = Wx + b     W: 10×3072, b: 10 → 30,730개
        W의 각 row = class별 template (내적 = 유사도)
```

### 📝 4-1. 가능한 이미지 개수 `2023` (10점)

> CIFAR-10 이미지(32×32, RGB)와 같은 해상도·color depth를 가지는 서로 다른 이미지는 이론적으로 총 몇 개인가? 계산 방법도 쓰라.

<details>
<summary><b>▶ 모범 답안</b></summary>

- 이미지 1장 = 32 × 32 × 3 = **3,072개의 숫자**
- 숫자 하나(픽셀의 한 채널)는 8bit → **2⁸ = 256가지** 값
- 3,072개 각각이 독립적으로 256가지 → **256^3072 = (2⁸)^3072 = 2^24,576** (≈ 10^7,398)

</details>

### 📝 4-2. K-NN vs Linear classifier 학습 결과의 dimension `2023 · 2026.04` (5점 × 2) ✍️

> CIFAR-10 학습 데이터(50,000장, 32×32×3)에 대하여 K-NN classifier와 Linear classifier의 학습 결과를 나타내는 데이터의 dimension을 쓰라.

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a) K-NN**: 학습 = 모든 학습 데이터를 그대로 저장 → **50,000 × 32 × 32 × 3** (= 50,000 × 3,072) + label **50,000개**

**(b) Linear classifier**: 학습 결과 = W와 b → **W: 10 × 3,072**, **b: 10** (총 30,730개). 학습 데이터 수와 무관하며, 예측 후 학습 데이터가 필요 없다.

</details>

### 📝 4-3. 1,000장 640×480×3, 10 class `2025.04` (5점 × 3)

> (a) K-NN classifier, Linear classifier에서 학습된 결과(추론 시 사용하는 학습 결과)는?
> (b) Linear Classifier에서 "Linear"의 의미와, Linear이기 때문에 발생하는 문제는?
> (c) 모델 크기가 커지면 weight가 학습 데이터에 종속되는 "Overfitting"이 발생할 수 있다. 해결 방법은?

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)**
- K-NN: **학습 데이터 1,000장 전체**(1,000 × 640 × 480 × 3)와 label 1,000개 — 추론 시 전부와 거리를 비교
- Linear: **W(10 × 921,600)와 b(10)** — class별 template

**(b)** score가 입력 x에 대한 **1차 함수**(Sᵢ = Wᵢ₁x₁ + … + Wᵢₙxₙ + bᵢ, 곱하고 더하기만 함)라는 뜻이다. 결정 경계가 **직선(고차원에서는 초평면)** 이다.
- 문제: XOR 형태(사분면 홀짝), 도넛 모양, 여러 덩어리로 떨어진 class처럼 **직선으로 나눌 수 없는 데이터를 분류하지 못한다.** 또 class당 template이 하나뿐이라(머리가 2개인 말 template) class 내 다양한 모양을 표현하지 못한다.

**(c)** Regularization(L2 weight decay, **Dropout**, Batch Normalization), **Data augmentation**, **Early stopping**, **Transfer learning**(ImageNet 사전 학습 모델을 fine-tuning).

</details>

### 📝 4-4. Linear Classifier 그림 해석 `2024` (5점 + 4점 × 3)

> 그림: 고양이 이미지 <x₁, …, x₃₀₇₂> → f(x; W) = Wx → <s₁, …, s₁₀> → SVM/Softmax → Loss. W는 10 × 3072 행렬, (가)는 W 옆의 10장의 흐릿한 class 이미지.
> (a) (가) 부분은 'W' 행렬의 어떤 부분을 가시화한 그림인가?
> (b) L(W) 식에서 xᵢ, yᵢ, W의 의미 및 shape를 각각 쓰라.

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)** W의 **각 행(row)** 을 가시화한 것이다. 10개 행 각각(3,072개 값)을 32 × 32 × 3 이미지 모양으로 되돌려 그린 것으로, **각 class의 template(대표 이미지)** 이다. 학습 과정에서 각 행은 해당 class 이미지와 곱했을 때 큰 값이 나오고 다른 class 이미지와 곱하면 작은 값이 나오도록 바뀌므로 class의 평균적인 모양이 보인다 (plane·ship은 파란 배경, horse는 머리가 2개).

**(b)**

| 기호 | 의미 | shape |
|---|---|---|
| **xᵢ** | i번째 학습 이미지를 한 줄로 편 벡터 | **3072 × 1** (32×32×3) |
| **yᵢ** | i번째 학습 이미지의 정답 label | **스칼라 1개** (0~9 정수) |
| **W** | class별 template을 담은 weight 행렬 (학습 대상) | **10 × 3072** |

</details>

### 📝 4-5. Linear Classifier 서술 `2주차 노트의 기출` (5점 × 3)

<details>
<summary><b>▶ 모범 답안</b></summary>

- **W의 row가 class template이 되는 이유**: 학습 중 각 class row를 **그 class 학습 데이터 pixel과 곱했을 때 큰 값**, **다른 class 이미지와 곱했을 때 작은 값**이 되도록 바꾸기 때문
- **"linear"인 이유**: W₁₁X₁ + W₁₂X₂ + … + W₁ₙXₙ = 0 처럼 **X에 대한 1차 식**이기 때문
- **horse template의 머리가 2개인 이유**: 학습 데이터에 머리가 왼쪽인 말과 오른쪽인 말이 모두 있어서 **두 경우 모두 높은 score가 나오도록** 학습되었기 때문

</details>

### 📝 4-6. K-NN 서술 `2주차 노트의 기출` (5점 × 6)

<details>
<summary><b>▶ 모범 답안</b></summary>

- **시간 복잡도**: Train **O(1)** (저장만), Predict **O(N)** (전부와 비교) → 실제 서비스(예측이 빨라야 함)와 정반대
- **k의 의미**: feature space에서 질의 데이터로부터 **가장 가까운 k개 학습 데이터의 class로 voting**해서 class 결정 (k=1이면 NN)
- **결정 영역 그림**: space = **feature space** / 각 점 = **학습 데이터** / 영역 = 그 위치의 질의가 분류될 class (각 class 데이터의 분포)
- **그림 그리는 프로그램**: `foreach xᵢ in feature_space: foreach yⱼ in training_data: dᵢⱼ = distance(xᵢ, yⱼ)` → 가장 가까운 k개 → majority voting → 색칠
- **흰색 영역**: 가장 가까운 k개의 voting 결과가 **동점**
- **이미지 분류에 거의 안 쓰는 이유 3가지**: ① test 시간이 매우 느림 ② **픽셀 단위 거리는 의미 있는 정보가 아님** (조금 이동·어둡게·가리기만 해도 거리 크게 변함) ③ **차원의 저주** (고차원인데 데이터가 적어 거리 차이가 없어짐)
- **Hyperparameter (k, distance) 설정**: train만 보고 고르면 k=1이 항상 100% (BAD) / test로 고르면 test에 맞춰짐 (BAD) / **train·validation·test로 나눠 validation으로 선택** (Better)

</details>

### 📝 4-7. 이미지 분류 방법의 발전 `6주차 수업에서 소개한 기출` (3점 × 6)

> K-NN → Linear Classifier → Multi-layer NN → Deep NN으로 발전했다. 각 방법의 문제점과 다음 방법에서의 해결 방법은?

<details>
<summary><b>▶ 모범 답안</b></summary>

| 단계 | 문제점 | 다음 단계의 해결 |
|---|---|---|
| **K-NN** | 모든 학습 데이터와 비교 → predict **O(N)**, 느림 | **Linear**: 학습으로 class별 **대표 template을 W로** 만들어 두고 template만 비교 |
| **Linear** | template 비교가 **선형 함수**라 선형으로 분리 안 되는 복잡한 문제를 못 풂 | **Multi-layer NN (1990s)**: linear를 여러 단계로 쌓고 단계마다 **비선형 activation** |
| **Multi-layer NN** | 깊어지면 **vanishing gradient**로 학습 안 됨 | **DNN (2010s)**: **ReLU, Batch Normalization**(+ Xavier/He 초기화) |

</details>

### 🎯 4-8. Image classification이 어려운 이유 / Semantic gap `2주차`

<details>
<summary><b>▶ 정리</b></summary>

- **Semantic gap**: 사람은 "고양이"라는 의미를 보지만 컴퓨터는 [0, 255] 숫자 격자만 봄
- **Challenges**: Viewpoint variation, Illumination, Deformation, Occlusion, Background clutter, Intraclass variation, Scale
- **Robust/Invariant feature**: 이런 변화가 있어도 feature 값이 크게 변하지 않는 것
- **Rule-based의 문제**: super brittle, not scalable → **data-driven approach**

</details>

<br/>

---
---

<br/>

# 블록 5 — Loss · Regularization · Optimization 기초 ⏱ 30분 · 3주차

### 배우기 ✍️

| | 식 | min / max | W가 작을 때(s≈0) 초기 loss |
|---|---|---|---|
| **SVM (hinge)** | $L_i = \sum_{j \ne y_i} \max(0,\ s_j - s_{y_i} + 1)$ | 0 / ∞ | **C − 1** (10 class → 9) |
| **Softmax (cross-entropy)** | $L_i = -\log \dfrac{e^{s_{y_i}}}{\sum_j e^{s_j}}$ | 0 / ∞ | **log C** (10 class → ln10 ≈ 2.3) |
| Cross entropy | $H(p,q) = -\sum p(x)\log q(x)$ | — | p가 one-hot이면 정답 항만 남음 |

- log는 **자연로그(ln)** 기준. 답안에 "ln 기준"이라고 적으세요.
- **SVM**: 정답 score가 다른 score보다 **margin(1) 이상 크면 만족** → 그 뒤로는 score가 조금 바뀌어도 loss 변화 없음
- **Softmax**: 정답 확률이 1이 될 때까지 **계속 불만족** → 항상 상대 비율을 봄
- **Softmax에서 eˣ를 쓰는 이유**: ① 미분이 쉬움 ② 큰 값은 더 크게, 작은 값은 더 작게 → class 구별이 뚜렷

### 📝 5-1. Softmax loss 계산 `2023` (5점)

> 4개 class, 정답 확률 p = <0, 1, 0, 0>, 계산된 확률 q = <0.2, 0.5, 0.1, 0.2>일 때 Softmax Loss는?

<details>
<summary><b>▶ 모범 답안</b></summary>

$$L_i = H(p, q) = -\sum p \log q = -(0 \cdot \ln0.2 + 1 \cdot \ln0.5 + 0 \cdot \ln0.1 + 0 \cdot \ln0.2) = -\ln 0.5 \approx \mathbf{0.693}$$

(밑이 10이면 0.301) — 정답이 one-hot이므로 정답 class의 예측 확률(0.5)만 남는다.

</details>

### 📝 5-2. Loss의 min = 0, max = ∞ 예시 `2023` (5점)

> 4 class, 정답이 4번 class인 데이터에서 score가 어떤 값이어야 Loss가 0(min), ∞(max)가 되는지 예를 들어 설명하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

- **Min = 0**: 정답 class score만 매우 크고 나머지는 상대적으로 무시할 만할 때. 예: score **<0, 0, 0, 500>** → 확률 ≈ <0, 0, 0, 1> → L = −ln(1) = **0** (정확히 0은 아니고 한없이 가까워짐)
- **Max = ∞**: 정답 class score가 다른 class보다 엄청 작을 때. 예: score **<500, 500, 500, 0>** → 정답 확률 ≈ 0 → L = −ln(0) → **∞**
- (SVM loss로 답한다면: min 0 = 정답 score가 모든 다른 score보다 1 이상 큼, 예 <10, 20, 30, 40> / max ∞ = 정답 score가 무한히 작음)

</details>

### 📝 5-3. W가 아주 작으면 loss = log C 유도 `2023` (10점) / SVM이면? `2025.04` (5점)

<details>
<summary><b>▶ 모범 답안</b></summary>

**Softmax**: W가 매우 작으면 모든 score $s_j = Wx \approx 0$ 이다.

$$L_i = -\log\frac{e^{s_{y_i}}}{\sum_{j=1}^{C} e^{s_j}} = -\log\frac{e^0}{\sum_{j=1}^{C} e^0} = -\log\frac{1}{C} = \log C$$

(모든 class 확률이 1/C. CIFAR-10이면 ln 10 ≈ 2.3 → 학습 시작 시 sanity check)

**SVM (margin 1, 10 class)**: 모든 s ≈ 0이면 정답 제외 C−1개 항이 각각 max(0, 0 − 0 + 1) = 1 → $L_i = C - 1 = \mathbf{9}$

</details>

### 📝 5-4. 3개 이미지 예제 `2025.04` (7점 + 8점)

| | cat 이미지 | car 이미지 | frog 이미지 |
|---|---|---|---|
| cat | **3.2** | 1.3 | 2.2 |
| car | 5.1 | **4.9** | 2.5 |
| frog | −1.7 | 2.0 | **−3.1** |

> ① 전체 학습 데이터에 대한 평균 SVM loss (margin 1) ② 고양이 이미지에 대한 Softmax loss

<details>
<summary><b>▶ 모범 답안</b></summary>

**① SVM**
- cat: max(0, 5.1 − 3.2 + 1) + max(0, −1.7 − 3.2 + 1) = 2.9 + 0 = **2.9**
- car: max(0, 1.3 − 4.9 + 1) + max(0, 2.0 − 4.9 + 1) = 0 + 0 = **0**
- frog: max(0, 2.2 + 3.1 + 1) + max(0, 2.5 + 3.1 + 1) = 6.3 + 6.6 = **12.9**
- 평균 L = (2.9 + 0 + 12.9) / 3 = **5.27**

**② Softmax (cat 이미지)**
- exp: e^3.2 = 24.5, e^5.1 = 164.0, e^−1.7 = 0.18 → 합 188.7
- 정답 확률 = 24.5 / 188.7 = 0.13
- L = −ln(0.13) ≈ **2.04**

</details>

### 📝 5-5. L(W)의 (1)·(2) 항목의 역할 `2024 · 2025.04` (5~10점) ✍️

> 모든 학습 데이터에 대한 loss L(W) 식에서 (1)번 항목과 (2)번 항목이 W를 학습 데이터에 대하여 어떻게 변화시키도록 노력하는지 설명하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

- **(1) Data loss** $\frac{1}{N}\sum L_i$: 모든 학습 데이터에 대해 **정답 class의 score가 높게 나오도록**, 즉 W를 **학습 데이터에 맞추도록(fit)** 변화시킨다.
- **(2) Regularization loss** $\lambda R(W)$: W가 **학습 데이터에 너무 딱 맞지 않도록(종속되지 않도록)**, **작고 고르게 퍼진 단순한(simple) 형태**로 유지시킨다. 그래야 test 데이터에서도 잘 동작한다 (일반화, Occam's razor).
- 이유: loss를 0으로 만드는 W는 하나가 아니다(W가 L=0이면 2W도 L=0). 그중 test에서 잘 되는 단순한 W를 고르기 위해 (2)를 더한다. λ는 둘의 비중을 정하는 hyperparameter.

</details>

### 📝 5-6. L1/L2 Regularization으로 만들어지는 W의 특성 `2024` (5점)

<details>
<summary><b>▶ 모범 답안</b></summary>

- **L2** $R(W) = \sum W_{k,l}^2$: 큰 값에 큰 벌점 → **작은 값들이 모든 원소에 고르게 퍼진 W**.
  예: x = [1,1,1,1]에서 w₁ = [1,0,0,0], w₂ = [0.25,0.25,0.25,0.25]는 score가 1로 같지만 R(w₁) = 1, R(w₂) = 0.25 → **w₂ 선택**.
- **L1** $R(W) = \sum |W_{k,l}|$: **0이 많은 sparse한 W** (non-zero 원소 수로 복잡도를 봄).
- **이유**: W가 특정 입력 차원 몇 개에 큰 값을 가지면 그 차원만 보고 판단해 학습 데이터에 과하게 맞춰진다. **입력의 모든 차원을 골고루 반영하는 단순한 W**가 새 데이터에 더 잘 일반화되고 overfitting을 막는다.

</details>

### 📝 5-7. Loss space와 SGD `2024` (5점 × 2)

> ① L(W) 값은 무엇에 의해 결정되나? ② SGD로 최적의 W를 찾는 방법을 설명하고, 이렇게 찾은 W가 학습 데이터에 대한 loss를 최소화하는 것을 보장하는지 설명하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

**①** 학습 데이터(xᵢ, yᵢ)는 고정되어 있으므로 L(W)는 **W(와 b)의 값에 의해서만 결정**된다. W의 각 원소를 축으로, loss를 높이로 그린 것이 loss space이다 (CIFAR-10 linear classifier면 10×3072 + 1차원).

**② SGD**
1. W를 **random 값으로 초기화**
2. 학습 데이터 **1개(또는 mini-batch)** 를 넣어 forward로 score와 loss 계산
3. backpropagation으로 **gradient ∂L/∂W** 계산
4. **W ← W − η·∂L/∂W** (gradient 반대 방향 = loss가 줄어드는 방향)
5. 모든 학습 데이터에 대해 여러 epoch 반복

**보장하지 않는다.** gradient는 현재 위치의 국소적 기울기일 뿐이고 loss space는 non-convex하므로 **local minimum이나 saddle point**(gradient ≈ 0)에 멈출 수 있다. 또 SGD의 gradient는 일부 데이터로 구한 근사값이라 noisy하다. 따라서 **sub-optimum**을 찾는 방법이다.

</details>

### 📝 5-8. 3-layer NN — 공간 차원과 update 횟수 `2025.04` (3점 × 5)

> 32×32×3 이미지를 2개 class로 분류하는 3-layer NN (입력 → (a) FC → 6개 뉴런 → (b) FC → 6개 뉴런 → (c) FC → 출력 2개). 학습 데이터 5,000개, mini-batch 50개, 1 epoch에 종료, Loss는 MSE.
> (a) 입력 데이터 공간의 차원 및 loss 공간의 차원
> (b) (b) FC의 weight 하나가 ① SGD ② Mini Batch ③ Batch로 학습할 때 몇 번 수정되나

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)**
- 입력 공간: 32 × 32 × 3 = **3,072차원**
- loss 공간 = (weight 개수) + 1(loss 축)
  - weight = 3,072×6 + 6×6 + 6×2 = 18,432 + 36 + 12 = **18,480** → **18,481차원**
  - (bias 포함 시 weight 18,494개 → 18,495차원)

**(b)** 1 epoch 동안 update 횟수
- ① SGD (1개마다): **5,000번**
- ② Mini-batch (50개마다): 5,000 / 50 = **100번**
- ③ Batch (전체 보고 1번): **1번**

</details>

### 🎯 5-9. Gradient 계산 / GD 종류 `3주차`

<details>
<summary><b>▶ 정리</b></summary>

- **Numerical gradient**: (f(x+h) − f(x))/h — 근사, 느림, 쉬움 / **Analytic**: 미분 공식 — 정확, 빠름, 실수 쉬움 → **실전: analytic 쓰고 numerical로 검증 (gradient check)**
- **Random search**로 W 찾기 → CIFAR-10 정확도 15.5% (매우 나쁨)
- **Learning rate**: 작으면 느리게 수렴 / 너무 크면 최소점 근처에서 튀고 발산
- **Batch / Mini-batch / SGD**: W를 update하는 주기의 차이. epoch당 계산량 SGD < Mini < Batch, 필요한 epoch 수 SGD < Mini < Batch. SGD는 빠르지만 궤적이 흔들림, Batch는 매끄럽지만 느리고 메모리 큼, Mini-batch(32~256)가 표준
- **Hand-crafted feature vs CNN**: 기존은 사람이 feature 설계(Color histogram, HoG, BoW) + classifier만 학습 / 딥러닝은 **feature 추출까지 학습(end-to-end)**

</details>

## ⚠️ 블록 5 틀리는 지점

1. **SVM 합에서 정답 class(j = yᵢ)는 빼야 합니다.** 넣으면 모두 1씩 커집니다.
2. Softmax는 **정답 class 확률 하나만** 넣습니다. ln(2.04)과 log₁₀(0.89)를 헷갈리지 마세요.
3. Update 횟수: **SGD가 가장 많고(N번), Batch가 가장 적습니다(1번).**

<br/>

---
---

<br/>

# 블록 6 — Backprop · Activation · 초기화 · BN · 전처리 ⏱ 30분 · 4~5주차

### 배우기 — 노드별 역전파 규칙 ✍️

```
downstream gradient = upstream gradient × local gradient

add gate  (+)  : 그대로 복사해서 나눠줌 (distributor)
mul gate  (×)  : 상대편 입력값을 곱함 (switcher)   x의 grad = y × upstream
max gate       : 큰 쪽만 받음, 나머지 0 (router)
branch         : 여러 갈래에서 온 gradient를 더함

도함수:  eˣ → eˣ   |   ax → a   |   1/x → −1/x²   |   c + x → 1
sigmoid gate 한 번에:  σ'(x) = σ(x)(1 − σ(x))
```

- **Backprop이 필요한 이유**: 출력층과 직접 연결된 W는 loss 영향을 바로 계산할 수 있지만, **직접 연결되지 않은 아래층 W**는 영향을 바로 알 수 없음 → 출력의 오류를 **chain rule로 뒤로 전달**하며 계산. 손실에 **영향(책임)이 큰 weight일수록 많이 수정**.
- forward()는 결과 계산 + **gradient 계산에 필요한 중간값 저장**, backward()는 chain rule 적용 (autograd 원리)

### 📝 6-1. Computational graph 빈칸 `2023` (5점 × 4 + 5점 × 2)

$$f(w, x) = \frac{1}{1 + e^{-(w_0x_0 + w_1x_1 + w_2)}}, \quad w_0 = 2,\ x_0 = -1,\ w_1 = -3,\ x_1 = -2,\ w_2 = -3$$

```
w0= 2.00 (다)─┐
              (*)─ −2.00 ─┐
x0=−1.00 (라)─┘           (+)─ 4.00 ─┐
w1=−3.00 ────┐            │          │
              (*)─  6.00 ─┘          (+)─ 1.00 ─(*−1)─ −1.00 ─(exp)─ 0.37 ─(+1)─ 1.37 ─(1/x)─ 0.73
x1=−2.00 ────┘                       │   grad(나)       grad −0.20     grad −0.53   grad(가)    grad 1.00
w2=−3.00 ────────────────────────────┘
```

> (a) (가)~(라) 부분의 gradient를 구하라. (b) 학습 시 (다)의 값과 (라)의 값이 어떤 용도로 사용되는지 설명하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)** 뒤에서부터 upstream × local

| 위치 | 계산 | 값 |
|---|---|---|
| **(가)** 1/x 노드의 입력(1.37) 쪽 | $-\frac{1}{1.37^2} \times 1.00$ | **−0.53** |
| (exp 출력 0.37 쪽) | +1 노드는 그대로: 1 × (−0.53) | −0.53 |
| (×−1 출력 −1.00 쪽) | exp의 local = e^−1 = 0.37 → 0.37 × (−0.53) | −0.20 |
| **(나)** + 출력(1.00) 쪽 | ×(−1)의 local = −1 → (−1) × (−0.20) | **0.20** |
| (w₀x₀ 곱 출력) | + gate는 그대로 전달 | 0.20 |
| **(다)** w₀ | mul gate: 상대편 x₀ × upstream = (−1) × 0.20 | **−0.20** |
| **(라)** x₀ | mul gate: 상대편 w₀ × upstream = 2 × 0.20 | **0.40** |

검증: sigmoid gate로 한 번에 σ(1) = 0.73 → 0.73 × (1 − 0.73) = **0.20** = (나) ✓

**(b)**
- **(다) = ∂L/∂w₀**: weight w₀를 **update하는 데 사용** → w₀ ← w₀ − η × (−0.20)
- **(라) = ∂L/∂x₀**: x₀가 아래 layer 뉴런의 출력이라면, 이 값이 그 뉴런의 **upstream gradient로 아래 layer에 전달(backpropagation)** 되어 아래 layer weight들의 gradient 계산에 사용된다.

</details>

### 📝 6-2. Sigmoid gate의 gradient `2023 기말 (이번 학기 4~5주차 내용)` (30점)

> sigmoid gate에서 ∂L/∂x = (∂σ/∂x)(나) × (∂L/∂σ)(가) = (다)
> (a) (가)의 값이 0.5일 때 (다)의 최댓값과 최솟값을 그때의 x값과 함께 쓰라.
> (b) Vanishing gradient는 (가)가 큰 값이어도 발생한다. 그 이유를 (나)의 최댓값을 이용해 설명하라.
> (c) ReLU의 계산 방법 (마)와 이 함수에 대한 local gradient (바)의 식을 쓰라.
> (d) ReLU를 사용하면 deep해도 vanishing gradient가 발생하지 않는 이유를 (c)의 식으로 설명하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)** (다) = σ(x)(1 − σ(x)) × 0.5
- **최댓값 0.125, x = 0일 때** (σ(0) = 0.5 → 0.5 × 0.5 × 0.5)
- **최솟값 ≈ 0, x → ±∞일 때** (포화 영역. 예: x = ±10이면 약 2.3×10⁻⁵)

**(b)** (나) = σ'(x)의 **최댓값은 0.25**이다. 따라서 (가)가 아무리 커도 아래 layer로 내려가는 gradient는 **최대 1/4로 줄어든다.** 층이 n개면 (0.25)ⁿ 이하로 지수적으로 작아지므로(10층이면 약 10⁻⁶) 입력 쪽 layer의 gradient는 거의 0이 된다.

**(c)** (마) σ(x) = **max(0, x)** / (바) ∂σ/∂x = **1 (x > 0),  0 (x < 0)**

**(d)** x > 0이면 (바) = 1이므로 ∂L/∂x = 1 × ∂L/∂σ, 즉 **위에서 온 gradient를 줄이지 않고 그대로** 아래 layer로 전달한다. 층마다 1을 곱하므로 깊어져도 gradient가 작아지지 않는다.

</details>

### 📝 6-3. ReLU를 써도 학습 속도에 문제가 생기는 이유 `2023 · 2024` (5점) ✍️

<details>
<summary><b>▶ 모범 답안</b></summary>

**이유 1 — not zero-centered (zig-zag)**
- ReLU 출력은 **항상 0 이상**이다. 다음 뉴런 f = Σwᵢxᵢ + b에서 ∂L/∂wᵢ = (∂L/∂f) × xᵢ 인데, xᵢ가 모두 양수이므로 **모든 wᵢ의 gradient 부호가 ∂L/∂f의 부호와 같아진다** (전부 + 또는 전부 −).
- weight들이 "모두 증가" 또는 "모두 감소" 방향으로만 update될 수 있어, 최적점이 다른 방향(예: w₁ 감소·w₂ 증가)에 있으면 **zig-zag 경로로 돌아가야 하므로 학습이 느려진다.**

**이유 2 — Dead ReLU**
- x < 0이면 gradient가 0이다. 초기화가 잘못되거나 learning rate가 너무 커서 입력이 항상 음수가 된 뉴런은 **다시는 활성화·update되지 않는다.**

**해결 방법**
- **Leaky ReLU** max(0.01x, x), **PReLU** max(αx, x), **ELU**: 음수 영역에도 기울기가 있어 죽지 않고 출력 평균이 0에 더 가까움
- **Batch Normalization**, 입력 데이터의 **zero-centering**
- learning rate를 적절히 작게, ReLU bias를 작은 양수(0.01)로 초기화

</details>

### 📝 6-4. Zero-centered의 의미와 학습에 미치는 영향 `2024 기말 (이번 학기 5주차 내용)` (5점)

<details>
<summary><b>▶ 모범 답안</b></summary>

- **의미**: activation 출력이 **양수와 음수를 고르게 가져 평균이 0**인 것 (tanh는 zero-centered, sigmoid·ReLU는 항상 양수라 아님).
- **영향**: zero-centered가 아니면 다음 층 입력 xᵢ가 모두 양수 → ∂L/∂wᵢ = (∂L/∂f)·xᵢ 의 부호가 모두 같음 → 모든 weight가 함께 증가하거나 함께 감소하는 방향으로만 update → **zig-zag 경로로 학습이 느려진다.** zero-centered이면 이런 제약이 없어 빠르게 수렴한다. (입력 데이터를 zero-mean으로 전처리하는 이유이기도 함)

</details>

### 📝 6-5. Xavier Initialization이 해결하는 문제 `2025.04` (5점)

<details>
<summary><b>▶ 모범 답안</b></summary>

- weight를 **너무 작게**(0.01×randn) 초기화하면 층을 지날수록 activation이 0으로 모여 gradient도 0(**vanishing**), **너무 크게**(1.0×randn) 하면 tanh/sigmoid가 **포화**되어 gradient가 0이 된다. **0으로 초기화**하면 모든 뉴런이 똑같이 학습된다(symmetry).
- **Xavier**: `W = randn(fan_in, fan_out) / sqrt(fan_in)` — 입력 뉴런 수(fan-in)의 제곱근으로 나눠 **Var(W) = 1/n**. 그러면 각 층 출력의 분산이 입력 분산과 같게 유지되어, **층이 깊어져도 activation 분포가 무너지지 않고 gradient가 안정적으로 전달**된다.
- ReLU에는 분산이 절반으로 줄어드는 것을 보정한 **He 초기화** `/ sqrt(fan_in/2)`.

</details>

### 🎯 6-6. Activation function 비교 `5주차`

<details>
<summary><b>▶ 정리</b></summary>

| 함수 | 범위 | 장점 | 단점 |
|---|---|---|---|
| Sigmoid | (0, 1) | firing rate 해석 | ① 포화 → vanishing ② not zero-centered ③ exp 비용 |
| tanh | (−1, 1) | **zero-centered** | 포화 → vanishing |
| **ReLU** | [0, ∞) | 양수에서 포화 X, 계산 빠름, **6배 빠른 수렴**, AlexNet(2012)부터 | not zero-centered, dead ReLU |
| Leaky ReLU / PReLU | (−∞, ∞) | 죽지 않음 (PReLU는 α 학습) | — |
| ELU | (−α, ∞) | 평균 0에 가까움, 노이즈에 강건 | exp 계산 |
| Maxout | — | ReLU 일반화, 포화·죽음 X | 파라미터 2배 |

- **실전**: ReLU (LR 주의), Leaky ReLU/ELU/Maxout 시도 가능, **sigmoid는 hidden에 쓰지 말 것**
- **비선형 함수가 필요한 이유**: 없으면 W₂(W₁x) = (W₂W₁)x = W'x → 층을 쌓아도 linear 하나. 비선형이 있어야 복잡한(곡선) 경계, 층마다 공간 변형, 계층적 특징(선 → 눈·귀 → 고양이)

</details>

### 🎯 6-7. Batch Normalization / Data Preprocessing `5주차`

<details>
<summary><b>▶ 정리</b></summary>

**Batch Normalization**
- 아이디어: 입력을 정규화해도 **층을 지나면 activation 분포가 다시 틀어짐** → 중간중간 정규화해서 다음 층으로 넘기자
- 문제: **Internal Covariate Shift** — 앞층 weight가 계속 변해서 다음 층 입력 분포가 계속 바뀜 → 학습 불안정·느림
- 계산 (mini-batch의 **같은 뉴런 값들**로, 뉴런마다 따로):
  $\mu_B = \frac{1}{m}\sum x_i,\ \sigma_B^2 = \frac{1}{m}\sum (x_i - \mu_B)^2,\ \hat{x}_i = \frac{x_i - \mu_B}{\sqrt{\sigma_B^2 + \epsilon}},\ y_i = \gamma\hat{x}_i + \beta$
- **γ, β가 필요한 이유**: tanh 입력이 꼭 unit gaussian일 필요는 없음 → 원하는 평균·분산을 **학습**으로 정함 (γ=σ, β=μ면 원래대로 복원 가능)
- 위치: **FC/Conv 뒤, activation 앞**
- 효과: gradient 흐름 개선, **큰 learning rate** 가능, **초기화 의존성 감소**, **regularization 효과**(batch 통계의 noise)
- Test 시: 학습 중 구한 **평균·분산의 running average** 사용
- 다른 정규화: Layer Norm(한 샘플 안의 모든 채널, RNN·Transformer), Instance Norm(한 샘플의 한 채널), Group Norm

**Data Preprocessing**
- 차원별 scale·분포가 비슷해야 의미 있는 계산 가능 (키 cm vs 연봉 만원)
- 정규화 전: loss가 weight 변화에 **매우 민감** → 최적화 어려움 / 정규화 후: 덜 민감 → 쉬움
- `X -= mean(X, axis=0)` (zero-center), `X /= std(X, axis=0)` (normalize)
- 이미지는 보통 **zero-centering만** (평균 이미지 빼기 AlexNet, 채널별 평균 빼기 VGG)

</details>

<br/>

---
---

<br/>

# 블록 7 — Fancier Optimization · Dropout · Regularization ⏱ 25분 · 6주차

과거 중간에는 거의 안 나왔지만 **이번 학기 6주차에 배운 내용**이라 새로 나올 수 있습니다. 기말 기출로 형태가 확인된 문제(🎯+기말)부터 보세요.

### 🎯 7-1. SGD의 문제점 3가지와 해결 `6주차 예상`

<details>
<summary><b>▶ 모범 답안</b></summary>

1. **Poor conditioning (zig-zag)**: loss가 한 방향으론 가파르고 다른 방향으론 완만하면(condition number 큼) 가파른 방향으로 진동하고 완만한 방향으론 아주 느리게 진행. 원인: 영향이 작은 weight도 **영향이 큰 weight들이 결정한 upstream gradient에 맞춰** update됨 → 해결: **Momentum**(진동 상쇄), **AdaGrad·RMSProp**(차원별 update 균등화)
2. **Local minima / Saddle point**: gradient = 0(또는 매우 작음)이라 멈추거나 매우 느림. 고차원에서는 **saddle point가 훨씬 흔함** → 해결: **Momentum의 관성**으로 통과
3. **Noisy gradient**: mini-batch마다 구성이 달라 어떤 batch의 loss를 줄이는 방향이 다른 batch에서는 아닐 수 있음 → 해결: Momentum으로 **smoothing**

</details>

### 🎯 7-2. Optimizer 비교 `6주차 예상` ✍️

| 알고리즘 | 식·핵심 | 해결 / 단점 |
|---|---|---|
| **SGD** | W ← W − η∇L | zig-zag·local min·noisy |
| **Momentum** | v = ρv + ∇L, W −= ηv (ρ = 0.9, friction) | 관성으로 local min·saddle 통과, zig-zag·noise 완화 / **overshooting** |
| **Nesterov** | velocity만큼 **먼저 가본 곳(look-ahead)** 의 gradient로 결정 | 앞이 오르막이면 브레이크 → overshooting 감소 |
| **AdaGrad** | W −= η · dx / √(Σ dx²) (차원별) | gradient 큰 방향은 작게, 작은 방향은 크게 → **차원별 update 균등** / 오래 하면 분모 커져 **step → 0, 학습 멈춤** |
| **RMSProp** | grad² = decay·grad² + (1−decay)·dx² (decay 0.9) | 누적합 대신 **지수이동평균** → AdaGrad의 step 소멸 해결 |
| **Adam** | Momentum(1차 모멘트) + RMSProp(2차 모멘트) + **bias correction** | β₁ 0.9, β₂ 0.999, LR 1e-3 → **기본 선택** |

- 두 계열: **gradient의 크기(양)** 로 update — SGD → Momentum → Nesterov / **과거 대비 비율** 로 update — AdaGrad → RMSProp → Adam
- **Adam bias correction**: moment가 0에서 시작해 초기 값이 0쪽으로 치우쳐 너무 작음 → (1 − βᵗ)로 나눠 초기에 키워줌 (t=1이면 0.1·dx / 0.1 = dx), t가 커지면 1로 나누는 것과 같아짐
- 예: AdaGrad에서 A 방향 gradient 매번 10, B 방향 0.1 → 첫 step A: 10/√100 = 1, B: 0.1/√0.01 = 1 (같은 크기). A의 2번째: 10/√200 ≈ 0.71 → 계속 감소

### 🎯 7-3. Train/Val gap을 줄이는 방법 분류 `6주차 예상`

<details>
<summary><b>▶ 모범 답안</b></summary>

1. **여러 모델**: **Model Ensemble** — 독립 모델 여러 개를 학습해 test 시 결과 평균 (약 2% 향상). **Snapshot ensemble**: 한 모델 학습 중 여러 시점의 snapshot을 사용 (cyclic LR로 local min을 옮겨 다님, "train 1, get M for free")
2. **하나의 모델**
   - **Cyclic LR, Polyak averaging** (학습 마지막 weight 대신 최근 weight들의 평균 사용 → 골짜기 중앙에 가까움)
   - **Regularization**: loss에 R(W) 추가, Dropout, Batch Normalization, Data Augmentation, DropConnect, Fractional Max Pooling, Stochastic Depth

- **Ensemble vs Regularization의 근본 차이** (2024 기말): Ensemble은 **여러 개의 독립 모델**을 학습해 평균 / Regularization은 **하나의 모델** 안에서 학습 데이터에 종속되지 않게 함

</details>

### 🎯 7-4. Dropout `6주차 예상` ✍️

<details>
<summary><b>▶ 모범 답안</b></summary>

- **방법**: 학습 시 **각 forward pass마다 일부 뉴런을 랜덤하게 0으로** (drop 확률은 hyperparameter, 0.5가 흔함). FC는 뉴런, conv는 channel을 drop. 매번 **더 작은 버전의 NN**을 학습하는 셈.
- **좋은 이유 2가지**
  1. **Co-adaptation 방지**: 일부 feature(귀, 꼬리, 털…)가 랜덤하게 꺼져도 남은 feature로 판단해야 하므로 **특정 feature에 종속되지 않고 여러 feature에 dependency를 분산** → overfitting 방지
  2. **하나의 모델 안의 ensemble**: 각 binary mask가 하나의 모델 → **parameter를 공유하는 거대한 ensemble** (4096 unit이면 2⁴⁰⁹⁶ ≈ 10¹²³³개 mask)
- **Test 시**: dropout을 끄고 activation에 **keep 확률 p를 곱함**. 이유: 입력 2개·p = 0.5인 뉴런에서 학습 때 기대값은 ¼(w₁x+w₂y) + ¼(w₁x) + ¼(w₂y) + ¼·0 = **½(w₁x + w₂y)** 로 test 때의 p배이므로 스케일을 맞춤. (실제 프레임워크는 학습 때 p로 나누는 inverted dropout)

</details>

### 📝 7-5. Regularization 공통 패턴 표 채우기 `2024 기말 (이번 학기 6주차 내용)` (3점 × 4)

> Regularization의 common pattern: Training 時 Add random noise / Testing 時 Marginalize over the noise.
> ① Dropout — 기본 방법: 학습 시 뉴런의 activation 값을 0으로 / randomness: "0"으로 만들 뉴런을 random 선택
> ② Batch Normalization — (가) 기본 방법 / (나) randomness 추가 방법
> ③ Data Augmentation — (다) 기본 방법 / (라) randomness 추가 방법

<details>
<summary><b>▶ 모범 답안</b></summary>

| | 기본 방법 | Randomness 추가 방법 |
|---|---|---|
| ② BN | **(가)** batch에 있는 학습 데이터들에 대해 각 layer의 특정 뉴런 activation 값을 **평균 0·분산 1로 normalize** (+ γ, β로 scale·shift) | **(나)** mini-batch를 구성할 **학습 데이터를 random 선택** → batch 구성이 매번 달라 정규화 통계(평균·분산)가 매번 달라짐 |
| ③ Data Aug. | **(다)** 학습 데이터를 **random하게 변형**(flip, crop·scale, color jitter, rotation 등)해서 사용 | **(라)** 변형(transform)의 종류와 **crop 위치·크기 등 파라미터를 random 선택** |

- 그 밖에: DropConnect(0으로 만들 **weight**를 random) / Fractional Max Pooling(pooling **영역**을 random) / Stochastic Depth(drop할 **layer**를 random)
- Marginalize: 각 학습 데이터에 대한 loss를 합산해 평균 / Dropout은 test 시 p를 곱하고, Data Aug.는 test 시 고정 crop 여러 개(5 scale × 10 crop)의 결과를 평균

</details>

### 🎯 7-6. Data Augmentation 세부 / Loss space와 skip connection `6주차`

<details>
<summary><b>▶ 정리</b></summary>

- **Horizontal flip**: 왼쪽으로 앉은 고양이도 cat
- **Random crop & scale (ResNet)**: 학습 — L ∈ [256, 480] 랜덤 → 짧은 변을 L로 resize → 224×224 랜덤 crop / 테스트 — 5개 scale × (4 corner + center + flip) 10 crop 평균
- **Color jitter**: contrast·brightness 랜덤 / 복잡하게는 RGB에 PCA → 주성분 방향 color offset
- 그 외: translation, rotation, stretching, shearing, lens distortion (**get creative**)
- **Skip connection**: network가 깊어지면 loss space가 울퉁불퉁(non-convex) → skip connection이 있으면 매끈한 그릇 모양 → 최적화 쉬움
- **Sharp minimum**은 학습 데이터에만 맞는 overfitting 지점일 가능성 → overshooting(momentum)으로 빠져나올 수 있음

</details>

<br/>

---
---

<br/>

# 블록 8 — Self-Supervised · Contrastive · NLP SSL ⏱ 30분 · 7주차

**같은 가을학기인 2025.10에 25점**이 나왔습니다. 반드시 보세요.

### 배우기 ✍️

- **Self-Supervised Learning (SSL)**: label 없는 대량의 데이터에서 **데이터 자체로 정답을 자동 생성**하는 **pretext task**를 만들어 supervised 방식으로 학습 → 좋은 **feature extractor(representation)** 획득 → 적은 labeled 데이터로 **downstream task** 학습
  - 필요한 이유: 큰 모델에는 엄청난 데이터가 필요한데 **사람이 일일이 labeling할 수 없음**
  - supervised처럼 보이는 unsupervised learning, **proxy loss**로 학습
- **Pretext task** ("구실"): rotation(0/90/180/270 맞히기), jigsaw(9조각 순서), inpainting(가린 영역 복원), colorization(흑백→컬러), relative position, 다음 단어 예측(GPT), 빈칸 단어 예측(BERT)
- **평가**: pretext 성능은 관심 없음 → **downstream task 성능** (frozen feature extractor + linear classifier, 적은 labeled 데이터)
- **Generative vs SSL (1달러 그림)**: Generative = 데이터 분포 p(x)를 모델링해 **픽셀 디테일까지 실제 같은 데이터 생성** (정밀한 지폐 그림) / SSL = 디테일 없이 **핵심 semantic 특징**만 (기억으로 그린 지폐: ONE DOLLAR, 가운데 인물)

### 📝 8-1. Rotation pretext task `2025.10` (5점 × 5)

> (가) self-supervised learning 단계 → feature extractor → (나) supervised learning 단계 (small amount of labeled data) → evaluate on target task
> (a) (가) 단계 및 (나) 단계에서 supervised learning을 위한 정답을 만드는 방법 (5점 × 2)
> (b) pretext task가 640×480 (true color) 이미지의 4개 회전 각도(0°, 90°, 180°, 270°) 분류일 때, DNN의 입력 및 출력 layer 뉴런 개수
> (c) Contrastive Learning에서 Positive Sample과 Negative Sample을 만드는 방법
> (d) ChatGPT 같은 텍스트 모델에서 foundation model을 만들기 위해 사용하는 pretext task의 예

<details>
<summary><b>▶ 모범 답안</b></summary>

**(a)**
- **(가)**: 사람이 label을 붙이지 않는다. label 없는 이미지를 **0°, 90°, 180°, 270° 중 하나로 직접 회전시키고, 회전시킨 각도를 정답(label)으로 자동 생성**한다.
- **(나)**: 실제 풀고 싶은 문제(target task, 예: 새 분류)에 대해 **사람이 직접 정답을 붙인 소량의 labeled 데이터**를 사용한다.

**(b)** 입력: 640 × 480 × 3 = **921,600개** / 출력: 회전 각도 4 class → **4개**

**(c)**
- **Positive**: 같은 이미지(anchor)에 서로 다른 **data augmentation**(random crop, 회전, color jitter, 흑백, flip, 가리기 등)을 적용한 이미지 → 같은 객체이므로 가깝게
- **Negative**: **다른 이미지**들 (SimCLR에서는 같은 mini-batch 안의 다른 이미지와 그 변형) → 멀게

**(d)** **다음 단어 예측 (auto-regressive language modeling)** — 앞 단어들로 다음 단어를 맞힘. 정답(다음 단어)이 원문에 이미 있으므로 labeling이 필요 없다 (GPT). 그 밖에 **빈칸(masked) 단어 예측**(BERT), 다음 문장 여부 예측(NSP).

</details>

### 📝 8-2. Inpainting pretext task `2026.04` (5점 × 3)

> 640×480 (true color) 이미지에서 **10×10 box**를 가리고 predict missing pixels 하는 inpainting이 pretext task일 때
> (가) DNN의 입력 및 출력 layer 뉴런 개수
> (나) supervised learning의 backpropagation으로 학습할 때 loss 계산 방법
> (다) 이런 학습으로 학습되는 것은 무엇이며, 학습된 모델의 용도는?

<details>
<summary><b>▶ 모범 답안</b></summary>

**(가)** 입력: 가린 이미지 전체 = 640 × 480 × 3 = **921,600개** / 출력: 가려진 영역 픽셀 = 10 × 10 × 3 = **300개**

**(나)** 정답은 **가리기 전 원본 이미지의 10×10 영역 픽셀 값**(자동 생성). 예측한 300개 픽셀 값과 원본 300개 값의 차이를 **L2 loss (MSE)** $L = \sum_{k=1}^{300} (\hat{p}_k - p_k)^2$ 로 계산하고 backpropagation한다.

**(다)**
- 학습되는 것: 가려진 부분을 주변 문맥으로 복원하려면 물체의 모양·구조를 알아야 하므로, network(encoder)가 **이미지의 의미 있는 특징을 추출하는 능력(representation, visual common sense)** 을 학습한다.
- 용도: 학습된 encoder를 **사전 학습된 feature extractor**로 써서, 적은 labeled 데이터로 분류·검출·segmentation 같은 **downstream task에 transfer(fine-tuning)** 한다.

</details>

### 📝 8-3. Contrastive Learning 그림 `2026.04 · 2024 기말 · 2025 기말` (5점 + 5~10점) ✍️

> Anchor(파랑), Positive(초록), Negative(빨강). (가) = Anchor–Positive 거리, (나) = Anchor–Negative 거리. 학습 후 Positive는 가까워지고 Negative는 멀어짐.
> (가) 각 원(circle)이 의미하는 것은? (나) 학습을 위한 loss 계산 방법을 (가)와 (나)의 수식으로 표현하라.

<details>
<summary><b>▶ 모범 답안</b></summary>

**원의 의미**: 각 이미지를 **encoder(DNN, 특징 추출기)에 넣어 얻은 feature vector를 feature 공간의 한 점으로 나타낸 것**이다.
- Anchor: 기준 이미지 / Positive: **같은 이미지를 변형(augmentation)** 한 이미지 / Negative: **다른 이미지**

**Loss (Triplet loss)**

$$L = \max\big(0,\ (가) - (나) + \alpha\big) = \max\big(0,\ \lVert f(a) - f(p)\rVert^2 - \lVert f(a) - f(n)\rVert^2 + \alpha\big)$$

- (가)는 **작아지도록**, (나)는 **커지도록** 학습한다. α(margin)는 negative가 positive보다 최소 α만큼 더 멀어야 한다는 조건. 이미 (나)가 (가)보다 α 이상 크면 loss = 0.
- 예: (가) = 1, (나) = 3, α = 0.5 → 1 − 3 + 0.5 < 0 → loss 0 / (가) = (나) = 2 → loss 0.5
- 학습 대상은 **encoder f의 weight** (세 이미지 모두 같은 weight의 encoder 통과)

</details>

### 📝 8-4. Representation vs Generative Learning `2023 기말 (이번 학기 7주차 내용)` (4점 × 4)

> 1달러 그림 두 장(기억으로 그린 것 = Representation learning, 정밀하게 그린 것 = Generative learning). 각 방법의 (가)(나) 학습 대상, (다)(라) 학습 후 활용 방법은?

<details>
<summary><b>▶ 모범 답안</b></summary>

| | Representation Learning (Self-supervised) | Generative Learning |
|---|---|---|
| 학습 대상 | **(가)** 데이터의 **핵심(high-level semantic) 특징** — 픽셀 디테일 없이 "ONE DOLLAR, 가운데 인물" 같은 구별에 필요한 특징 | **(나)** 데이터 분포 **p_data(x) 자체** — 픽셀 단위 디테일까지 |
| 활용 | **(다)** 학습된 encoder를 feature extractor로 써서 **downstream task(분류·검출 등)에 transfer** | **(라)** 학습한 분포에서 sampling해 **실제 같은 새 데이터 생성** |

- 공통점: 둘 다 **사람의 label 없이** 학습

</details>

### 🎯 8-5. Contrastive 세부 — InfoNCE · SimCLR `7주차 예상`

<details>
<summary><b>▶ 정리</b></summary>

- **목표**: $\text{score}(f(x), f(x^+)) \gg \text{score}(f(x), f(x^-))$, score = cosine similarity (−1 ~ 1) 또는 −거리
- **InfoNCE** (positive 1개 + negative N−1개):
  $L = -\log \frac{\exp(s(f(x), f(x^+)))}{\exp(s(f(x), f(x^+))) + \sum_{j=1}^{N-1} \exp(s(f(x), f(x_j^-)))}$
  - 의미: 전체 score 합 중 **positive score가 차지하는 비율** → **N-way softmax의 cross entropy** = N개 중 positive 찾기
  - loss 0: 분모 ≈ 분자 (negative score ≈ 0) / **negative 개수 N이 클수록 성능 좋음**
- **InfoNCE vs Triplet**: negative 여러 개 + similarity의 softmax 비율 vs negative 1개 + L2 거리 차이 + margin
- **Pretext task 방식의 한계** → contrastive 등장: ① 과제를 일일이 고안하기 번거로움 ② representation이 **특정 pretext task에 묶여** 일반적이지 않음
- **SimCLR** (Google, Hinton): 같은 이미지에 **augmentation 2개** → positive / **같은 mini-batch의 다른 이미지는 모두 negative** → Encoder f(ResNet) → **projection head g(MLP)** → contrastive loss. downstream에는 **g 이전의 h** 사용. **batch가 클수록(negative 많음), epoch가 길수록 좋음** / 단점: 큰 batch → 메모리 부담
- **MoCo**: 이전 batch의 feature를 **queue(dictionary)** 에 쌓아 negative로 재사용 + key encoder는 momentum update → batch 크기와 무관하게 negative 확보

</details>

### 🎯 8-6. 이미지 pretext task 세부 `7주차 예상`

<details>
<summary><b>▶ 정리</b></summary>

- **Rotation (RotNet)**: 가설 — 물체가 원래 어떻게 생겼는지에 대한 **visual commonsense**가 있어야 회전을 맞힐 수 있음. 4-way classification. 결과: label이 적을수록 supervised보다 훨씬 좋음, Pascal VOC transfer에서 supervised(79.9)에 근접(72.97)
- **Jigsaw**: 3×3 = 9 patch를 섞고 순서 맞히기. 경우의 수 **9! = 362,880** → 너무 많아 **미리 정한 permutation 세트(예: 100개) 중 분류**로 바꿈. patch마다 **weight 공유 CNN**
- **Inpainting (Context Encoder)**: 지운 픽셀 복원, encoder–decoder
- **Colorization**: 컬러 이미지를 흑백으로 만들어 입력, 원래 컬러가 정답
- **Super-resolution**: 원본을 축소해 입력, 원본이 정답

</details>

### 🎯 8-7. NLP의 SSL — GPT vs BERT `7주차 예상`

<details>
<summary><b>▶ 정리</b></summary>

| 모델 | 구조 | 방향 | Pretext task |
|---|---|---|---|
| ELMo | 양방향 LSTM | 양방향 | task별 architecture 필요 |
| **GPT** | **Transformer Decoder** (masked self-attention) | **왼→오 단방향** | **다음 단어 예측** (auto-regressive LM) |
| **BERT** | **Transformer Encoder** | **양방향** | **Masked LM**(빈칸 단어) + **NSP**(이어지는 문장인지) |

- 외우기: **GPT = Decoder = 다음 단어 / BERT = Encoder = 빈칸 단어**
- NLP pretext task: Center word(Word2Vec **CBOW**) / Neighbor word(**Skip-gram**) / Neighbor sentence / **Auto-regressive LM(GPT)** / **Masked LM(BERT)** / **NSP(BERT)** / Sentence order prediction(ALBERT) / Sentence permutation·Document rotation(BART) / Emoji prediction(DeepMoji) / Gap sentence prediction(PEGASUS, 요약)
- LLM = 다음 단어·가운데 단어 맞히기로 **언어의 특성을 통계적으로 학습**한 모델. 학습은 실제 다음 단어 = 1인 분포를 정답으로 **cross-entropy + backprop**
- **데이터 양에 따른 모델**: 매우 적음 → 전통 ML / 조금 더 → **inductive bias 높은** CNN·RNN / 매우 많음 → **Transformer** → 개인·일반 회사는 빅테크가 SSL로 학습한 모델을 fine-tuning

</details>

<br/>

---
---

<br/>

# 블록 9 — 최종 점검: 백지 테스트 ⏱ 15분

**아무것도 보지 않고** 키워드 3개씩 말하거나 쓰세요. 막히는 것만 해당 블록으로 돌아갑니다.

| # | 질문 | 키워드 (가리고 보세요) |
|---|---|---|
| 1 | Vanishing gradient 원인 숫자 | sigmoid 미분 최대 **0.25**, 0.25ⁿ, 포화 |
| 2 | Vanishing 해결 3개 | **ReLU**(미분 1), **Xavier/He**, **BN** |
| 3 | Overfitting 원인 | **파라미터 수 대비 데이터 적음** |
| 4 | Gap 큼 / Gap 없음 | overfit → λ↑ dropout early stop / underfit → λ↓ epoch↑ |
| 5 | 학습 멈출 때 | train acc ↑, **val acc 정체·하락** |
| 6 | 최종 모델 선택 / 최종 성능 | **validation 최고** / **test 한 번** (val은 선택에 써서 편향) |
| 7 | λ 크게 | train error ↑, val error ↓ (너무 크면 둘 다 ↑) |
| 8 | 차원의 저주 4 단어 | 고차원 → 데이터 양 지수 증가(k^d) → overfitting → 정확도 ↓ |
| 9 | 저차원으로 줄여도 되는 이유 | 핵심 특징은 적은 차원으로 표현 가능(**latent vector**), 실제 데이터는 **저차원 구조**, 픽셀 간 **상관관계·중복성** |
| 10 | Transfer learning | ImageNet 1000 class, **generic feature**, 위층만 학습 → 적은 데이터 OK |
| 11 | K-NN vs Linear 결과 | **50,000×32×32×3** / **W 10×3072 + b 10** |
| 12 | 가능한 이미지 수 | **256^3072 = 2^24576** |
| 13 | 초기 loss | SVM **C−1**, Softmax **ln C** |
| 14 | cat softmax / SVM 평균 | **2.04** / **5.27** |
| 15 | Update 횟수 (5000, batch 50) | SGD **5000** / mini **100** / batch **1** |
| 16 | 2023 그래프 (가)(나)(다)(라) | **−0.53 / 0.20 / −0.20 / 0.40** |
| 17 | ReLU 속도 문제 | **not zero-centered → zig-zag**, dead ReLU → Leaky·ELU·BN |
| 18 | Optimizer 계보 | Momentum(관성) → Nesterov(look-ahead) / AdaGrad(→0) → RMSProp(지수평균) → **Adam** |
| 19 | Dropout 이유 / test | co-adaptation 방지, ensemble / **p 곱함** |
| 20 | BN·Data Aug.의 randomness | **batch 구성 random** / **변형 파라미터 random** |
| 21 | Rotation / Inpainting 뉴런 | 921,600 → **4** / 921,600 → **300** |
| 22 | Contrastive loss | **max(0, (가) − (나) + α)**, 원 = encoder의 feature vector |
| 23 | GPT / BERT | Decoder·다음 단어 / Encoder·빈칸 단어 + NSP |

<br/>

> **마지막 당부**: 서술형은 **"정의 → 원인/이유 → 해결/예시"** 3단 구조로 쓰세요. 점수를 주는 키워드가 이 순서로 다 들어갑니다.
