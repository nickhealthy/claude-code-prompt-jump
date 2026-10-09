#!/usr/bin/env bash
# 데모용 대화를 실제 모델 응답으로 만든다: todo API 개발 7턴 (haiku, 도구 사용 없음)
# 사용자 설정(CLAUDE.md, statusline, hooks, 응답 언어)이 섞이지 않게 --setting-sources project로 실행한다
set -euo pipefail

DEMO_DIR="$1"
SESSION_ID="$2"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

COMMON=(
  --setting-sources project
  --model haiku
  --disallowedTools "Bash,Edit,Write,NotebookEdit,WebFetch,WebSearch,Read,Glob,Grep"
  --append-system-prompt "Answer inline in Markdown with code blocks. Do not use any tools."
)
PROMPTS=(
  "Design a minimal REST API for a todo app: list the endpoints and the JSON shape of a todo."
  "Implement those endpoints with Express and an in-memory store."
  "Add request validation to POST /todos using zod."
  "Write Jest + supertest tests for the validation errors."
  "Should updates use optimistic or pessimistic locking here? Explain the trade-offs briefly."
  "Add cursor-based pagination to GET /todos."
  "Write a short README section that documents the API."
)

for i in "${!PROMPTS[@]}"; do
  if [ "$i" -eq 0 ]; then FLAG=(--session-id "$SESSION_ID"); else FLAG=(--resume "$SESSION_ID"); fi
  LINES=$(claude -p "${COMMON[@]}" "${FLAG[@]}" "${PROMPTS[$i]}" | wc -l | tr -d ' ')
  echo "[$((i + 1))/${#PROMPTS[@]}] ${LINES} lines"
done
