# 딥러닝 기초 W02 — Image Classification Pipeline

> 과목: 딥러닝 기초 (낭종호 교수) / 2026-2학기
> 범위: Lecture 2 Image Classification Pipeline
> 기본 교재: Stanford CS231n (2017) Lecture 2 기반
> 후반부에 3주차 주제(Loss Function & Optimization) 도입부까지 다룸

---

## 0. 도입 — 기계 학습, 딥러닝, 생성 AI

### 0-1. 기계 학습과 딥러닝
- **기계 학습(Machine Learning)**: 사람이 rule을 직접 만들지 않고, **데이터로부터 rule을 자동으로 만들어내는 것**임 (Data-Driven)
- **딥러닝(Deep Learning)**: 뉴런(neuron)을 여러 층으로 연결한 구조(Neural Network)로 문제를 푸는 방법임
- 아이디어 자체는 오래전부터 있었으나, 다음 문제들 때문에 오랫동안 잘 풀지 못했음
  - **Vanishing Gradient**: 층이 깊어질수록 gradient가 0에 가까워져 앞쪽 층이 학습되지 않음
  - **Overfitting**: 학습 데이터에만 과하게 맞춰져 새로운 데이터에서 성능이 떨어짐
  - **Local Minima**: loss가 가장 작은 지점(global minimum)이 아닌 곳에 갇힘

### 0-2. 생성 AI (Generative AI)와 Foundation Model
- **생성 AI**: 딥러닝 모델을 이용해 **데이터를 생성**하는 AI임
  - 이미지 생성 모델: GAN, Stable Diffusion 등
  - 텍스트 생성 모델: LLM (Large Language Model)
- **Foundation Model**: 복잡한 문제를 풀려면 뉴런(파라미터)이 많아야 하고, 많은 뉴런을 학습시키려면 학습 데이터도 대량으로 필요함 → 초대규모 데이터로 사전 학습한 거대 모델임
- 생성 모델은 학습 데이터에서 배운 패턴을 조합해서 **질문과 가장 그럴듯한 답을 무조건 만들어냄**
  - 학습 데이터에 똑같은 답이 없어도 답을 생성함 → **환각(Hallucination)은 학습 기반 생성의 근본적인 특성**임
- 분류든 생성이든 **어떤 학습 데이터로 학습했느냐**에 따라 결과가 결정됨
  - 예) 같은 이미지 생성 모델이라도 학습 데이터에 따라 디즈니 스타일 / 실사 / 인물 얼굴 등 결과가 달라짐

---

## 1. 기계 학습의 분류 (Classical Machine Learning)

| 구분 | 데이터 | 세부 유형 | 예시 |
|---|---|---|---|
| **Supervised (지도 학습)** | 정답(label)이 있음 | **Classification**: 카테고리 예측 | 스팸 메일 분류, 양말 색깔별 분류 |
| | | **Regression**: 숫자(연속값) 예측 | 넥타이 길이 예측, 곡선 fitting |
| **Unsupervised (비지도 학습)** | 정답이 없음 | **Clustering**: 유사도로 묶기 | 비슷한 옷끼리 쌓기 (K-Means, DBSCAN 등) |
| | | **Dimension Reduction**: 차원 축소 (generalization) | 고차원 데이터를 저차원으로 투영 |
| | | **Association**: 숨은 연관 규칙 찾기 | 같이 입는 옷 조합 찾기 |
| **Semi-Supervised** | 일부만 label | Generative models | GAN (Generator vs Discriminator) — GAN 자체는 label 없이 학습하는 생성 모델이며, semi-supervised 학습에 활용되는 대표 사례로 분류한 것 |
| **Reinforcement (강화 학습)** | 보상(reward) | Agent ↔ Environment | Action → State, Reward 피드백 |

- **GAN 구조**: Latent Space + Noise → Generator(G)가 가짜 샘플 생성 → Discriminator(D)가 진짜/가짜 판별 → 판별 결과로 fine-tune 학습
- **Dimension Reduction 관련 포인트**: 모델링에 선택한 feature는 전체 진실(truth)의 **저차원 투영(projection)**일 뿐임
  - 원기둥을 한쪽에서 보면 사각형, 다른 쪽에서 보면 원으로 보이는 것처럼, 어떤 차원(feature)으로 데이터를 보느냐가 일종의 인지 편향(cognitive bias)이 됨

---

## 2. Image Classification (이미지 분류)

### 2-1. 정의
- 컴퓨터 비전의 핵심 과제(core task)임
- **미리 정해진 이산 label 집합** `{dog, cat, truck, plane, ...}` 중에서 입력 이미지에 **하나의 label(혹은 확률 분포)** 을 할당하는 문제임
- 사람에게는 쉽지만 컴퓨터에게는 어려움
- 참고: 학습된 모델(Pre-trained Models) 모음 → https://cv.gluon.ai/model_zoo/index.html

### 2-2. 컴퓨터 안의 이미지 표현
- 이미지 = **픽셀(pixel)들의 격자(grid)**
- **해상도(resolution)**: 가로×세로 픽셀 수 (예: 640×480)
- **RGB 모델**: 각 픽셀을 R, G, B 3개 채널의 조합으로 표현함
  - 채널당 8bit → 값의 범위 `[0, 255]`
  - 픽셀당 24bit → 2²⁴ = 약 **1,677만 색(True Color)**
  - 사람의 시각은 이 이상의 색 차이를 구별하지 못하므로 24bit면 충분함
