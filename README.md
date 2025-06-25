# NewsArticle: 뉴스 기사 기반 유사도 검색 시스템

## 프로젝트 개요 및 목표
이 프로젝트는 한국어 뉴스 기사 데이터를 기반으로 **입력된 문장 또는 키워드에 대해 유사한 기사들을 검색**해주는 시스템입니다.  
`VectorDB`, `Embedding`, `RAG`, `LoRA`, `Quantization`, `Reflexion LLM` 등 다양한 최신 기법들을 단계적으로 실험하며 적용합니다.

### 프로젝트의 최종 목표
> "야구"라는 단어를 입력하면,  
> ▶ LG 트윈스 경기 결과,  
> ▶ 특정 야구 선수의 인터뷰,  
> ▶ 야구장 리모델링 기사 등  
> → **의미적으로 관련된 기사들을 다수 제공**하는 시스템 완성.

---

## 사용 기술 스택

- **데이터 전처리**: Python, pandas, json
- **모델링 & 튜닝**: HuggingFace Transformers, ko-sbert, PEFT (LoRA)
- **임베딩 & 검색**: SentenceTransformer, FAISS or Qdrant
- **RAG**: Retrieval-Augmented Generation (LLM + 검색 결과 조합)
- **경량화 기법**: LoRA, 8-bit Quantization, Knowledge Distillation(예정)
- **성능 측정**: BertScore, Recall@k, MRR
- **UI 구성**: Gradio
- **실험 관리**: Weights & Biases (wandb)
- **환경 관리**: Docker, Conda

---

## 원본 데이터

