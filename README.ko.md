# prompt-jump

**Claude Code 세션에서 내가 입력했던 프롬프트로 바로 이동하세요. 더 이상 스크롤하지 않아도 됩니다.**

[English](README.md)

긴 Claude Code 세션에서는 내 프롬프트가 도구 출력 수십 페이지 아래에 묻힙니다. `Ctrl+R`은 예전 프롬프트의 *텍스트*는 불러오지만, 대화 속 그 *위치*로 데려가지는 않습니다. `prompt-jump`는 `/jump` 패널을 추가합니다. 현재 대화의 프롬프트가 최신순으로 나오고, 하나를 고르면 대화가 그 위치로 바로 스크롤됩니다.

![/jump가 resume한 세션의 프롬프트를 나열하고, 단어와 번호로 거른 뒤, 고른 프롬프트로 대화를 스크롤하는 모습](docs/demo.gif)

<sub>데모는 세션을 resume한 뒤, 스크롤해 본 적 없는 #1 프롬프트로 바로 이동합니다.</sub>

## 기능

- **최신순 목록.** 현재 대화의 모든 프롬프트를 보여 주고, 번호는 대화 순서입니다(`#1`이 가장 오래된 프롬프트).
- **입력하면서 검색.** 공백으로 나눈 단어가 모두 들어간 프롬프트만 남습니다(대소문자 무시).
- **번호로 이동.** `12`나 `#12`를 입력하고 `Enter`를 누르세요.
- **연달아 이동.** 이동한 뒤에도 패널이 열려 있어 여러 프롬프트를 오갈 수 있고, `Esc`로 닫습니다.
- **`--resume` 후에도 동작.** 재시작 전 프롬프트가 바로 목록에 나옵니다. 아직 스크롤해 보지 않은 프롬프트도 마찬가지입니다.
- **실제로 남아 있는 것만.** 되감기(rewind)로 버린 프롬프트, 슬래시 명령(`/rewind`, `/plugin` 등), 작업 알림, 다른 세션이 보낸 메시지는 빠집니다.
- **흔적을 남기지 않음.** `/jump`를 열어도 대화 기록이나 모델 컨텍스트에 아무것도 추가되지 않고, Claude가 응답하는 중에도 열 수 있습니다.
- **한글 폭 처리.** 긴 한글·중국어·일본어 프롬프트도 레이아웃이 깨지지 않게 패널 폭에 맞춰 자릅니다.
- **`Ctrl+R`은 그대로.** 대체가 아니라 추가 명령입니다.

## 요구 사항

| | |
| --- | --- |
| Claude Code | v2.1.287 이상, 터미널 (mod는 early access 기능) |
| 렌더러 | fullscreen 렌더러(`/tui fullscreen`). 이동은 Claude Code 자체 대화 화면을 스크롤합니다 |
| OS | macOS 또는 Linux. resume 지원에 시스템의 `grep`, `find`를 씁니다 |

## 설치

Claude Code 터미널 세션에서:

```
/plugin install prompt-jump --marketplace nickhealthy/claude-code-prompt-jump
```

마켓플레이스 추가 질문에 `y`, 그다음 범위를 고르세요(user 범위면 모든 세션에서 로드). 설치 즉시 동작합니다.

또는 마켓플레이스를 먼저 추가한 뒤 설치해도 됩니다:

```
/plugin marketplace add nickhealthy/claude-code-prompt-jump
/plugin install prompt-jump@prompt-jump
```

<details>
<summary>수동 설치 (로컬 폴더에서 실행)</summary>

```bash
git clone https://github.com/nickhealthy/claude-code-prompt-jump.git ~/.claude/mods/prompt-jump
```

`~/.claude/settings.json`에 등록하면 모든 세션에서 로드됩니다:

```json
{
  "env": {
    "CLAUDE_CODE_PLUGIN_DIRS": "/절대/경로/.claude/mods/prompt-jump"
  }
}
```

한 세션만 쓰려면: `claude --plugin-dir ~/.claude/mods/prompt-jump`

</details>

## 사용법

| 명령 | 동작 |
| --- | --- |
| `/jump` | 전체 프롬프트로 패널 열기 |
| `/jump bypass 모드` | 두 단어가 모두 들어간 프롬프트만 보이게 열기 |
| `/jump 12` | `#12` 프롬프트만 보이게 열기 |

패널 안에서:

| 키 | 동작 |
| --- | --- |
| 입력 | 단어로 검색, 숫자(`12`, `#12`)면 번호로 필터 |
| 검색창에서 `Enter` | 가장 최근에 일치한 프롬프트로 이동 |
| `Tab` / `↑` `↓` | 프롬프트 사이 이동 |
| `Enter` / 클릭 | 선택한 프롬프트로 이동 |
| `Esc` | 패널 닫기 |

## 동작 원리

