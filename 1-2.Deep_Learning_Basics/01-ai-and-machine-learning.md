# 딥러닝 기초 W01 — 인공지능과 기계학습

> 과목: 딥러닝 기초 (낭종호 교수) / 2026-2학기
> 범위: 강의자료 1~25p (수업자료 기준)
> 참고 교재: Stanford CS231n (2017 Spring)

---

## 1. 산업혁명과 AI의 위치

| 차수 | 기술 | 대체 대상 |
|---|---|---|
| 1차 | Steam Engine | 사람의 **육체노동** |
| 2차 | Electricity, Automobile | 사람의 **육체노동** |
| 3차 | PC, Internet | (정보 처리 자동화) |
| 4차 | **Artificial Intelligence** | 사람의 **지적노동(?)** |

핵심은 4차 산업혁명이 처음으로 "지적노동" 영역을 건드린다는 점.

---

## 2. AI ⊃ Machine Learning ⊃ Deep Learning

```
Artificial Intelligence (1950s~)
 ├─ 지식표현 (Knowledge Representation)
 ├─ 추론 (Inference)
 └─ Machine Learning (1980s~)
      └─ Deep Learning (2010s~)
```

- **AI**: 사람의 지적 활동을 기계로 구현하려는 분야 전체. 지식표현·추론도 AI의 한 갈래.
- **Machine Learning**: AI의 하위 분야 중 하나. "학습"으로 문제를 푸는 접근.
- **Deep Learning**: ML을 **neural network 구조**로 구현하는 방법론.

> 강의 포인트: "기계학습을 하는 방법 중 하나가 neural network를 이용하는 것 = deep learning". Deep learning이 등장하면서 machine learning의 성능이 비약적으로 좋아졌다.

---

## 3. 컴퓨터에게 쉬운 것과 어려운 것

| | Easy | Hard |
|---|---|---|
| 컴퓨터 | 복잡한 수식 계산, **명확히 정의된 algorithm** 수행 | 인식(recognition), 상황 판단 |
| 사람 | 얼굴/사물 인식, 언어 이해 | 빠른 수치 계산 |

**왜 이런 차이가 나는가 (강의 설명)**

- 컴퓨터는 **수식을 빨리 계산할 목적**으로 설계됨 → 연산장치(CPU)와 저장장치(memory)가 **분리**되어 있음 (von Neumann 구조).
- 사람의 뇌는 **neuron 자체가 계산도 하고 저장도** 함. 계산과 메모리가 분리되어 있지 않음.
- 뇌 = neuron들이 연결된 network → **Neural Network**라는 이름의 유래.

> "사람이 진화 과정에서 자연스럽게 터득한 것들이 컴퓨터에게는 어렵다."

### 규칙 기반(rule-based) 접근의 한계

강아지 vs 머핀, 강아지 vs 프라이드치킨, 개 vs 대걸레 사진 예시.
→ "귀가 있으면 개다" 같은 **rule을 사람이 일일이 정의하는 방식은 실패**한다. 예외가 무한히 많기 때문.

---

## 4. Machine Learning의 정의

> Machine learning is the subfield of computer science that "gives computers the ability to learn without being explicitly programmed."
> (명시적으로 프로그래밍하지 않고도 학습할 수 있는 능력을 컴퓨터에 부여하는 분야)

### 일반적인 programming vs 기계학습

| | 입력 | 출력 |
|---|---|---|
| **일반 programming** | inputs + **program** | outputs |
| **Machine Learning** | inputs + **outputs** | **program** |

핵심: 기계학습은 **입력과 출력 사이의 연관관계를 자동으로 찾아내어 program(= 모델)을 기계가 직접 작성**하게 하는 것.

---

## 5. 예제: 아파트 가격 예측 (Regression)

### 입력 feature (4차원)
- 평수(평)
- 층수(층)
- 가장 가까운 지하철 역까지의 거리(km)
- 해당 지역의 1인당 소득 평균(천만원)

