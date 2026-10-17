# 딥러닝 기초 중간시험 — A4 정리지 (손글씨용 2면)

> **용도**: 시험장에 가져갈 A4 정리지 2면에 **손으로 옮겨 쓸 내용**입니다.
> **범위**: 이번 학기에 배운 1~7주차만. 기출에서 반복된 문제의 **답안 뼈대 + 공식 + 숫자**와 6~7주차 핵심을 넣었습니다. 설명은 [midterm-study-guide.md](./midterm-study-guide.md)에 있습니다.
>
> **쓰는 요령**
> - 한 면에 약 55줄입니다. 작은 글씨로 **좌우 2단**으로 나눠 쓰면 들어갑니다.
> - ★ = 반드시 / ☆ = 공간이 남으면. 모자라면 ☆ 줄부터 빼세요.
> - 화살표(→)와 약어를 그대로 쓰세요. 문장으로 풀어 쓰면 다 안 들어갑니다.
> - **옮겨 쓰는 과정 자체가 마지막 복습입니다.** 직접 쓰세요.

<br/>

---

## 1면 — 공식 · 계산 · 6~7주차

### ① Loss ★
```
SVM   Li = Σ(j≠yi) max(0, sj − syi + 1)     min 0 / max ∞ / W작음 → C−1 (10cls=9)
Soft  Li = −ln( e^syi / Σ e^sj )             min 0 / max ∞ / W작음 → ln C (10cls=2.3)
      유도: s≈0 → e⁰/Σe⁰ = 1/C → −log(1/C) = log C
CE    H(p,q) = −Σ p log q, p=one-hot → 정답 항만  <0,1,0,0>,<.2,.5,.1,.2> → −ln0.5 = 0.693
예제  SVM cat/car/frog 2.9 / 0 / 12.9 → 평균 5.27
      Soft cat: e^3.2=24.5 e^5.1=164 e^-1.7=0.18 → 24.5/188.7=0.13 → −ln0.13 = 2.04
min0 <0,0,0,500> / max∞ <500,500,500,0> (정답 4번)
SVM: margin 넘으면 만족(변화X) / Soft: 확률 1까지 계속 불만족 / e^x: 미분 쉬움, 차이 극대화
```

### ② L(W) = (1/N)ΣLi + λR(W) ★
```
(1) data loss: 정답 score↑ → W를 학습데이터에 fit
(2) reg: W 작고 고르게(simple) → 학습데이터에 종속X → 일반화 (Occam) / L=0인 W 유일X (2W)
λ 작음: train↓ val↑ (overfit) | 큼: train↑ val↓ | 너무 큼: 둘 다↑ (underfit)
L2 Σw² → 작은 값 고르게 [.25×4] > [1,0,0,0] (R 0.25 vs 1) | L1 Σ|w| → sparse
L(W)는 W로 결정 (데이터 고정) | loss space = weight수 + 1 (CIFAR linear 10×3072+1)
SGD: random W → 1개/batch → loss → backprop → W −= η∂L/∂W 반복
   최소 보장X: non-convex → local min/saddle, gradient 근사(noisy) → sub-optimum
```

### ③ 숫자 ★
```
32×32×3 = 3072 | 640×480×3 = 921,600 | 가능한 이미지 256^3072 = 2^24576
K-NN 결과: 학습데이터 전부 50000×32×32×3 + label | Train O(1) Predict O(N)
Linear 결과: W 10×3072 + b 10 (= 30,730) ← 데이터 수 무관
1 epoch update: Batch 1 / Mini N÷B / SGD N   (5000, B=50 → 1 / 100 / 5000)
3-layer FC 3072→6→6→2: 3072×6+6×6+6×2 = 18,480 → loss 공간 18,481
Rotation: 입력 921,600 / 출력 4 | Inpaint 10×10: 출력 10×10×3 = 300, loss MSE
```