- 따라서 이미지 1장은 **고차원 벡터**임
  - 800×600 RGB 이미지 → `800 × 600 × 3 = 1,440,000`차원
  - 640×480 RGB 이미지 → `640 × 480 × 3 = 921,600`차원

> **멀티미디어와 사람의 감각**
> - 멀티미디어: 정보를 전달할 때 사람의 **여러 감각 기관을 동시에 자극**하는 것임
> - 사람의 감각은 **큰 자극이 오면 작은 자극을 느끼지 못함** (Masking 효과) → 대포 소리와 총소리가 동시에 나면 대포 소리만 들림
> - 컴퓨터–사람 인터랙션은 결국 사람의 감각 기관이 구별 가능한 수준으로 데이터를 전달하는 것임

### 2-3. The Problem: Semantic Gap
- 사람은 고양이를 보면 바로 "Cat"이라는 **의미(Semantic Label, idea of cat)** 를 인식함
- 컴퓨터가 보는 것은 **[0, 255] 사이 숫자의 거대한 격자(gigantic grid of numbers)** 일 뿐임
- 이 둘 사이의 간극이 **Semantic Gap**임
- 핵심 질문: **이런 숫자들로부터 어떻게 "catness(고양이다움)"를 추출할 것인가?**

### 2-4. Challenges — 왜 어려운가?

| Challenge | 의미 |
|---|---|
| **Viewpoint variation** | 고양이는 그대로여도 **카메라가 움직이면 모든 픽셀 값이 바뀜** |
| **Illumination** | 조명 조건에 따라 픽셀 값이 크게 달라짐 |
| **Deformation** | 변형, 자세 변화 (고양이는 가장 변형이 심한 동물임) |
| **Occlusion** | 가려짐 — 객체의 일부만 보임 (담요 밑 얼굴, 소파 밑 꼬리) |
| **Background Clutter** | 배경이 객체와 비슷해서 구분이 어려움 |
| **Intraclass variation** | 같은 class(cat)인데도 shape, color, texture가 달라 **픽셀 값이 서로 다름** |
| **Scale** | 객체의 크기가 이미지마다 다름 |

- **Feature가 Robust(강건한) / Invariant(변치 않는)하다는 것의 의미**
  - 위와 같은 변화(시점, 조명, 변형, 가림, 크기 등)가 생겨도 **추출된 feature 값이 크게 변하지 않는다**는 뜻임
  - 좋은 feature는 같은 class면 비슷한 값, 다른 class면 다른 값을 내야 함

---

## 3. Rule-Based → Data-Driven Approach

### 3-1. Image Classifier 함수
```python
def classify_image(image):
    # Some magic here?
    return class_label
```
- 입력: Image / 출력: Class Label
- 숫자 정렬과 달리 **고양이를 인식하는 알고리즘을 hard-coding할 명확한 방법이 없음**

### 3-2. Rule-Based (Hand-made rules) 시도와 한계
- 이미지 → Edge 검출 → Corner 검출 → 사람이 정한 규칙으로 판단
- 문제점
  1. **Super brittle**: 조금만 조건이 달라져도 쉽게 깨짐
  2. **Not scalable**: class마다 다른 rule을 사람이 일일이 만들어야 함

### 3-3. Data-Driven Approach (= 기계 학습)
1. 이미지와 label로 이루어진 **데이터셋 수집**
2. 기계 학습으로 **classifier 학습**
3. 새로운 이미지로 **classifier 평가**

```python
def train(images, labels):
    # Machine learning!
    return model

def predict(model, test_images):
    # Use model to predict labels
    return test_labels
```
- **Classifier를 프로그래밍하지 말고 자동 생성하자**는 것이 핵심임
- 기존(함수 1개)과 달리 **train / predict 2개의 함수**로 구성됨
- **Model** = 각 class에 대한 rule의 집합
  - 학습 데이터(training set)를 이용해 ML 알고리즘이 각 class의 rule을 자동 생성함

---

## 4. Nearest Neighbor (NN, 최근접 이웃)

### 4-1. 동작 방식
- **train**: 모든 학습 데이터와 label을 **그냥 저장(memorize)** 함 → 학습할 게 없음
- **predict**: test 이미지를 **모든 학습 이미지와 비교**하여 **가장 비슷한(거리가 가장 가까운) 이미지의 label**을 출력함

### 4-2. Nearest Neighbor의 의미 — Feature Space 상의 점
- 256×256 흑백 이미지 1장 = **256×256 = 65,536차원 공간의 점 1개**
- 가능한 서로 다른 이미지의 수
  - 8bit 흑백(픽셀당 256단계): `256^(256×256) = 2^(8×256×256)`가지
  - 1bit 흑백(이진 이미지): `2^(256×256)`가지
- 즉, NN은 **데이터 공간에서 나와 가장 가까운(비슷한) 데이터를 찾아가는 방법**임

### 4-3. Feature Vector 기반 검색
- 실제로는 원본 픽셀을 직접 비교하기보다, **이미지에서 특징(feature)을 추출**해서 feature vector 사이의 거리를 계산함
- Image Retrieval 구조: `Query Image → Feature Extraction → Feature(vector) Space에서 Distance Measure → 가장 가까운 이미지 반환`