- **데이터명**: 뉴스 기사 기계독해 데이터
- **제공처**: AI Hub  
- **링크**: [뉴스 기사 기계독해 데이터 (AI Hub)](https://www.aihub.or.kr/aihubdata/data/view.do?pageIndex=1&currMenu=115&topMenu=100&srchOptnCnd=OPTNCND001&searchKeyword=%EA%B8%B0%EC%82%AC&srchDetailCnd=DETAILCND001&srchOrder=ORDER001&srchPagePer=20&aihubDataSe=data&dataSetSn=577)

---

## 프로젝트 구조

```bash
NewsArticle/
├── .devcontainer/
│   ├── Dockerfile            # 도커 환경 설정 파일
│   ├── environment.yml       # conda 환경 정의 (wandb 포함)
│   ├── docker-compose.yml    # Docker 서비스(app, qdrant 등)를 한 번에 정의하고 실행하는 설정 파일
│   ├── devcontainer.json     # 지정한 Docker 환경(Dockerfile or docker-compose.yml)을 자동으로 빌드하고 실행하게 해주는 설정
│   └── upload_changed.sh     # 로컬에서 git을 하고난 뒤, 'docker-sync'를 통해 자동으로 도커에 업데이트하는 파일 // 해당 파일에 사용법 작성 완료
├── .dockerignore             # 캐시/모델/log 제외 설정
├── .gitignore                # wandb/, *.pt, __pycache__ 등 명시
├── .env                      # wandb API key, 포트, 경로 등의 환경변수 저장 (Git 무시 필수)
│
├── data/ 
│   ├── [데이터 명세서 보기](data/README.md)
│   ├── Training/             # AI Hub Train JSON
│   ├── Validation/           # AI Hub Validation JSON
│   └── processed/            # 청크 & metadata JSON
├── models/
│   ├── base_model/           # ko-sbert 초기 모델
│   └── tuned_model/          # fine-tuned 모델 파일
├── embeddings/
│   ├── base_embeddings.npy   # 기사의 기본적인 임베딩 결과 (리소스 절약, 실험 재현성 목적)
│   └── tuned_embeddings.npy  # 완료한 모델로 동일한 뉴스 청크들을 임베딩한 결과
├── tests/                    # 단위 테스트 및 통합 테스트
│   ├── test_embed.py         # 예: 임베딩 정상 작동 확인
│   ├── test_search.py        # 검색 정확성 테스트
│   └── test_rag.py           # RAG 응답 유효성 테스트
│
├── qdrant/
│   └── collection_config.json
├── wandb/                    # wandb 로컬 실험 로그 디렉토리 (.gitignore로 무시 권장)
│   └── latest-run/
├── notebooks/
│   └── embedding_vs_evaluation.ipynb # 평가지표를 계산해 성능을 비교 분석
│
├── src/
│   ├── preprocess.py         # 데이터 파싱 + 청킹
│   ├── embed.py              # embedding 생성/저장
│   ├── search_qdrant.py      # Qdrant 연동, 검색 기능
│   ├── rag.py                # RAG inference 코드
│   ├── optimize.py           # LoRA/Quant/Distill/Reflexion 스크립트
│   └── ui_app.py             # OpenwebUI / Gradio UI 서버
├── eval/
│   ├── metrics.py            # BertScore, Recall@k, MRR 계산
│   └── eval_results.csv
│
├── requirements.txt
└── README.md
```

뉴스 QA 데이터셋 구조 및 필드 설명 추가

---
## 🛠️ 개발 환경 세팅 가이드 (for Docker + Conda)

`.devcontainer/` 디렉토리를 기반으로 **Docker + Conda 환경을 자동 구성** 하는 세팅 가이드
Docker Desktop이 설치되어 있다면, 단 한 번의 설정으로 전체 개발환경이 셋업 가능.


```bash
# Docker 켜기
docker start news-search-container
docker exec -it news-search-container bash 

# Docker 끄기
(base) root@6fc639bce2c4:/app/NewsArticle/.devcontainer# exit
docker stop news-search-container

# gui가 아닌 터미널에서 도커 사용
>> (base) root@6fc639bce2c4:/app

# Conda 활성화 및 비활성화
conda activate news-env
>> (news-env) root@6fc639bce2c4:/app/NewsArticle
conda deactivate 

# 로컬의 작업들을 도커에 업데이트
git add .
docker-sync # git push 전에 할 것. git status에 있어야 함
```
---

### 1. 사전 설치 프로그램

| 도구 | 링크 |
|------|------|
| Docker Desktop | [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/) |
| Git | [https://git-scm.com/downloads](https://git-scm.com/downloads) |
| VSCode | [https://code.visualstudio.com/](https://code.visualstudio.com/) |


---

### 2. Docker 기반 환경 자동 구성 (with VSCode)

> VSCode 기준으로 가장 쉬운 방식

1. `NewsArticle/` 루트 폴더를 VSCode로 열기
2. `F1` 또는 `Ctrl + Shift + P` (`Cmd` on Mac)  
3. `Dev Containers: Rebuild and Reopen in Container` 선택

또는 Local 터미널에서

```bash
# 수동 빌드
# 1. 이미지 빌드
docker build -t news-search-app .devcontainer

# 2. 컨테이너 생성 및 실행
docker run -it --name news-search-container news-search-app
```

#### 구성 결과

- Docker 이미지: `news-search-app`  
- 컨테이너 이름: `news-search-container`  
- Conda 환경: `news-env` (자동 생성)

---

### 3. Conda 환경 구성 방식

`.devcontainer/Dockerfile`과 `environment.yml`을 통해  
`news-env`라는 이름의 Conda 환경이 컨테이너 내에서 자동으로 생성.


```dockerfile
# Dockerfile 일부
RUN conda env create -f environment.yml
SHELL ["conda", "run", "-n", "news-env", "/bin/bash", "-c"]
```

> 이후 모든 명령어는 해당 환경 안에서 실행.

---

### 4. 로컬 변경 사항 컨테이너에 반영하기 (`docker-sync`)

`.devcontainer/upload_changed.sh`를 사용하면,  
`git add`된 파일만 자동으로 Docker 컨테이너 내 `/app/NewsArticle/`에 반영됨.

**git status에 파일이 있어야하므로, push 전에 'docker-sync' 실행**

#### 최초 1회 설정

```bash
chmod +x .devcontainer/upload_changed.sh
alias docker-sync='./.devcontainer/upload_changed.sh'
```

#### 사용 방법

```bash
# 1. 로컬에서 변경된 파일 git add
git add .

# 2. 컨테이너에 변경 반영
docker-sync
```

#### 자동으로 제외되는 항목

- `.env`, `.envs/` 등 민감 정보 포함 파일
- 삭제된 파일 및 이름 변경 파일도 반영됨