### ④ Backprop · Activation ★
```
down = up × local | add 복사 | mul 상대값 곱 | max 큰 쪽만 | branch 합
e^x→e^x  ax→a  1/x→−1/x²  c+x→1   σ' = σ(1−σ) ≤ 0.25
2023 그래프 (가) −1/1.37² = −0.53 (나) 0.20 [=.73×.27] (다) ∂w0=x0×.2=−0.20 (라) ∂x0=w0×.2=0.40
   (다) → w0 update / (라) → 아래 layer로 전달
sigmoid (가)=0.5 → (다) max 0.125 (x=0), min ≈0 (x→±∞) | 0.25¹⁰ ≈ 10⁻⁶
ReLU max(0,x), 미분 1(x>0)/0(x<0) | tanh: zero-centered, 포화O | Leaky max(.01x,x)
ELU 평균≈0 exp비용 | Maxout param 2배 | 실전: ReLU, sigmoid 쓰지 말 것
Xavier randn/√fan_in (Var 1/n) | He /√(fan_in/2) (ReLU) | W=0 → 모든 뉴런 동일
BN x̂=(x−μB)/√(σB²+ε), y=γx̂+β (뉴런별, batch 방향) | FC 뒤 act 앞 | 원인: internal covariate shift
   효과: gradient↑ 큰LR 초기화 덜 민감 reg | test: running avg | γβ: 원하는 분포 학습
```

### ⑤ Optimizer · Regularization (6주) ★
```
SGD 문제: zig-zag(poor cond.) / local min·saddle(고차원은 saddle 多) / noisy grad
Momentum v=ρv+∇, W−=ηv (ρ .9) → 관성, 진동 상쇄 / overshoot
Nesterov 먼저 가본 곳 grad → overshoot↓ | AdaGrad dx/√Σdx² 차원별 균등 → step→0
RMSProp 지수평균(decay .9) | Adam = Mom + RMS + bias corr (β1 .9 β2 .999 lr 1e-3)
gap 줄이기: 여러 모델(ensemble, snapshot) / 한 모델(cyclic LR, Polyak, regularization)
Reg 패턴: train noise 추가 / test marginalize
 Dropout 뉴런 0 (p .5) | BN batch 구성 random | Aug 변형 파라미터 random
 DropConnect weight 0 | Frac.MaxPool 영역 random | Stoch.Depth layer drop
Dropout 이유: co-adaptation 방지 / 공유 param ensemble (2^4096) | test: ×p (E = ½(w1x+w2y))
```

<br/>

---

## 2면 — 서술형 답안 뼈대 (정의 → 원인 → 해결)

### ⑥ 용어 7종 ★
```
[Program vs ML] 사람이 rule 작성: input+program→output (brittle, not scalable)
   ML: input+output(정답)→program(W) 자동 생성, data-driven, train/predict
[Association] label X, 장바구니 함께 사는 상품 {빵}→{우유} → 진열·묶음·추천
[Cls vs Reg] 이산 class vs 연속값 | 덥다/춥다 vs 기온 | 정확도 vs RMSE | 공통 supervised
[차원축소 이유] 차원의 저주(k^d) / overfit 방지 / 계산·저장↓ / 노이즈 제거 / 시각화
[Vanishing] 정의: 역전파 시 gradient가 아래층으로 갈수록 → 0, 아래층 학습X
   원인: sigmoid 미분 ≤0.25 매층 곱(0.25ⁿ), 포화 ≈0 | 해결: ReLU(미분1) / Xavier·He / BN
[Overfitting] 문제: train↑ test(새 데이터)↓ → 일반화 실패
   원인: param 수 대비 데이터 적음, 고차원, 과학습
   해결: 데이터↑·aug / L2·dropout·BN / early stop / transfer / 차원축소
[Perceptron] 그림 x1..xn —w→ Σwx+b → f → y   y = f(Σwᵢxᵢ + b)
   가중합 → 비선형 act → 출력 / w가 출력 결정 → w 찾기 = 학습 / f 없으면 W2W1x = W'x
```

### ⑦ 학습 실전 ★
```
[gap 큼] overfit → (데이터·모델 수정X) λ↑ dropout early-stop BN aug
[gap 없음] underfit(둘 다 낮음) → λ↓ dropout↓ epoch↑ LR 조정 Adam
[멈출 때] train acc↑인데 val acc 정체/↓ (val loss↑) → early stop, val 최고 epoch
[W 매번 다름] hyperparam → loss space 경로 다름 + random init·batch순서·dropout → 다른 local min
[최종 선택] val 최고 | [test 필요] val은 선택에 사용 → 과대평가 / test 미사용 → 진짜 일반화, 1회
[babysit] 초기 loss 2.3 확인 / 20개로 overfit (acc 1.0) / update÷weight ≈ 1e-3
[탐색] coarse→fine, log space, random > grid (중요 param 값 9개 vs 3개)
```