`prompt-jump`는 [Claude Code mod](https://code.claude.com/docs/en/plugins/mods/overview)입니다. Claude Code 안에서 실행되는 함수 hook 플러그인입니다.

1. **어떤 프롬프트가 있는가.** 현재 대화는 `$.session.messages()`에서 가져옵니다. 되감기로 버려진 분기는 여기 포함되지 않으므로 되감은 프롬프트는 빠지고, 순서도 실제 대화 순서가 됩니다.
2. **각 프롬프트가 어디 있는가.** 이동하려면 프롬프트 행의 id가 필요합니다. id는 두 곳에서 얻습니다.
   - 화면에 그려진 행 (`UserMessage` 행의 `ui.render` hook)
   - 세션 기록 파일. `grep`으로 프롬프트 행만 읽습니다. fullscreen 렌더러는 스크롤해서 본 행만 그리기 때문에, resume 직후에는 이 경로가 필요합니다.
3. **이동.** `$.ui.scroll({ to: { requestId } })`로 그 행을 화면 맨 위로 가져옵니다.

목록은 `/jump`를 열 때 한 번만 계산하므로, 검색어를 입력할 때마다 대화 전체를 다시 읽지 않습니다.

## 개인정보와 보안

prompt-jump는 전부 내 컴퓨터 안에서 동작합니다. **네트워크로 아무것도 보내지 않고, Claude Code 자체 세션 상태 밖에는 아무것도 쓰지 않습니다.**

**읽는 것**

목록에 필요한 것만, 현재 세션에서만, `/jump`를 열 때만 읽습니다.

- 내가 직접 입력한 프롬프트(id와 텍스트)만 남기고, Claude의 답변·도구 출력·알림은 건너뜁니다.
- 다른 세션, Claude의 메모리, 대화 요약은 읽지 않으며, 세션이 끝나면 아무것도 남기지 않습니다.

자세히:

- 현재 대화(`$.session.messages()`): 어떤 프롬프트가 있고 순서가 어떤지 정하기 위해
- 화면에 그려진 프롬프트 행의 텍스트와 id
- 내 세션의 기록 파일 `<설정 폴더>/projects/<프로젝트>/<세션 id>.jsonl`: `--resume` 직후 아직 그려지지 않은 프롬프트를 찾기 위해. 설정 폴더는 `$CLAUDE_CONFIG_DIR`, 없으면 `~/.claude`입니다
- 환경 변수 `HOME`, `CLAUDE_CONFIG_DIR`: 위 기록 파일 위치를 찾는 데만 씁니다

**실행하는 것**

`/jump`를 열 때만, 읽기 전용 로컬 프로그램을 최대 두 개 실행합니다. 셸을 거치지 않고 인자 목록으로 직접 실행합니다.

| 프로그램 | 실행하는 명령 그대로 | 이유 |
| --- | --- | --- |
| `grep` | `grep -F '"promptSource":' <기록 파일>` | 프롬프트 행만 읽어 옵니다. 기록 파일은 mod가 `$.fs.read`로 읽을 수 있는 4 MiB보다 클 수 있습니다 |
| `find` | `find <설정 폴더>/projects -maxdepth 2 -name <세션 id>.jsonl` | 기록 파일이 예상 경로에 없을 때만 실행합니다. 프로젝트 폴더 이름이 200자를 넘어 Claude Code가 줄여 쓴 경우입니다 |

**보내는 것**

없습니다. 위 프로그램의 출력은 mod 안에서 해석해 패널에 보여 줄 뿐, 파일로 쓰지도, 서버로 보내지도, 대화 기록이나 모델 컨텍스트에 넣지도 않습니다.

## 알려진 한계

- `/compact` 이후에는 압축 전 프롬프트가 목록에서 빠집니다. 스크롤로는 여전히 볼 수 있습니다.
- 엔진이 최근 메시지 4096개까지만 돌려주므로, 아주 긴 세션에서는 오래된 프롬프트부터 빠집니다.
- resume 지원은 세션 기록 파일의 내부 필드(`promptSource`)를 읽습니다. Claude Code 업데이트로 이 필드가 바뀌면 화면에 그려진 프롬프트만으로 동작하고, 에러는 나지 않습니다.
- 붙여넣기로 입력한 프롬프트는 저장 형식이 화면 표시와 달라 목록에서 빠질 수 있습니다.
- 패널을 연 뒤 보낸 프롬프트는 다음에 열 때 나타납니다.
- Remote Control의 웹·모바일 클라이언트는 아직 지원하지 않습니다.

## 개발

```
prompt-jump/
├── .claude-plugin/plugin.json   # 매니페스트
├── hooks/hooks.json             # hooks 모듈 지정
├── hooks/register.tsx           # mod 본체
├── types/index.d.ts             # $.state 계약
├── tests/prompt-jump.test.tsx   # claude plugin test
└── docs/DEVELOPMENT.md          # 개발 과정 기록
```

```bash
claude plugin validate .   # 매니페스트, hooks 모듈, state 계약 검증
claude plugin test .       # 테스트 15개: 정렬, 되감기, resume, 필터, 한글 폭
```

개발 중에는 `claude --plugin-dir .`로 폴더에서 바로 실행하세요. 파일을 저장하면 mod가 다시 로드됩니다.

버그가 어떻게 발견되고 왜 그렇게 고쳤는지까지 담은 개발 과정은 [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)에 있습니다.

## 라이선스

[MIT](LICENSE)
