## 로컬 터미널에서 실행할 스크립트
# 처음 1번만 실행
# chmod +x .devcontainer/upload_changed.sh
# alias docker-sync='./.devcontainer/upload_changed.sh'

# 실질적 파일 업로드 (로컬 터미널에서)
# git add를 감지해서 가져오는 방식!
# git add ~ push 등등 add 이상의 작업 진행
# docker-sync




#!/bin/bash

# 도커 컨테이너 이름
CONTAINER=news-search-container

# 도커 컨테이너 내에서 프로젝트 루트 경로
TARGET_ROOT=/app/NewsArticle

# 변경 파일 상태 리스트 얻기 (A=추가, M=수정, D=삭제, R=이름 변경)
CHANGED=$(git diff --name-status --cached)

echo "🔍 변경 사항 감지 중..."
echo "$CHANGED"

# 한 줄씩 처리: STATUS FILE1 [FILE2]
echo "$CHANGED" | while read -r STATUS FILE1 FILE2; do

  case "$STATUS" in

    A|M)
      if [ -f "$FILE1" ]; then
        echo "⏫ 업로드 파일: $FILE1"
        docker exec "$CONTAINER" mkdir -p "$TARGET_ROOT/$(dirname "$FILE1")"
        docker cp "$FILE1" "$CONTAINER:$TARGET_ROOT/$FILE1"

      elif [ -d "$FILE1" ]; then
        echo "📁 디렉토리 업로드: $FILE1"

        # 컨테이너 내 대상 경로가 없을 수도 있으니 미리 만들어줘
        docker exec "$CONTAINER" mkdir -p "$TARGET_ROOT/$FILE1"

        # 디렉토리 안의 **내용물 전체**를 복사 (꼭 `/./` 아님 `/.` 붙여야 함)
        docker cp "$FILE1/." "$CONTAINER:$TARGET_ROOT/$FILE1"
      fi
      ;;


    D)
      # 삭제된 파일
      echo "🗑️ 삭제: $FILE1"
      docker exec "$CONTAINER" rm -f "$TARGET_ROOT/$FILE1"
      ;;

    R*)
      # 이름이 바뀐 파일 (rename)
      echo "🔄 이름 변경: $FILE1 → $FILE2"

      # 기존 파일 삭제
      docker exec "$CONTAINER" rm -f "$TARGET_ROOT/$FILE1"

      # 새 파일이 있다면 업로드
      if [ -f "$FILE2" ]; then
        docker exec "$CONTAINER" mkdir -p "$TARGET_ROOT/$(dirname "$FILE2")"
        docker cp "$FILE2" "$CONTAINER:$TARGET_ROOT/$FILE2"
      elif [ -d "$FILE2" ]; then
        docker cp "$FILE2" "$CONTAINER:$TARGET_ROOT/$(dirname "$FILE2")"
      fi
      ;;

    *)
      echo "⚠️ 처리되지 않은 상태: $STATUS"
      ;;
  esac

done

echo "✅ 컨테이너에 변경사항 반영 완료! (/app/NewsArticle/)"