```
학습 데이터                      질의
<0.3, 0.2, 0.9>, cat            <0.3, 0.2, 0.8>, ???
<0.5, 0.7, 0.6>, dog
<0.1, 0.2, 0.3>, cat            → 가장 가까운 <0.3, 0.2, 0.9>의 label인 cat으로 분류
...
<0.6, 0.5, 0.8>, car
```
- 고차원 feature 공간을 **2차원 평면으로 투영(t-SNE 등)** 하면 비슷한 이미지끼리 모여 있는 것을 볼 수 있음

> 참고: Elasticsearch/OpenSearch의 kNN(vector) search도 같은 원리임 — 임베딩 벡터를 저장해두고 `l2`, `cosine`, `dot_product` 등의 거리/유사도로 가장 가까운 k개를 찾음. 대규모에서는 전수 비교 대신 ANN(Approximate Nearest Neighbor, HNSW 등) 인덱스를 사용함

### 4-4. 예시 데이터셋: CIFAR-10
- **10 classes**: airplane, automobile, bird, cat, deer, dog, frog, horse, ship, truck
- **학습 이미지 50,000장 / 테스트 이미지 10,000장**
- 이미지 1장: **32×32, 24-bit color** → `32 × 32 × 3 = 3,072`개의 숫자
- 대표적인 벤치마크 데이터셋임

---

## 5. Distance Metric (거리 측정 방법)

### 5-1. L1 (Manhattan) distance
```
d₁(I₁, I₂) = Σ_p | I₁ᵖ − I₂ᵖ |
```
- **픽셀별로 차이의 절댓값을 구해서 모두 더함** (pixel-wise absolute value differences)

**계산 예시 (4×4 이미지)**
```
test image          training image      |차이|
56  32  10  18      10  20  24  17      46  12  14   1   → 73
90  23 128 133   −   8  10  89 100  =   82  13  39  33   → 167
24  26 178 200      12  16 178 170      12  10   0  30   → 52
 2   0 255 220       4  32 233 112       2  32  22 108   → 164
                                                   합계 = 456
```

### 5-2. L2 (Euclidean) distance
```
d₂(I₁, I₂) = √( Σ_p ( I₁ᵖ − I₂ᵖ )² )
```
- 두 점 사이의 **직선 거리**임

### 5-3. Manhattan vs Euclidean 예시
- 격자에서 가로 3칸, 세로 3칸 떨어진 두 점
  - Manhattan: `3 + 3 = 6`
  - Euclidean: `√(3² + 3²) = √18 ≈ 4.24`

### 5-4. L1 vs L2의 기하학적 차이
| | L1 (Manhattan) | L2 (Euclidean) |
|---|---|---|
| 원점에서 거리가 1인 점들의 모양 | **마름모(◇)** | **원(○)** |
| 좌표축 의존성 | 좌표축을 회전하면 거리가 바뀜 (축에 의존) | 좌표축을 회전해도 거리 불변 |
| K=1일 때 결정 경계 | **경계가 좌표축을 따라(수평/수직) 움직임** | 경계가 좀 더 자유로운 방향으로 형성됨 |
| 적합한 경우 | 각 feature가 개별적인 의미를 가질 때 | feature 간 의미 구분이 없는 일반 벡터일 때 |

- L2 그림의 원 위 두 점은 **원점 (0,0)으로부터의 거리가 같음**
- Demo: http://vision.stanford.edu/teaching/cs231n-demos/knn/

### 5-5. Cosine Similarity
```
sim(A, B) = cos(θ) = (A · B) / (‖A‖ × ‖B‖)
          = Σ Aᵢ×Bᵢ / ( √(Σ Aᵢ²) × √(Σ Bᵢ²) )
```
- 두 벡터의 **크기가 아닌 방향(각도)** 으로 유사도를 측정함
- 값의 범위 `[-1, 1]`, 1에 가까울수록 같은 방향(유사)
- 텍스트 임베딩 비교 등에서 많이 사용함

### 5-6. Jaccard Similarity
```
J(A, B) = |A ∩ B| / |A ∪ B|
```
- **집합** 간 유사도 = 교집합 크기 / 합집합 크기
- 예) A = {▲, ★, ■}, B = {⬢, ★} → 교집합 {★}, 합집합 {▲, ★, ■, ⬢} → `J = 1/4`

### 5-7. 기타 자주 쓰이는 거리 함수
| 이름 | 식 / 의미 |
|---|---|
| **Minkowski** | `d = (Σ |xᵢ − yᵢ|ʳ)^(1/r)` — r=1이면 L1, r=2이면 L2인 일반화 형태 |
| **Chebyshev** | `d = maxᵢ |xᵢ − yᵢ|` — 차이가 가장 큰 차원 하나로 거리 결정 (Minkowski r→∞) |
| **Canberra** | `d = Σ |xᵢ − yᵢ| / |xᵢ + yᵢ|` — 차이를 값의 크기로 정규화 |
| **Hamming** | 같은 길이의 두 문자열/비트열에서 서로 다른 위치의 개수 |
| **Levenshtein** | 한 문자열을 다른 문자열로 바꾸는 최소 편집(삽입/삭제/치환) 횟수 (BITCOIN ↔ ALTCOIN) |
| **Sørensen–Dice** | `2|A∩B| / (|A| + |B|)` |
| **Mahalanobis** | 데이터 분포(공분산)를 고려한 거리 |
| **Pearson / Spearman** | 상관계수 기반 유사도 (Spearman은 순위 기반) |
| **Jensen-Shannon / Chi-Square** | 확률 분포(히스토그램) 간의 차이 |

- 참고: https://towardsdatascience.com/17-types-of-similarity-and-dissimilarity-measures-used-in-data-science-3eb914d2681

