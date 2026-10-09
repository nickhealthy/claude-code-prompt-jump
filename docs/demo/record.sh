#!/usr/bin/env bash
# README 데모 GIF(docs/demo.gif)를 다시 만든다: 데모 대화 생성 → VHS 녹화 → gifsicle 최적화
# 필요: 로그인된 claude, vhs, gifsicle (macOS: brew install vhs gifsicle)
# 주의: haiku로 짧은 대화 7턴을 실제로 생성하므로 사용량이 조금 든다
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"

# Claude Code 안에서 실행해도 바깥 세션의 표시(transcript 저장 끔, 플러그인 폴더 등)를 물려받지 않게 한다
for name in $(env | grep -o '^CLAUDE[A-Z_]*' || true); do
  [ "$name" = "CLAUDE_CONFIG_DIR" ] || unset "$name"
done

WORK="$(mktemp -d)"
export DEMO_DIR="$WORK/todo-api"
export SESSION_ID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
export DEMO_SETTINGS="$WORK/settings.json"
export PLUGIN_DIR="$ROOT"
echo '{"tui":"fullscreen","theme":"dark"}' > "$DEMO_SETTINGS"

echo "== 데모 대화 생성 ($SESSION_ID)"
"$HERE/seed-session.sh" "$DEMO_DIR" "$SESSION_ID"

echo "== 녹화"
(cd "$HERE" && vhs demo.tape)

echo "== 최적화"
gifsicle -O3 --lossy=40 --colors 128 "$HERE/demo.raw.gif" -o "$ROOT/docs/demo.gif"
rm "$HERE/demo.raw.gif"
ls -lh "$ROOT/docs/demo.gif"
