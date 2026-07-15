# Machine Basics

## 강의 자료
- [machine-basics-slides.pdf](./machine-basics-slides.pdf)
- 판서 사진: [whiteboard-storage-and-memory-hierarchy.jpeg](./whiteboard-storage-and-memory-hierarchy.jpeg), [whiteboard-pcie-and-gpu-interconnect.jpeg](./whiteboard-pcie-and-gpu-interconnect.jpeg)

## 강의 내용 정리

컴퓨터를 이루는 기본 하드웨어 요소를 훑어보며 한 학기 동안 다룰 내용의 큰 그림을
잡는 첫 강의입니다. 이후 주차에서 다룰 메모리 계층, GPU 아키텍처, 프로세스 관리
등의 밑그림에 해당합니다.

### 1. 컴퓨터를 이루는 핵심 부품
- **CPU / Register**: 실제 연산을 수행하는 핵심 장치. Register는 CPU 내부에 위치한, CPU가 가장 빠르게 접근할 수 있는 저장 공간.
- **Memory (RAM)**: DRAM 기반의 주기억장치. 전원이 꺼지면 내용이 사라지는 휘발성(volatile) 메모리이며, 강의에서는 예시로 32GB 용량이 언급됨.
- **Storage**: 비휘발성 저장장치로 Magnetic Disk(HDD)와 NAND Flash(SSD)로 구분됨.
  - HDD: 플래터가 회전하며 자기 신호로 데이터를 기록하는 트랙/섹터 구조.
  - NAND Flash: Floating Gate(플로팅 게이트)에 전자를 가두는 방식으로 데이터를 저장하며, 전자가 게이트를 넘나드는 통로를 Trap이라 부름.

### 2. 저장장치 인터페이스의 발전
- **메모리 계열**: RAM(DRAM), PRAM(Persistent/Phase-change RAM 계열) 등 휘발성·비휘발성 메모리가 계층을 이루며 존재.
- **PCIe (PCI Express)**: 세대가 올라갈수록 레인(Lane)당 대역폭이 2배씩 증가합니다. 예를 들어 Gen2는 레인당 약 0.5GB/s, Gen3 약 1GB/s, Gen4 약 2GB/s, Gen5 약 4GB/s 수준입니다. GPU, NVMe SSD, NVLink 등 고속 장치들이 이 PCIe 인터페이스를 공유합니다.
  > 참고: 초기 PCIe(Gen1~2)는 8b/10b 인코딩을 사용해 전송 비트의 약 20%가 오버헤드로 소모되었지만, Gen3부터는 128b/130b 인코딩으로 오버헤드가 약 1.5%까지 줄어 실효 대역폭이 크게 개선되었습니다.
- **I/O Bus / Memory Bus**: CPU와 메모리, 파일시스템(FS), 저장장치 사이를 연결하는 버스 구조.

### 3. 연산 관점의 예시
- 행렬 곱 `A x B = C` 예시를 통해 CPU/GPU가 실제로 수행하는 연산 단위를 소개.
- ALU, 연산 노드(Ring Node) 등 GPU 내부 연산 구조에 대한 도입부 설명. (자세한 GPU 아키텍처는 [04-gpu-architecture](../04-gpu-architecture) 참고)

> 이번 강의는 판서 위주로 진행되어 세부 개념은 이후 주차(메모리 계층, GPU 아키텍처 등)에서 이어서 다룹니다.