---

## 6. K-Nearest Neighbors (K-NN)

### 6-1. 개념
- NN은 **가장 가까운 1개**의 label을 그대로 복사함
- K-NN은 **가장 가까운 K개**를 찾아서 **다수결 투표(majority vote)** 로 class를 결정함
- **K=1이면 NN과 동일**함

### 6-2. 결정 영역 그림 해석 (What does this look like?)
- **공간**: Feature space
- **각 점**: 학습 데이터 (색 = class)
- **각 색 영역**: 그 위치에 질의 데이터가 오면 분류될 class 영역 (각 class에 속하는 데이터의 분포)
- **K=1**: 초록 영역 안에 노란 점 하나(**noise**)가 있어도 그 주변이 노란 섬처럼 분리됨 → noise에 민감함
- **K=3, K=5**: K가 커질수록 경계가 부드러워지고 noise 영향이 줄어듦
- **흰색 영역**: 가장 가까운 K개의 투표 결과 **동점**이 나와 class를 정할 수 없는 영역임

### 6-3. 그림을 그리는 프로그램 구조
```
foreach xᵢ in Feature_space              # 공간의 모든 좌표에 대해
    foreach yⱼ in training_data          # 모든 학습 데이터와
        dᵢⱼ = compute_distance(xᵢ, yⱼ)   # 거리 계산
    closest_Nᵢ = find_closest_neighbors_k(dᵢⱼ)   # 가장 가까운 k개 선택
    classᵢ = majority_voting(closest_Nᵢ)          # 다수결로 class 결정 → 해당 색으로 칠함
```

### 6-4. 간단 구현 (numpy, L1 기준 NN)
```python
import numpy as np

class NearestNeighbor:
    def train(self, X, y):
        # X: (N, D) 학습 데이터, y: (N,) label → 그냥 저장
        self.Xtr = X
        self.ytr = y

    def predict(self, X):
        # X: (M, D) 테스트 데이터
        y_pred = np.zeros(X.shape[0], dtype=self.ytr.dtype)
        for i in range(X.shape[0]):
            distances = np.sum(np.abs(self.Xtr - X[i]), axis=1)  # L1 거리 (N개 전부 계산)
            y_pred[i] = self.ytr[np.argmin(distances)]           # 가장 가까운 것의 label
        return y_pred
```

### 6-5. 시간 복잡도 (N개의 학습 데이터)
- **Train: O(1)** — 저장만 함
- **Predict: O(N)** — 질의마다 N개 전부와 거리 계산
- 실제 서비스에서는 **학습은 느려도 되지만 예측은 빨라야** 하므로 정반대의 특성임 → 큰 단점

### 6-6. Hyperparameters
- **최적의 K는?** / **어떤 distance를 쓸 것인가?**
- 이런 값들이 **Hyperparameter**임: 학습으로 얻는 값이 아니라 **알고리즘에 대해 사람이 미리 설정하는 값**
- 문제에 크게 의존(very problem-dependent)하므로, 여러 값을 시도해 보고 가장 잘 되는 것을 골라야 함

### 6-7. Hyperparameter 설정 방법
| 방법 | 내용 | 평가 |
|---|---|---|
| **Idea #1** | 전체 데이터에서 가장 잘 되는 값 선택 | **BAD** — 학습 데이터에서는 K=1이 항상 100% 맞음 |
| **Idea #2** | train / test로 나누고 test에서 가장 잘 되는 값 선택 | **BAD** — test에 맞춰버려서 새로운 데이터에서의 성능을 알 수 없음 |
| **Idea #3** | **train / validation / test**로 나누고, validation으로 값을 고른 뒤 test로 최종 평가 | **Better!** |

- test 데이터는 **맨 마지막에 한 번만** 사용해야 진짜 일반화 성능을 알 수 있음
- 참고: 데이터가 적을 때는 train을 여러 fold로 나눠 번갈아 validation으로 쓰는 **Cross-Validation**도 사용함

### 6-8. K-NN을 이미지 분류에 거의 사용하지 않는 이유
1. **Very slow at test time** — 예측할 때마다 모든 학습 데이터와 비교함
2. **픽셀 단위 거리(distance metrics on pixels)는 의미 있는 정보가 아님** — 이미지를 조금 이동/어둡게/가리기만 해도 거리가 크게 변하고, 서로 다른 변형의 이미지들이 원본과 같은 L2 거리를 가질 수도 있음
3. **Curse of Dimensionality (차원의 저주)** — 이미지는 고차원인 반면 학습 데이터는 상대적으로 적기 때문에, 학습 데이터 간 거리 차이가 별로 없어져 분류 결과가 의미 없어짐

---

## 7. 차원의 저주 (Curse of Dimensionality)

- **feature(차원) 수가 늘어나면, 정확하게 일반화하는 데 필요한 데이터 양이 기하급수적으로 증가함**
- 각 축을 10칸으로 나누는 경우
  - 1차원: 10칸
  - 2차원: 10² = 100칸
  - 3차원: 10³ = 1,000칸
  - 같은 밀도로 공간을 채우려면 데이터가 지수적으로 필요함
- 전체 데이터의 **20%를 포함**하는 영역의 한 변 길이
  - 1차원: 0.2
  - 2차원: √0.2 ≈ **0.45**
  - 3차원: ∛0.2 ≈ **0.58**
  - 차원이 높아질수록 "가까운 이웃"을 찾기 위해 공간의 훨씬 넓은 범위를 봐야 함 → "가깝다"는 의미가 약해짐

