# Dockerfile

# 1. 베이스 이미지: Miniconda가 설치된 환경
FROM continuumio/miniconda3

# 작업 디렉토리
WORKDIR /app

# conda 환경 파일 복사 (devcontainer 내부 경로 기준)
COPY .devcontainer/environment.yml /app/environment.yml

# conda 환경 생성
RUN conda env create -f environment.yml

# 기본 쉘 환경 설정
SHELL ["conda", "run", "-n", "news-env", "/bin/bash", "-c"]
                             # conda 환경 이름을 'news-env'로 설정
# 이후 명령은 conda 환경에서 실행됨
RUN echo "Conda env is ready!"