| 평수 | 층수 | 역거리(km) | 소득 | 실제가격(천만원) |
|---|---|---|---|---|
| 34 | 15 | 1 | 4 | 72 |
| 32 | 4 | 5 | 3.3 | 60 |
| 18 | 9 | 2 | 2.5 | 34 |
| 42 | 3 | 2.5 | 5 | 100 |
| 21 | 10 | 1.5 | 3 | 42 |

### (a) 일반적인 방법 — 사람이 계수를 직접 정함

```
평수 × 2 + 층수 × 0.3 + 역거리 × (-1) + 소득 × 0.1 = 가격
```
→ 이 `2, 0.3, -1, 0.1`을 **사람이 감으로 정해야** 한다는 게 문제.

### (b) 기계학습 방법

1. 계수 □, △, ○, ☆ 를 **random**으로 초기화한다.
2. 예측값과 실제값의 차이를 제곱해서 평균 낸다 → **Loss** (여기서는 MSE).
   - 모두 1로 두었을 때: `(실제가격 − 추론가격)²`의 평균 = **287.524**
3. 이 Loss가 작아지는 방향으로 □, △, ○, ☆ 를 **조금씩 조정**한다.
4. Loss가 충분히 작아지면 program 완성.

### Gradient Descent (경사하강법)

- 왜 필요한가? feature가 4개뿐이면 값을 몇 가지씩 다 넣어봐도 되지만, **차원이 커지면 모든 조합을 시도하는 것은 불가능**하다.
- 그래서 Loss 함수의 **기울기(gradient)** 를 구해서, **Loss가 감소하는 방향으로 파라미터를 조금씩 이동**시킨다.
- 이동 폭을 결정하는 값이 **learning rate**.

```
w ← w − η · ∂Loss/∂w      (η = learning rate)
```

---

## 6. 기계학습의 종류

### 6.1 Supervised Learning (지도학습)
- **Input + label(정답)** 을 함께 주고 학습.
- 푸는 문제: **Classification(분류)**, **Regression(회귀)**
- **Self-Supervised Learning (자기지도학습)**: label을 사람이 붙이는 게 아니라 **데이터 자체로부터 정답을 자동 생성**해서 supervised learning을 수행. → LLM이 대표적 (다음 단어 맞히기).

### 6.2 Unsupervised Learning (비지도학습)
- **Input만** 주고 학습 (label 없음).
- 푸는 문제: **Clustering(군집화)**, **Association(연관규칙)**, **Dimensionality Reduction(차원축소)**, 압축(compression)

### 6.3 Reinforcement Learning (강화학습)
- label 대신 **reward**가 주어짐.
- Agent ↔ Environment 사이에서 State / Action / Reward 순환.
- 푸는 문제: Action selection, Policy learning
- → **본 과목에서는 다루지 않음.** 지도학습·비지도학습 중심. (강화학습은 별도 과목)

### 문제 유형 결정 흐름도

```
Problem
 ├─ labeled data? YES → Supervised Learning
 │     ├─ Category  → Classification
 │     │      (Neural Network, Logistic Regression, Random Forest,
 │     │       Naive Bayes, SVM)
 │     └─ Quantity  → Regression
 │            (SVM, Neural Network, Ridge Regression, Random Forest, Lasso)
 └─ labeled data? NO  → Unsupervised Learning
       ├─ Group      → Clustering
       │      (K-means, Gaussian Mixture, DBSCAN,
       │       Spectral Clustering, Hierarchical Clustering)
       └─ Lower Dim. → Dimensionality Reduction
              (PCA, LDA, Isomap, Autoencoder)
```

---

## 7. Regression vs Classification

| | Regression | Classification |
|---|---|---|
| 목적 | **연속적인 수치** 예측 | **class(label)** 예측 |
| 출력 변수 | Continuous | Categorical (Discrete) |
| 예시 | 내일 기온은 몇 도인가? | 내일은 덥나 춥나? |
| 예시 2 | 대출 가능 금액(Loan Amount) | 대출 승인 여부(Approved/Rejected) |
| 성능 평가 | **RMSE** (Root Mean Squared Error) | **정확도**(Percentage of correct classifications) |