### 해결 방향
- **Dimension Reduction (차원 축소)**: 입력 데이터의 차원을 줄여서 사용함
- **Latent Vector (잠재 벡터)**: 입력 데이터의 차원을 줄이고 **핵심 특징만 뽑아낸 압축 표현(엑기스)** 임
- **Foundation Model 활용**: 대규모 데이터로 사전 학습된 모델로 고차원 데이터를 의미 있는 저차원 임베딩으로 변환 → 고차원 데이터에서도 문제를 풀 수 있게 하는 방법 중 하나임

---

## 8. Linear Classification (선형 분류기)

### 8-1. Parametric Approach
```
f(x, W) = Wx + b
```
| 기호 | 의미 | 크기 (CIFAR-10) |
|---|---|---|
| **x** | 입력 이미지를 한 줄로 편 벡터 (32×32×3) | 3072 × 1 |
| **W** | parameters (weights) | 10 × 3072 |
| **b** | bias | 10 × 1 |
| **f(x, W)** | 10개 class의 score | 10 × 1 |

- 학습해야 할 파라미터 수: `10 × 3072 + 10 = 30,730`개
- 출력: **class별 score 10개** → 가장 큰 score의 class로 분류

### 8-2. K-NN과의 차이
| | K-NN | Linear Classifier |
|---|---|---|
| 학습 결과 | **모든 학습 데이터를 그대로 보관(keep)** | 학습 데이터의 특징을 **W(parameter)에 압축 저장** |
| 예측 시 비교 대상 | 학습 데이터 전체 | class별 대표 이미지(template) 1개씩 |
| 예측 비용 | O(N) | 행렬곱 1번 (학습 데이터 수와 무관) |
| 예측 후 학습 데이터 | 필요함 | **필요 없음** (W만 있으면 됨) |

- 이 **W**가 이후 Deep Neural Network의 **weight**와 같은 의미임

### 8-3. 계산 예시 (4픽셀 이미지, 3개 class)
```
입력 x = [56, 231, 24, 2]ᵀ  (2×2 이미지를 한 줄로 폄)

         W                       x       b          score
[ 0.2  -0.5   0.1   2.0 ]     [ 56]   [ 1.1]     [ -96.8 ]  Cat
[ 1.5   1.3   2.1   0.0 ]  ×  [231] + [ 3.2]  =  [ 437.9 ]  Dog
[ 0.0   0.25  0.2  -0.3 ]     [ 24]   [-1.2]     [  60.75]  Ship
                              [  2]
```
- Cat: `0.2×56 − 0.5×231 + 0.1×24 + 2.0×2 + 1.1 = 11.2 − 115.5 + 2.4 + 4.0 + 1.1 = −96.8`
- Dog: `1.5×56 + 1.3×231 + 2.1×24 + 0.0×2 + 3.2 = 84 + 300.3 + 50.4 + 0 + 3.2 = 437.9`
- Ship: `0×56 + 0.25×231 + 0.2×24 − 0.3×2 − 1.2 = 0 + 57.75 + 4.8 − 0.6 − 1.2 = 60.75`
- 고양이 이미지인데 Dog score가 가장 큼 → **이 W는 나쁜 W**임
- 참고: CS231n 원본 슬라이드에는 Ship score가 61.95로 적혀 있으나, 이는 bias −1.2를 더하지 않은 값 (61.95 − 1.2 = 60.75)

### 8-4. 해석 1 — Template (Prototype) Matching
- **Score = 이미지 픽셀들의 weighted sum** (1차 함수)
- W의 각 row(3072개 값)가 **한 class의 template(대표 이미지)** 임 → **One template for each class**
- cat 이미지의 score가 크게 나오려면 **W_cat이 cat 이미지와 비슷한 패턴**이어야 함
  - 입력과 template을 픽셀별로 곱해서 더함(내적) → 패턴이 비슷할수록 값이 커짐 → 사실상 **유사도 계산**임
- 즉, class별 대표 이미지 하나씩만 두고, 테스트 이미지와 가장 비슷한 대표 이미지의 class를 따라가는 방법임
- **template을 어떻게 만드는가? → 학습에 의해** 만들어짐

**CIFAR-10으로 학습된 W를 이미지로 시각화한 결과**
- plane, ship: 파란 배경(하늘/바다) → 배경색이 template에 강하게 반영됨
- car: 가운데 빨간 형체
- deer, frog: 초록/갈색 배경
- **horse: 머리가 2개인 말** 형상 → 학습 데이터에 머리가 왼쪽인 말과 오른쪽인 말이 모두 있어서, 둘 다 높은 score를 내도록 template이 합쳐졌기 때문임
- → class당 template이 **1개뿐**이라는 것이 linear classifier의 한계임

### 8-5. 해석 2 — 기하학적 관점 (Linear의 의미)
```
Sᵢ = Wᵢ,₁ × X₁ + Wᵢ,₂ × X₂ + Wᵢ,₃ × X₃ + … + Wᵢ,₃₀₇₂ × X₃₀₇₂ (+ bᵢ)
```
- **입력 값에 W를 곱해서 더하기만 함** → score는 입력 데이터에 대한 **1차 함수(선형 함수)** 임
  - 1차 함수: `y = ax + b` 처럼 입력에 곱하고 더하기만 하는 형태
  - 2차 함수: `y = ax² + ...` 처럼 입력을 제곱하는 항이 있는 형태
