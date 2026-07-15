# Week 1 — Generative AI Basics & Python Library Overview

## 강의 자료
- [generative-ai-basics.pdf](./generative-ai-basics.pdf)
- [python-libraries-and-selena-5-step-method.pdf](./python-libraries-and-selena-5-step-method.pdf)

## 강의 내용 정리

### 1. 생성형 AI 개요 및 흐름
ChatGPT의 2022년 11월 30일 공개 이후 두 달 만에 사용자 1억 명을 돌파한 성장 흐름을 시작으로, GPT-4(2023, 초기 멀티모달 입력 지원), GPT-4o(2024년 상반기, 실시간 멀티모달), GPT-o1(2024년 하반기, 단계별 추론에 특화된 "reasoning" 모델), GPT-5(2025년 하반기, Fast/Thinking을 자동 전환하는 단일 통합 시스템)로 이어지는 모델 발전 타임라인을 다룬다.

> **참고**: GPT-5가 GPT-4o 대비 환각(hallucination)을 약 45% 줄였고 o3 대비로는 약 6배 줄였다는 수치는 OpenAI가 자체 발표한 벤치마크 결과이며, 독립적으로 검증된 값은 아니다. 강의 자료를 볼 때 벤치마크 수치는 "제조사 발표치"로 구분해서 받아들일 필요가 있다.

ChatGPT와 생성형 AI(Generative AI)라는 개념의 차이, 그리고 Claude(Anthropic), Gemini(Google), LLaMA(Meta), Perplexity, Google NotebookLM 등 주요 경쟁 서비스를 소개한다.

### 2. 한계와 대응 방안
- **환각(Hallucination)**: "세종대왕이 맥북프로를 던졌다"는 유명한 가짜 역사 생성 사례를 통해 LLM이 그럴듯하지만 사실이 아닌 답을 생성할 수 있음을 설명한다.
- **탈옥(Jailbreaking)**: 안전장치를 우회해 제한된 답변을 유도하는 시도.
- **대응**: RAG(검색 증강 생성)로 외부 지식 기반 근거를 제공하는 방식, Anthropic의 "Constitutional Classifier" 같은 안전 필터링 계층을 소개한다.

### 3. 실제 비즈니스 적용 사례
Amazon Rufus(쇼핑 어시스턴트), Coca-Cola의 AI 설계 신제품 "Y3000", Qatar Airways의 딥페이크 광고 캠페인, Nuvilab의 급식 이미지 인식 서비스, Airbnb 챗봇(문의의 약 50%를 자동 응대)을 예시로 생성형 AI의 실무 적용 범위를 설명한다.

### 4. 프롬프트 엔지니어링 — 6요소 프레임워크
좋은 프롬프트를 구성하는 6가지 요소를 정의하고 각각 예시를 든다.

| 요소 | 의미 |
|------|------|
| 명령(Task) | 무엇을 해달라는 것인지 명확한 지시 |
| 역할(Role) | AI가 취할 페르소나 (예: "마스코트", "법무팀", "안전관리팀" 입장에서 금연 안내문 작성) |
| 맥락(Context) | 상황 배경 정보 |
| 포맷(Format) | 응답 형식 (표, 목록, 코드 등) |
| 톤(Tone) | 어조 (공식적/친근함 등) |
| 예시(Example) | 원하는 결과물의 샘플 제공 |

역할(Role)에 따라 같은 주제(금연 안내문)라도 문체와 어조가 달라지는 예시를 통해 역할 프롬프팅의 효과를 보여준다. 이 외에 Zero-shot, One/Few-shot, Role-prompting 등 프롬프트 스타일과 단계별로 사고 과정을 유도하는 Chain-of-Thought(CoT) 기법을 소개한다.

### 5. 파이썬 라이브러리 개념
ChatGPT가 코드를 "생성"하고 파이썬이 이를 "실행"하는 역할 분담을 요리사(ChatGPT)와 주방 도구(Python)에 빗대어 설명한다. 이번 학기에 사용할 5개 핵심 라이브러리(NumPy, Pandas, Matplotlib, Seaborn, BeautifulSoup)의 역할과 설치·불러오기 방법을 개괄한다. 개발 환경으로는 PyCharm, Jupyter, VS Code, IDLE을 비교하고, 이번 학기 실습 환경인 Google Colab(구글 드라이브 연동, 무료 GPU 제공, 사전 설치된 패키지, 클라우드 기반 협업 편집)의 특징과 설정 절차(드라이브 폴더 생성 → 우클릭 → "더보기" → Google Colaboratory 선택, 공유받은 .ipynb는 "Google Colaboratory로 열기" 후 파일 → 사본 저장)를 안내한다.

### 6. 셀레나의 5단계 학습법
1. **수업 준비** — 수업 전 Colab 환경을 미리 세팅해둔다.
2. **실시간 타이핑 실습** — 강의 중 코드를 직접 따라 타이핑하며 실습한다.
3. **복습** — 수업 직후 출력 결과를 지우고 다시 실행해보며 복습한다.
4. **나만의 강의노트 만들기** — 셀을 추가해 자신만의 코드/설명 노트를 만든다.
5. **Q&A 활용** — 카카오톡 오픈채팅방과 공유 구글시트를 통해 질문한다.