공통점:
- 둘 다 **supervised learning** 기법이다.
- 둘 다 데이터 간 관계를 배우는 **training phase**가 있다.
- 학습 데이터에 **input과 output이 모두** 있어야 한다.

> 정리: Classification은 "미리 정해놓은 label 중에서 하나를 고르는 문제", Regression은 "값을 맞히는 문제".

---

## 8. Unsupervised Learning 세부

### Clustering (군집화)
- 유사도(similarity)를 기준으로 데이터를 나눔.
- 예: Targeted Marketing, 고객 세분화

### Association (연관 규칙)
- "고객들이 어떤 상품을 **함께** 구매하는가?"
- 장바구니 안 상품들 사이의 association / correlation을 찾음.
- 예: Customer Recommendation (추천 시스템)

### Dimensionality Reduction (차원 축소)
> Dimensionality reduction is simply the process of reducing the dimension of your feature set.

**왜 필요한가?**

1. **Curse of Dimensionality (차원의 저주)**
   - 1차원에서 구간을 6등분해 데이터를 채우려면 6개.
   - 2차원이면 6² = 36개, 3차원이면 6³ = 216개.
   - **차원이 d일 때 같은 밀도를 유지하려면 6^d 개의 데이터가 필요** → 차원이 100이면 6^100 개.
   - 즉 **차원이 늘어나면 필요한 학습 데이터 양이 지수적으로 폭증**한다.
2. **Overfitting** 방지
   - 고차원 데이터인데 데이터 개수가 적으면 overfitting이 발생하기 쉽다.

**방법**: PCA, LDA, Isomap, Autoencoder
3차원 데이터를 2차원 평면에 투영(projection)해서 다루기 좋은 형태로 바꾸는 식.

---

## 9. Applications 정리

| 학습 방식 | 대표 응용 |
|---|---|
| Supervised — Classification | Image Classification, Fraud Detection, Customer Retention, Diagnostics |
| Supervised — Regression | Forecasting, Predictions, Process Optimization, New Insights |
| Unsupervised — Clustering | Recommender Systems, Targeted Marketing, Customer Segmentation |
| Unsupervised — Dim. Reduction | Structure Discovery, Feature Elicitation, Meaningful Compression, Big Data Visualisation |
| Reinforcement | Real-Time Decisions, Game AI, Robot Navigation, Skill Acquisition |

---

## 10. Deep Learning

### 10.1 Machine Learning Timeline

| 연도 | 사건 | 인물 |
|---|---|---|
| 1943 | Electronic Brain (adjustable weights, 학습은 X) | McCulloch–Pitts |
| 1957 | **Perceptron** (learnable weights) | Rosenblatt |
| 1960 | ADALINE | Widrow–Hoff |
| 1969 | **XOR Problem** → Dark Age 시작 | Minsky–Papert |
| 1986 | Multi-layered Perceptron + **Backpropagation** | Rumelhart–Hinton–Williams |
| 1995 | SVM (kernel) | Vapnik–Cortes |
| 2006 | Deep Neural Network (Pretraining) → Golden Age 2 | Hinton–Salakhutdinov |

- **Golden Age 1** (1960s) → **Dark Age / AI Winter** (1969~1980s) → **Golden Age 2** (2006~)
- 1980년대에 neural network 아이디어는 나왔지만 잘 안 되어서 사그라들었고, **2012년 이후 다시 붐**이 일어남.

### 10.2 Perceptron (Artificial Neural Network)

생물학적 neuron(Dendrite → Cell body → Axon → Axon Terminal) 구조를 모방.

```
y = f(wx + b)

w = [w₁ w₂ w₃ ... wₙ]
x = [x₁ x₂ x₃ ... xₙ]ᵀ
```