- 각 image는 3072차원 공간의 점이고, 각 class의 classifier는 `Wᵢ₁X₁ + Wᵢ₂X₂ + … + WᵢₙXₙ + bᵢ = 0` 형태의 **직선(고차원에서는 초평면, hyperplane)** 임
- 그 직선을 기준으로 한쪽(화살표 방향)이면 score가 양수 → 해당 class 쪽
- W를 바꾸면 직선이 회전하고, b를 바꾸면 직선이 평행 이동함

### 8-6. Linear Classifier로 풀기 어려운 경우 (Hard cases)
| Case | Class 1 | Class 2 | 이유 |
|---|---|---|---|
| 1 | 양수 좌표 개수가 **홀수**인 사분면 (2, 4사분면) | 짝수인 사분면 (1, 3사분면) | XOR 형태 → 직선 하나로 분리 불가 |
| 2 | L2 norm이 1~2 사이 (**도넛 모양**) | 나머지 | 원형 경계 → 직선 불가 |
| 3 | **떨어진 3개의 영역(Three modes)** | 나머지 | 여러 덩어리 → 직선 하나로 불가 |

- → 비선형 경계가 필요함 → 이후 **Neural Network (비선형 활성화 함수)** 로 해결함

### 8-7. W가 좋은지 나쁜지 어떻게 판단하는가?
| class | 고양이 이미지 | 자동차 이미지 | 개구리 이미지 |
|---|---|---|---|
| airplane | -3.45 | -0.51 | 3.42 |
| automobile | -8.87 | **6.04** | 4.64 |
| bird | 0.09 | 5.31 | 2.65 |
| cat | **2.9** | -4.22 | 5.1 |
| deer | 4.48 | -4.19 | 2.64 |
| dog | 8.02 | 3.58 | 5.55 |
| frog | 3.78 | 4.49 | **-4.34** |
| horse | 1.06 | -4.37 | -1.5 |
| ship | -0.36 | -2.09 | -4.79 |
| truck | -0.72 | -2.93 | 6.14 |

- 고양이: 정답 cat(2.9)보다 dog(8.02), deer(4.48), frog(3.78)가 큼 → **나쁨**
- 자동차: 정답 automobile(6.04)이 가장 큼 → **좋음**
- 개구리: 정답 frog(-4.34)가 거의 최하위 → **매우 나쁨**
- → **W가 얼마나 좋은지를 수치로 나타낼 방법이 필요함** → Loss Function

### 8-8. Coming up
- **Loss function**: "좋은 W"가 무엇인지를 정량화
- **Optimization**: 랜덤한 W에서 시작해서 loss를 최소화하는 W를 찾음
- **ConvNets**: 함수 f의 형태 자체를 바꿈

---

## 9. Loss Function & Optimization 도입 (3주차 예고)

### 9-1. Loss (손실)
- **Loss Function과 Optimization은 W를 알아내는 방법**임
- **Loss**: 내가 원하는 정답과 모델이 실제로 출력한 값 사이의 **차이**
- 학습 데이터 1개에 대한 loss가 `Lᵢ`일 때, 전체 학습 데이터에 대한 loss는 **평균**임
```
L(W) = (1/N) × Σᵢ Lᵢ( f(xᵢ, W), yᵢ )
```
- **학습(training)의 목적 = 모든 학습 데이터에 대한 평균 loss를 작게 만드는 W를 찾는 것**임
- 모델 출력과 정답의 차이를 계산하는 방법으로 가장 많이 쓰이는 것이 두 가지 있으며, 다음 강의에서 다룸 (CS231n 기준: Multiclass SVM(Hinge) loss, Softmax(Cross-Entropy) loss)

### 9-2. Loss Space와 Gradient Descent
- 학습 데이터가 고정돼 있으면 **loss는 W에 의해서만 결정**됨 → loss는 W의 함수 `L(W)`
- **Loss Space**: W(예: w₁, w₂)를 축으로, 각 W에서의 loss를 높이로 그린 공간
  - 목표: loss가 가장 작아지는 지점의 (w₁, w₂)를 찾는 것
- **Gradient Descent**: loss가 작아지는 방향(기울기의 반대 방향)으로 **W를 조금씩 바꿔나가는 방법**임
- 어떤 loss 함수를 쓰느냐에 따라 loss space의 모양이 달라지고, 최솟값을 찾아가는 경로도 달라짐
- **Global minimum**(전체에서 가장 작은 지점)이 이상적이지만, 도달한다는 **보장은 없음** → local minimum에 머물 수 있음
- 그래서 Optimization은 "완벽한 최적해"보다 **충분히 좋은(loss가 충분히 작은) W**를 찾는 과정으로 이해하면 됨

---

## 참고. 딥러닝에서 많이 사용하는 함수

### 지수 함수와 로그 함수
- `y = eˣ`와 `y = log x`는 **역함수 관계** → 직선 `y = x`에 대해 대칭임
  - 예) `(1.8, 6)`이 `y = eˣ` 위의 점이면 `(6, 1.8)`은 `y = ln x` 위의 점
- `y = eˣ`: 항상 양수, x=0일 때 1
- `y = log x`: x>0에서만 정의, x=1일 때 0
- 지수 ↔ 로그 변환: `aᵇ = c ⇔ log_a c = b`
  - 예) `5² = 25 ⇔ log₅ 25 = 2`

