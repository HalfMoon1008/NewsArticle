# 📊 데이터 명세서

이 디렉토리는 뉴스 기반 질의응답 모델 학습을 위한 원시 및 라벨링 데이터를 포함.\
data를 다 올리기 힘들어서 READMD.md로 대체\
데이터는 2021년에 구축되었으며, 국내 주요 언론사 20곳의 뉴스 기사와 이를 기반으로 생성된 QA 쌍으로 구성.\
\
데이터 출처: [AI Hub 뉴스기사 기반 질의응답 데이터](https://www.aihub.or.kr/aihubdata/data/view.do?pageIndex=1&currMenu=115&topMenu=100&srchOptnCnd=OPTNCND001&searchKeyword=%EA%B8%B0%EC%82%AC&srchDetailCnd=DETAILCND001&srchOrder=ORDER001&srchPagePer=20&aihubDataSe=data&dataSetSn=577)


---

## 1. 📅 데이터 구축 개요

| 항목             | 내용                   |
| -------------- | -------------------- |
| **데이터 구축 연도**  |  2021년            | 
| **원시 데이터**     | 뉴스 기사 약 **360,000건** |
| **라벨링 데이터 총량** | **400,056건**         |

---

## 2. 📂 데이터 파일 구성 요약

| 디렉토리                | 파일명 패턴      | 주요 목적                             |
| ------------------- | ----------- | --------------------------------- |
| `Training/raw/`     | `TS_*.json` | 원시 QA 데이터셋 (Training Source)      |
| `Training/labeled/` | `TL_*.json` | 라벨 포함 학습용 데이터셋 (Training Labeled) |

---

## 3. 📁 파일별 용도 비교

| 파일명                       | 유형        | 설명                           |
| ------------------------- | --------- | ---------------------------- |
| `TS_span_extraction.json` | 추출형 QA    | context 내에서 정답이 명시된 QA       |
| `TS_span_inference.json`  | 추론형 QA    | context 기반 정답은 있으나 명시적 위치 없음 |
| `TS_text_entailment.json` | 자연어 추론 QA | 문장의 논리적 타당성 판단 QA            |
| `TS_unanswerable.json`    | 무응답형 QA   | context로는 답변이 불가능한 질문        |

| 파일명                       | 유형         | 설명                          |
| ------------------------- | ---------- | --------------------------- |
| `TL_span_extraction.json` | 추출형 + 라벨   | TS 기반 QA에 정답 위치 등 추가 정보 포함  |
| `TL_span_inference.json`  | 추론형 + 라벨   | 정답 존재 여부 및 라벨 정보 포함         |
| `TL_text_entailment.json` | 추론 + 정답 태그 | 참/거짓/불확실 등의 태그 포함           |
| `TL_unanswerable.json`    | 무응답형 + 라벨  | is\_impossible 및 빈 정답 필드 명시 |

---

## 4. 🧾 주요 JSON 필드 설명

### 상위 메타 정보: `Dataset`

| 필드명          | 설명                                   |
| ------------ | ------------------------------------ |
| `Identifier` | 데이터셋 고유 식별자 (예: TEXT\_QnA\_News\_01) |
| `name`       | 데이터셋 이름                              |
| `src_path`   | 원시 데이터 위치 경로                         |
| `label_path` | 라벨 데이터 경로                            |
| `category`   | 데이터 분류 코드 (예: 뉴스 2번)                 |
| `type`       | 데이터 타입 구분 코드 (0: 기사 기반)              |

### 문서 메타 정보: `doc_*`

| 필드명               | 설명                               |
| ----------------- | -------------------------------- |
| `doc_id`          | 문서 고유 ID                         |
| `doc_title`       | 뉴스 제목                            |
| `doc_source`      | 언론사 이름                           |
| `doc_published`   | 기사 발행 일자                         |
| `doc_class.class` | 기사 출처 분류 (예: 한국언론진흥재단 빅카인즈 뉴스기사) |
| `doc_class.code`  | 주제 분류 코드 (예: 스포츠, 정치 등)          |

### 문단 및 QA 구조: `paragraphs` 내부

| 필드명                      | 설명                            |
| ------------------------ | ----------------------------- |
| `context`                | 지문 텍스트 (뉴스 기사 본문)             |
| `qas[].qa_type`          | 질문 유형 코드 (예: 1=추출형, 2=추론형 등)  |
| `qas[].question_id`      | 질문 고유 ID                      |
| `qas[].question`         | 사용자 질문 텍스트                    |
| `qas[].is_impossible`    | 정답 유무 (false: 있음, true: 무응답형) |
| `qas[].answers[]`        | 정답 정보 배열                      |
| `answers[].text`         | 정답 텍스트 (context 내 span)       |
| `answers[].answer_start` | context 내 정답 시작 위치 인덱스        |

---

## 5. 🔍 예시 JSON 구조 (`TL_span_extraction.json` 기준)

```json
{
  "Dataset": {
    "Identifier": "TEXT_QnA_News_01",
    "name": "뉴스기사 대상 기계독해 데이터",
    "src_path": "/dataSet/text/",
    "label_path": "/dataSet/text/",
    "category": 2,
    "type": 0
  },
  "data": [
    {
      "doc_id": "2202552",
      "doc_title": "오늘부터 사라진 네이버 ‘실검’…빈자리엔 날씨와 주가",
      "doc_source": "국민일보",
      "doc_published": "2021.04.16. 오전 10:46",
      "doc_class": {
        "class": "한국언론진흥재단 빅카인즈 뉴스기사",
        "code": "정치"
      },
      "paragraphs": [
        {
          "context": "국내 최대 포털 네이버에서 25일 ‘실시간 급상승 검색어(실검)’와 ‘뉴스토픽’ 서비스가 종료됐다. 이로써...",
          "qas": [
            {
              "qa_type": 1,
              "question_id": 4559297,
              "question": "네이버 뉴스토픽 자리는 무엇으로 대체됐어",
              "is_impossible": false,
              "answers": [
                {
                  "text": "주가와 유가, 환율 등",
                  "answer_start": 18
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 6. ✅ 학습 활용 전략 요약

| 활용 항목                    | 설명                            |
| ------------------------ | ----------------------------- |
| 질문 필드 (`question`)       | 유저 입력으로 활용됨 (의미 기반 검색 쿼리)     |
| 문맥 필드 (`context`)        | 뉴스 기사 본문, 임베딩 생성에 사용됨         |
| 정답 필드 (`answers[].text`) | 유사도 supervision 또는 평가 기준으로 사용 |
| 제목 (`doc_title`)         | 결과 요약, 리턴용으로 활용 가능            |

### 🎯 목표 AI 기능

- "야구"와 같은 키워드를 입력했을 때
  - LG 트윈스 경기 결과
  - 특정 야구 선수 인터뷰
  - 야구장 리모델링 관련 기사 등
- 의미적으로 관련된 다양한 문서를 검색해주는 AI 추천 시스템

### 🔧 모델 후보

- 의미 기반 임베딩 모델: `SBERT`, `DPR`, `ColBERT`
- 학습 전략: contrastive learning, multi-negative sampling 기반

---