- **inputs (x)**: 이전 층 뉴런의 출력값
- **weights (w)**: 연결의 강도 → **학습으로 알아내야 하는 값**
- **b (bias)**: 편향
- **transfer function (Σ)**: 가중합
- **activation function (f)**: 비선형 함수. 예를 들어 **sigmoid**

```
sigmoid: f(x) = 1 / (1 + e⁻ˣ)
```

> 핵심: "입력이 들어왔을 때 어떤 출력이 나오는지는 **w(연결 강도)** 가 결정한다. 그래서 **w를 알아내는 것이 곧 학습**이다."

### 10.3 딥러닝의 정의

> 딥러닝은 **deep neural network**를 통해 학습하는 것을 의미한다.

| Hidden layer 수 | 명칭 |
|---|---|
| ≤ 1 | **shallow network** |
| ≥ 2 | **deep network** |

구조: `input layer → hidden layer 1 → hidden layer 2 → output layer`

→ 남는 질문: **이렇게 많은 weight 값들을 어떻게 학습시킬 것인가?**

### 10.4 하이퍼파라미터는 정답이 없다

layer 수, 뉴런 수, **activation function** 종류, **learning rate** 등은 수학적으로 유도되는 게 아니라 **try & error**로 찾아야 한다.

→ 그래서 **많이 돌려본 쪽이 유리**하고, **GPU를 얼마나 갖고 있는가**와 **좋은 학습 데이터를 얼마나 갖고 있는가**가 실전 성능을 좌우한다.

**실습 도구**: Tensorflow Playground — https://playground.tensorflow.org/
(Epoch, Learning rate, Activation, Regularization, Batch size, Test loss / Training loss를 눈으로 확인 가능)

---

## 11. 딥러닝을 어렵게 하는 3가지 문제

### 11.1 Vanishing Gradient Problem
- Backpropagation으로 gradient를 뒤로 전달할수록 **값이 점점 작아짐**.
- 원인: **sigmoid의 미분값 최대치가 1/4**. 여러 layer를 거치며 (1/4)ⁿ 꼴로 곱해져 0에 수렴.
- 결과: **입력에 가까운 아래쪽 layer는 학습이 거의 일어나지 않음**.
- **해결 → sigmoid 말고 ReLU를 쓰자.**

### 11.2 Overfitting Problem
- **데이터가 많지 않을 때** 발생하기 쉬움.
- 학습 데이터에만 과도하게 최적화되어, **학습하지 않은 test data에 대한 추론 성능이 악화**되는 현상.
- 다항식 fitting 예: M=3은 적당히 맞고, **M=9는 학습점을 모두 통과하지만 곡선이 요동침**.
- Underfitting ↔ **Balanced** ↔ Overfitting
- **해결 → Regularization method를 쓰자 (예: dropout).**
- 그 외 대응: 학습 데이터를 늘리기, 차원 축소(feature 추출) 후 학습.

### 11.3 Get Stuck in Local Minima
- Loss space가 울퉁불퉁해서, **시작점에 따라 local minima에 빠질 위험**이 있음.
- "ConvNets: till 2012 — common wisdom: training does not work because we get stuck in local minima"
- **해결 → 실제로는 local minima에 빠져도 괜찮다**는 것이 밝혀짐 (고차원에서는 대부분 saddle point이고, local minima들의 성능 차이가 크지 않음).

> **정리: 세 문제의 해결 방안은 이미 다 나와 있는 상황.**

---

## 12. (참고) 이후 전개 — Generative AI

수업 뒷부분에서 언급된 흐름. 다음 주차 이후 본격적으로 다룸.

- 2017년 Google, **"Attention is All You Need"** 논문 → **Transformer** 등장.
- Transformer를 여러 층 쌓아 **LLM (Large Language Model)** 로 발전.
- **Attention**: 자기 자신의 입력만 보는 게 아니라, **다른 위치의 입력값들을 함께 고려**해서 결과를 내는 방식.
- **Foundation Model**: Internet scale에서 **task agnostic pre-training** 후, task별 별도 학습 없이 활용 (**Transfer Learning**).
  - natural language → GPT
  - computer vision → Stable Diffusion