### ⑧ 차원 · Transfer · K-NN/Linear ★
```
[차원의 저주] 고차원 → 필요 데이터 양 지수↑(k^d) → 한정 데이터 sparse, 거리 차이↓
   → overfitting → 분류 정확도↓   (4단어 다 쓰기!)
[저차원 유지 이유] 실제 데이터는 고차원에 고르게X, 저차원 구조에 모임
   이웃 픽셀 강한 상관관계·중복성, 결정 요인(물체·자세·조명) 소수 → latent vector
[FE 없이 FC 직접] param↑ 데이터 같음 → 차원의 저주 → overfit → test↓ / 픽셀 거리 무의미
[t-SNE 2D] 4096-D → 2-D, 비슷한 이미지끼리 모임 → 이웃 관계 유지 → 2D로도 분류 가능
[Transfer] ImageNet 1000cls → visual feature 학습됨 / 아래층 edge·색·질감 = generic
   → 위층(FC)만 적은 데이터로 학습 → param 적음 → overfit X, 시간↓
   유사·적음: linear만 | 유사·많음: 몇 층 | 다름·많음: 더 많은 층 | fine-tune LR 1/10
[Linear 의미] score = x의 1차 함수 → 초평면 경계 → XOR·도넛·여러 덩어리 X, template 1개
   row = template (같은 class와 곱하면 큼) / 말 머리 2개 = 좌우 말 모두 높은 score
[K-NN] k개 voting | 흰 영역 = 동점 | 안 쓰는 이유: test 느림 / 픽셀 거리 무의미 / 차원의 저주
[발전] KNN(O(N)) → Linear(template) → MNN(비선형 act) → DNN(ReLU, BN)
```

### ⑨ ReLU 문제 · SSL (7주) ★
```
[ReLU 속도] ① not zero-centered: ∂L/∂wᵢ = ∂L/∂f·xᵢ, xᵢ>0 → 모든 w 부호 같음 → zig-zag
   ② dead ReLU (x<0 grad 0) | 해결: Leaky·PReLU·ELU, BN, 입력 zero-center, LR↓
[Xavier] 작으면 act→0 vanishing, 크면 포화 → /√fan_in → 층마다 분산 유지
[SSL] label X + 정답 자동생성 pretext → feature extractor → 소량 label로 downstream
   (가) 직접 회전, 회전각 = 정답 / (나) 사람이 붙인 소량 label | 평가 = downstream
[Inpaint] 정답 = 원본 box 픽셀, MSE / 학습: representation(visual commonsense) → transfer
[Contrastive] 원 = encoder가 만든 feature vector (A / P = 같은 이미지 변형 / N = 다른 이미지)
   loss = max(0, (가) − (나) + α)  (가)↓(나)↑ | 학습 대상 = encoder
   InfoNCE = −log[e^pos/(e^pos+Σe^neg)] = N-way softmax CE, N↑ 성능↑
   P 만들기: crop·rotate·color jitter·gray·flip / N: 같은 batch 다른 이미지 (SimCLR, 큰 batch)
[Repr vs Gen] Repr: 핵심 특징(기억 지폐) → downstream transfer / Gen: p(x)(정밀 지폐) → 생성
[GPT/BERT] GPT Decoder 단방향 다음 단어 | BERT Encoder 양방향 Masked LM + NSP
☆ Jigsaw 9! = 362,880 → 정한 permutation 중 분류 | Rotation: visual commonsense 가설
```

<br/>

---

### 옮겨 쓴 뒤 확인 체크

- [ ] 1면: Loss 공식 + 초기 loss(C−1, ln C) + 2.04 / 5.27 / 0.693
- [ ] 1면: 그래프 (가)~(라) = −0.53 / 0.20 / −0.20 / 0.40
- [ ] 1면: Optimizer 계보 + Regularization randomness 표
- [ ] 2면: 용어 7종 "정의 → 원인 → 해결" 키워드
- [ ] 2면: 차원의 저주 4단어, Transfer, gap 2종, 멈출 때, SSL (가)(나), Contrastive loss
