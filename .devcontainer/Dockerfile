# 1. 베이스 이미지: Miniconda가 설치된 환경
FROM continuumio/miniconda3

# 2. 시스템 패키지 업데이트 및 편집기(vim) 설치
RUN apt-get update && apt-get install -y vim

# 3. 작업 디렉토리 설정
WORKDIR /app

# 4. conda 환경 파일 복사
COPY .devcontainer/environment.yml /app/environment.yml

# 5. conda 환경 생성
RUN conda env create -f environment.yml

# 6. 기본 쉘 환경 설정 (이후 RUN 명령어는 전부 news-env 안에서 실행됨)
SHELL ["conda", "run", "-n", "news-env", "/bin/bash", "-c"]

# 7. 간단한 테스트용 echo (환경 활성화 확인용)
RUN echo "Conda env is ready!"