- 최근에는 classification/regression 모델보다 **generative model**(데이터를 생성하는 모델)의 비중이 커짐.
- GAN / VAE / Diffusion Model의 삼각 트레이드오프: High Quality Samples ↔ Fast Sampling ↔ Mode Coverage(Diversity)
- **Hallucination**: AI가 **실재하지 않는, 학습 데이터 어디에도 없는 출력**을 생성하는 현상.

---

## 13. 필기 내용 검토 및 정정

| 필기 내용 | 판정 | 정정 |
|---|---|---|
| "모든 파라미터를 다 돌려볼 수 없으니 랜덤하게 값을 부여하고 Loss가 작아지는 방향으로 조금씩 조정" | ✅ 정확 | gradient descent의 정확한 요약 |
| **"파라미터 = 데이터의 행 수"** | ❌ **오류** | **Parameter는 모델이 학습하는 값(weight, bias)** 이다. 데이터의 행 수는 **sample 수 (N)**. |
| **"차원 = 데이터의 열(속성) 수"** | ✅ 맞음 | 정확히는 **feature 수 = 입력 차원 d**. |
| "차원의 저주: 차원 * 차원??" | ⚠️ 보완 | 곱셈이 아니라 **지수**. 축당 k구간이면 필요 데이터는 **k^d** (강의 예: 6, 6², 6³...). |
| "오버피팅: 학습 데이터가 그대로 나와버림" | ⚠️ 표현 보완 | 정확히는 "학습 데이터에만 최적화되어 **test data 성능이 나빠지는** 것". 학습 데이터를 외운다는 뉘앙스는 맞음. |
| "보통 데이터의 특징을 추출해서 차원을 축소한 다음 학습" | ✅ | overfitting 대응책 중 하나. 그 외 데이터 증량, regularization(dropout). |
| "경사하강법: 영향을 가장 많이 주는 가중치를 줄여나가는 방법?" | ⚠️ **부정확** | "가중치를 줄인다"가 아니라 **Loss를 줄이는 방향으로 가중치를 조정(증가/감소 모두)** 한다. 방향은 `−∂Loss/∂w`. |
| "어텐션: 다른 뉴런들의 입력값을 같이 고려" | ✅ 대략 맞음 | 정확히는 **입력 sequence 내 다른 위치들과의 관련도(가중치)를 계산**해 반영. |
| "에포크: 전체 데이터를 다 돌려보는 것?" | ✅ 맞음 | **1 epoch = 전체 학습 데이터를 한 번 모두 통과시킨 것**. |
| "Loss space = 결과의 오차 범위" | ⚠️ 정정 | Loss space는 **파라미터(w) 공간 위에 정의된 Loss 함수의 지형**. 그 지형의 골짜기를 찾는 게 학습. |
| "Vanishing gradient: 레이어를 내려올수록 에러가 희미해진다" | ✅ 정확 | 원인이 **sigmoid 미분 최대 1/4** 이라는 점을 함께 기억. |

### 음성 요약(STT) 오류 정정

| STT 표기 | 정정 |
|---|---|
| "2012년에 구글에서 어텐션 이즈 올 유 니드 발표" | **2017년**. (2012년은 AlexNet으로 딥러닝 붐이 시작된 해 — 두 사건이 섞임) |
| "골드네이지" | **Golden Age** |
| "그레디언트 디센트 / 경사 하암법" | **Gradient Descent / 경사 하강법** |
| "크래시피케이션 / 트레시피케이션" | **Classification** |
| "리그레션 / 리브레이션" | **Regression** |
| "컨터테티브" | **Quantitative** |
| "언슈파이드 러닝" | **Unsupervised Learning** |
| "러닝 네이트" | **Learning Rate** |
| "이포크" | **Epoch** |
| "유론 / 요 유론" | **Neuron** |
| "롯" | **Loss** |
| "레이얼" | **Layer** |
| "디멘전 리덕션" | **Dimensionality Reduction** |
| "레프리엔테이션" | **Representation** (Knowledge Representation) |
| "룰 뱅크 기계 학습" | **Rule-based** 와 혼동. 문맥상 지도학습 회귀 예제 설명 |

