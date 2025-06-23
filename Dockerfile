# Dockerfile

# 1. 베이스 이미지: Miniconda가 설치된 환경
FROM continuumio/miniconda3

# 2. 작업 디렉토리 설정 (컨테이너 안의 기준 경로야)
WORKDIR /app

# 3. 현재 프로젝트 폴더의 모든 파일을 컨테이너로 복사
COPY . /app

# 4. Conda 환경 설정 (environment.yml이 있어야 함)
COPY environment.yml /app/environment.yml
RUN conda env create -f environment.yml

# 5. 기본 shell 설정: 항상 conda 환경 nlp를 활성화하고 명령 수행
SHELL ["conda", "run", "-n", "nlp", "/bin/bash", "-c"]

# 6. 컨테이너가 실행될 때 시작할 기본 명령어 (예시)
CMD ["python", "src/ui_app.py"]