### y = −log(x)
- x → 0 이면 y → ∞, x = 1 이면 y = 0
- x ∈ (0, 1]인 **확률 값**에 적용하면, 확률이 1에 가까울수록 0, 0에 가까울수록 매우 큰 값이 됨
- → 정답 class의 확률이 낮을수록 큰 벌점을 주는 **Softmax(Cross-Entropy) loss**의 기반이 됨

## 참고. Color Space
| Color Space | 방식 | 설명 |
|---|---|---|
| **RGB** | 가산 혼합 (Additive, 빛) | Red, Green, Blue를 더함. (0,0,0) = Black, (255,255,255) = White. R+G = Yellow, G+B = Cyan, R+B = Magenta |
| **CMYK** | 감산 혼합 (Subtractive, 물감/인쇄) | Cyan, Magenta, Yellow (+ Key=Black). 섞을수록 어두워짐 |
| **HSV** | 원기둥 좌표 | **H**ue(색상, 각도), **S**aturation(채도), **V**alue(명도) — 사람이 색을 인지하는 방식에 가까움 |

---

## 기출 문제 (중간고사)

### 기출 1. k-Nearest Neighbor
**(a) N개의 학습 데이터를 이용하는 경우 Train 및 Predict 시의 시간 복잡도는? (5점)**
- Train: **O(1)**, Predict: **O(N)**

**(b) "k"가 의미하는 것은? (5점)**
- 질의 이미지가 어떤 class에 속하는지를, feature space에서 질의 데이터 point로부터 **거리가 가장 가까운 k개 데이터의 class**를 구하고, 이들의 **class voting**으로 질의 데이터의 class를 결정한다는 의미임

**(c) K-NN 결정 영역 그림은 어떤 space를 나타낸 것인가? 각 점과 영역의 의미는? (5점)**
- Space: **Feature space**
- 각 점: **학습 데이터**
- 영역: **각 class에 속하는 데이터의 분포**

**(d) 그림을 생성하는 프로그램의 대략적인 구조는? (5점)**
```
foreach xᵢ in Feature_space
    foreach yⱼ in training_data
        dᵢ,ⱼ = compute_distance(xᵢ, yⱼ)
    closest_Nᵢ = find_closest_neighbors_k(dᵢ,ⱼ)
    classᵢ = majority_voting(closest_Nᵢ)
```

**(e) 아주 가까운 주위에 다른 점들이 있는데도 흰색인 영역이 있는 이유는? (5점)**
- 가장 가까운 k개 학습 데이터의 class로 voting한 결과 **동점**이 나왔기 때문임

**(f) k-NN을 이미지 분류에 거의 사용하지 않는 이유 3가지 (5점)**
1. **Very slow at test time**
2. **Distance metrics on pixels are not informative**
3. **Curse of Dimensionality**: 이미지 데이터의 차원은 고차원인 데 반해 학습 데이터가 상대적으로 적기 때문에, 학습 데이터별 distance의 차이가 별로 없어서 분류 결과가 의미 없어지는 현상

### 기출 2. Linear Classifier (서술형, 15점)
**(a) Linear Classifier를 학습시킨 후 W의 각 row를 이미지로 형상화하면 각 class의 average 이미지(template)가 만들어지는 이유는? (5점)**
- 학습 과정에서 각 class별로 **해당 class 학습 데이터의 pixel 값과 곱했을 때 큰 값이 나오도록**(학습 데이터와 비슷한 pixel 패턴을 갖도록) W의 row 값을 변경하고, **다른 class에 속한 이미지의 pixel 값과 곱했을 때는 작은 값이 되도록** 변경하기 때문임

**(b) classifier가 왜 직선인가? 즉 linear classifier라고 하는 이유는? (5점)**
- `W₁₁X₁ + W₁₂X₂ + … + W₁ₙXₙ = 0` 과 같이 **X에 대한 1차 식**이기 때문임

**(c) horse class의 template이 머리가 2개인 말 형상으로 나온 이유는? (5점)**
- 학습 데이터에 머리가 왼쪽에 있는 말 이미지와 오른쪽에 있는 말 이미지가 모두 있어서, **두 경우 모두 높은 score가 나오도록** 학습되다 보니 머리가 2개인 template이 만들어졌음

---

## 용어 정리