---

## 14. 핵심 용어 정리 (한/영)

| English | 한국어 | 설명 |
|---|---|---|
| Supervised Learning | 지도학습 | input + label로 학습 |
| Unsupervised Learning | 비지도학습 | input만으로 학습 |
| Self-Supervised Learning | 자기지도학습 | 데이터에서 label을 자동 생성 |
| Reinforcement Learning | 강화학습 | label 대신 reward |
| Classification | 분류 | 이산 label 예측 |
| Regression | 회귀 | 연속 값 예측 |
| Clustering | 군집화 | 유사도 기반 그룹화 |
| Association | 연관규칙 | 함께 나타나는 항목 탐색 |
| Dimensionality Reduction | 차원축소 | feature 차원 줄이기 |
| Curse of Dimensionality | 차원의 저주 | 차원↑ → 필요 데이터 지수 증가 |
| Loss | 손실 | 예측값과 정답의 차이 척도 |
| Gradient Descent | 경사하강법 | Loss 감소 방향으로 w 갱신 |
| Learning Rate | 학습률 | w 갱신 폭 |
| Epoch | 에포크 | 전체 데이터 1회 순회 |
| Weight | 가중치 | 뉴런 간 연결 강도, 학습 대상 |
| Bias | 편향 | 가중합에 더해지는 상수 |
| Activation Function | 활성화 함수 | 비선형 변환 (sigmoid, ReLU) |
| Hidden Layer | 은닉층 | input/output 사이의 층 |
| Shallow / Deep Network | 얕은/깊은 신경망 | hidden layer ≤1 / ≥2 |
| Vanishing Gradient | 기울기 소실 | 하위 layer 학습 안 됨 |
| Overfitting | 과적합 | 학습 데이터에만 최적화 |
| Regularization | 정규화 | overfitting 억제 (dropout 등) |
| Local Minima | 지역 최솟값 | 전역 최솟값이 아닌 골짜기 |
| Transfer Learning | 전이학습 | 사전학습 모델을 다른 task에 활용 |
| Hallucination | 환각 | 근거 없는 출력 생성 |

---

## 15. 스스로 점검 체크리스트

- [ ] AI / ML / DL의 포함 관계를 그림으로 그릴 수 있는가?
- [ ] 일반 programming과 machine learning의 입출력 차이를 설명할 수 있는가?
- [ ] 아파트 가격 예제에서 Loss를 직접 계산해볼 수 있는가?
- [ ] Gradient Descent가 필요한 이유(조합 폭발)를 설명할 수 있는가?
- [ ] Regression과 Classification을 문제/출력/평가지표 3가지 축으로 구분할 수 있는가?
- [ ] Curse of Dimensionality를 k^d 형태로 수식화해 설명할 수 있는가?
- [ ] Perceptron 식 `y = f(wx + b)`의 각 항이 무엇인지 말할 수 있는가?
- [ ] shallow / deep network의 기준(hidden layer 수)을 아는가?
- [ ] 딥러닝의 3대 난제와 각각의 해결책을 짝지을 수 있는가?
- [ ] Vanishing gradient의 원인이 sigmoid 미분값(최대 1/4)임을 설명할 수 있는가?

---

## 16. 다음 주차 예고 (강의계획서 기준)

**2주차: Image Classification Pipeline**
- CS231n 기반. train/val/test split, KNN, Linear Classifier 등으로 이어질 가능성이 높음.
- 이번 주 Loss 개념이 3주차 **Loss Function and Optimization**으로 직결됨.