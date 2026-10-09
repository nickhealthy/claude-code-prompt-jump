# README 데모 GIF 녹화 스크립트 (https://github.com/charmbracelet/vhs)
# record.sh가 DEMO_DIR, SESSION_ID, DEMO_SETTINGS, PLUGIN_DIR를 채워서 실행한다

Output demo.raw.gif

Set Shell "bash"
Set FontSize 15
Set Width 1400
Set Height 760
Set Padding 16
Set Margin 16
Set MarginFill "#2b2b2b"
Set WindowBar Colorful
Set BorderRadius 8
Set Framerate 15
Set TypingSpeed 80ms

# 준비 과정은 숨긴다: 데모 세션을 --resume으로 열기 (스크롤하지 않은 프롬프트로 이동하는 것까지 보여주기 위함)
Hide
Type 'cd "$DEMO_DIR" && clear && claude --resume "$SESSION_ID" --setting-sources project --settings "$DEMO_SETTINGS" --plugin-dir "$PLUGIN_DIR" --permission-mode default'
Enter
Sleep 6s
# 처음 여는 폴더의 신뢰 확인 창: 기본 선택이 "No, exit"라 ↓로 "Yes"를 고른다
Down
Enter
Sleep 8s
Show

Sleep 1500ms
Type "/jump"
Sleep 600ms
Enter
Sleep 2500ms

# 단어 검색 → Enter로 가장 최근에 일치한 프롬프트로 이동
Type "valid"
Sleep 1500ms
Enter
Sleep 3s

# 번호 검색 → 대화 맨 앞(#1, resume 후 한 번도 스크롤하지 않은 위치)으로 이동
Backspace 5
Type "1"
Sleep 1200ms
Enter
Sleep 3s

Escape
Sleep 2s