| English | 한국어 | 설명 |
|---|---|---|
| Supervised Learning | 지도 학습 | 정답(label)이 있는 데이터로 학습 |
| Unsupervised Learning | 비지도 학습 | 정답 없이 데이터 구조를 학습 |
| Reinforcement Learning | 강화 학습 | 보상(reward)을 최대화하도록 행동 학습 |
| Classification | 분류 | 이산적인 카테고리 예측 |
| Regression | 회귀 | 연속적인 수치 예측 |
| Clustering | 군집화 | 유사한 데이터끼리 묶기 |
| Dimension Reduction | 차원 축소 | 고차원 데이터를 저차원으로 변환 |
| Semantic Gap | 의미적 간극 | 픽셀 숫자와 사람이 인식하는 의미 사이의 차이 |
| Viewpoint variation | 시점 변화 | 카메라 위치에 따른 픽셀 변화 |
| Illumination | 조명 | 조명 조건 변화 |
| Deformation | 변형 | 객체 형태/자세 변화 |
| Occlusion | 가려짐 | 객체 일부가 가려짐 |
| Background Clutter | 배경 혼잡 | 배경이 객체와 비슷함 |
| Intraclass variation | 클래스 내 변이 | 같은 class 내 외형 차이 |
| Robust / Invariant | 강건한 / 불변의 | 변화에도 feature 값이 유지됨 |
| Data-Driven Approach | 데이터 기반 접근 | 데이터로부터 rule을 자동 생성 |
| Nearest Neighbor (NN) | 최근접 이웃 | 가장 가까운 학습 데이터의 label을 따름 |
| K-Nearest Neighbors (K-NN) | K-최근접 이웃 | 가장 가까운 K개의 다수결 |
| Feature Space | 특징 공간 | feature vector들이 놓인 공간 |
| Distance Metric | 거리 척도 | 두 데이터 간 거리 계산 방법 |
| L1 / Manhattan distance | 맨해튼 거리 | 차이 절댓값의 합 |
| L2 / Euclidean distance | 유클리드 거리 | 직선 거리 |
| Cosine Similarity | 코사인 유사도 | 두 벡터의 방향(각도) 유사도 |
| Jaccard Similarity | 자카드 유사도 | 교집합 / 합집합 |
| Majority Vote | 다수결 투표 | 가장 많이 나온 class 선택 |
| Hyperparameter | 하이퍼파라미터 | 학습 전에 사람이 정하는 값 (k, distance 등) |
| Validation Set | 검증 데이터 | hyperparameter 선택용 데이터 |
| Cross-Validation | 교차 검증 | fold를 번갈아 validation으로 사용 |
| Curse of Dimensionality | 차원의 저주 | 차원이 커질수록 필요한 데이터가 지수적으로 증가 |
| Latent Vector | 잠재 벡터 | 핵심 특징만 뽑은 저차원 표현 |
| Foundation Model | 파운데이션 모델 | 대규모 데이터로 사전 학습한 거대 모델 |
| Hallucination | 환각 | 사실이 아닌 그럴듯한 내용을 생성하는 현상 |
| Linear Classifier | 선형 분류기 | `f(x, W) = Wx + b` |
| Parametric Approach | 파라메트릭 접근 | 학습 데이터 특징을 파라미터(W)에 저장 |
| Weight (W) | 가중치 | 입력에 곱해지는 학습 파라미터 |
| Bias (b) | 편향 | 입력과 무관하게 더해지는 값 |
| Score | 점수 | class별 출력값 |
| Template Matching | 템플릿 매칭 | class 대표 이미지와의 유사도로 분류 |
| Hyperplane | 초평면 | 고차원 공간에서의 선형 결정 경계 |
| Loss Function | 손실 함수 | 정답과 모델 출력의 차이를 정량화 |
| Optimization | 최적화 | loss를 최소화하는 W를 찾는 과정 |
| Gradient Descent | 경사 하강법 | loss가 줄어드는 방향으로 W를 조금씩 갱신 |
| Global / Local Minimum | 전역 / 지역 최솟값 | 전체 최소 / 주변에서만 최소 |
| Vanishing Gradient | 기울기 소실 | 깊은 층에서 gradient가 0에 가까워짐 |
| Overfitting | 과적합 | 학습 데이터에만 과하게 맞춰짐 |

---

## 학습 체크리스트

- [ ] Supervised / Unsupervised / Reinforcement Learning의 차이와 각 세부 유형을 설명할 수 있는가?
- [ ] Semantic Gap이 무엇인지 설명할 수 있는가?
- [ ] 이미지 분류를 어렵게 만드는 Challenge 7가지를 말할 수 있는가?
- [ ] Feature가 Robust/Invariant하다는 의미를 설명할 수 있는가?
- [ ] Rule-based 방식의 문제점 2가지와 Data-Driven Approach의 구조(train/predict)를 설명할 수 있는가?
- [ ] L1 distance를 직접 계산할 수 있는가? (예시 결과 456)
- [ ] L1과 L2의 기하학적 차이(마름모 vs 원, 좌표축 의존성)를 설명할 수 있는가?
- [ ] Cosine / Jaccard Similarity 식을 쓸 수 있는가?
- [ ] K-NN 결정 영역 그림에서 점, 영역, noise, 흰색 영역의 의미를 설명할 수 있는가?
- [ ] K-NN 결정 영역 그림을 그리는 프로그램 구조를 쓸 수 있는가?
- [ ] K-NN의 Train/Predict 시간 복잡도를 말할 수 있는가?
- [ ] Hyperparameter의 정의와 train/validation/test 분리가 필요한 이유를 설명할 수 있는가?
- [ ] K-NN을 이미지 분류에 쓰지 않는 이유 3가지를 말할 수 있는가?
- [ ] 차원의 저주를 예시(10 → 100 → 1000, 0.2 → 0.45 → 0.58)로 설명할 수 있는가?
- [ ] `f(x, W) = Wx + b`에서 CIFAR-10 기준 x, W, b, 출력의 크기를 말할 수 있는가?
- [ ] 4픽셀 예시의 score를 직접 계산할 수 있는가?
- [ ] Linear Classifier를 Template Matching 관점으로 설명할 수 있는가?
- [ ] W의 row가 class template이 되는 이유와 horse template의 머리가 2개인 이유를 설명할 수 있는가?
- [ ] "Linear"라고 부르는 이유와 Linear Classifier로 풀 수 없는 경우를 설명할 수 있는가?
- [ ] Loss의 정의, 전체 loss(평균), 학습의 목적을 설명할 수 있는가?
- [ ] Gradient Descent의 개념과 global minimum을 보장할 수 없다는 점을 이해했는가?
- [ ] `y = −log(x)` 그래프의 모양과 loss에서 쓰이는 이유를 설명할 수 있는가?