# deadman

macOS向けの **dead man's switch (デッドマン装置)** です。一定時間内に `deadman ping` によるチェックインが無い場合、任意のシェルスクリプトを自動実行します。

- 言語: **Bash のみ** (依存ゼロ・macOS 標準環境で動作)
- 常駐: **launchd** (ログアウトしても動作)
- トリガー: 任意のシェルスクリプト (メール送信、Webhook 通知、ファイル暗号化、ディスク消去等、何でも)

用途の例:

- 一定期間ログインがなければ家族や友人にメッセージを送る
- ノート PC 紛失時に遠隔でスクリプトを実行する
- 長期出張・旅行時のセーフティ
- 死活監視のバックアップ (他の監視系が全部止まった時の最後の砦)

## 仕組み

```
┌─────────────┐   StartInterval=60s   ┌───────────────────┐
│   launchd   │ ────────────────────▶ │ deadman check     │
└─────────────┘                       │                   │
                                      │  elapsed > timeout?
                                      │    ├─ no  → exit  │
                                      │    └─ yes → run   │
                                      │            trigger│
                                      └───────────────────┘
                                                ▲
                                                │ updates
                                                │ last_ping
                                       ┌────────┴────────┐
                                       │ deadman ping    │
                                       │ (ユーザーが実行) │
                                       └─────────────────┘
```

- **設定**: `~/.config/deadman/config` (`TIMEOUT` と `TRIGGER_SCRIPT`)
- **状態**: `~/.local/state/deadman/state` (最後のping時刻、発火フラグ)
- **ログ**: `~/.local/state/deadman/deadman.log` 他
- **launchd plist**: `~/Library/LaunchAgents/com.deadman.check.plist`

---

## セットアップ

### 1. リポジトリを取得

```sh
git clone https://github.com/nnnnnnnnnke/deadman.git
cd deadman
```

### 2. `deadman` を PATH に配置

`Makefile` を使うのが楽です。インストール先はデフォルト `/usr/local/bin` です (書き込みに `sudo` が必要な場合があります)。

```sh
# デフォルト (/usr/local/bin)
sudo make install

# Homebrew (Apple Silicon) を使っていて sudo を避けたい場合
make install PREFIX=/opt/homebrew

# ユーザーローカル (~/.local/bin を PATH に通していること)
make install PREFIX=$HOME/.local
```

インストールの確認:

```sh
which deadman
deadman version
```

> `make install` を使わずリポジトリ内のスクリプトを直接使うこともできますが、その場合リポジトリを移動・削除すると launchd が動作しなくなるので注意してください。

### 3. トリガースクリプトを作る

発火時に実行したいシェルスクリプトを用意します。実行可能である必要はありません (内部で `/bin/sh -c` 経由で実行されます) が、スクリプトとして書いておくとテストしやすいです。

`examples/` 以下にサンプルがあります:

- `examples/trigger-notify.sh.example` — 通知 + メール
- `examples/trigger-webhook.sh.example` — Slack / Discord Webhook

例として `~/bin/deadman-panic.sh` を作る場合:

```sh
mkdir -p ~/bin
cp examples/trigger-notify.sh.example ~/bin/deadman-panic.sh
chmod +x ~/bin/deadman-panic.sh
# エディタで中身を編集
$EDITOR ~/bin/deadman-panic.sh
```

発火時に渡される環境変数 (スクリプト内で参照可能):

| 変数名 | 内容 |
| --- | --- |
| `DEADMAN_LAST_PING` | 最後の ping の epoch 時刻 |
| `DEADMAN_TIMEOUT` | タイムアウト秒数 |
| `DEADMAN_ELAPSED` | 最後の ping から経過した秒数 |
| `DEADMAN_FIRED_AT` | 発火時の epoch 時刻 |
| `DEADMAN_TEST` | `deadman test` 経由なら `1` (本番発火時は未設定) |

### 4. 設定 (タイムアウト・トリガースクリプト)

```sh
deadman config set timeout 24h
deadman config set trigger_script ~/bin/deadman-panic.sh
```

タイムアウトの書式: `60s` / `30m` / `24h` / `7d` / 生の秒数。

設定内容の確認:

```sh
deadman config
```

### 5. launchd エージェントをインストール

```sh
deadman install
```

オプションでまとめて指定することもできます:

```sh
deadman install --timeout 24h --script ~/bin/deadman-panic.sh --interval 60
```

- `--interval` : launchd が `deadman check` を呼ぶ間隔(秒)。デフォルト 60 秒。
- `--timeout` : タイムアウト値。省略時は既存の config を使用。
- `--script` : トリガースクリプトのパス。省略時は既存の config を使用。

これで `~/Library/LaunchAgents/com.deadman.check.plist` が設置され、`launchctl load` されます。

### 6. タイマー開始

**重要**: インストール直後はまだタイマーが始まっていません。最初の `ping` で起動します。

```sh
deadman ping
```

以降、タイムアウト内に再度 `deadman ping` を実行しないと、トリガースクリプトが発火します。

### 7. 動作確認

```sh
deadman status
```

表示例:

```
last ping:       2026-04-19 01:30:15 +0900
timeout:         24h (1d)
elapsed:         2m30s
remaining:       23h57m30s
status:          ACTIVE
trigger script:  /Users/you/bin/deadman-panic.sh

config file:     /Users/you/.config/deadman/config
state file:      /Users/you/.local/state/deadman/state
launchd plist:   /Users/you/Library/LaunchAgents/com.deadman.check.plist (installed)
```

トリガーが正しく動くかを、実際に発火させずに試すには:

```sh
deadman test
```

---

## 日常の使い方

```sh
deadman ping       # チェックイン(毎回タイマーをリセット)
deadman status     # 状態確認
deadman logs       # 最近のログを表示
deadman logs 200   # 最新 200 行
```

チェックインを習慣化する方法:

- シェルの `PROMPT_COMMAND` や `precmd` にこっそり入れる
- cron / launchd で他のジョブと一緒に実行
- ログイン時に自動実行 (loginhook や LaunchAgent)
- 毎朝のカレンダー通知から `deadman ping` をワンクリック

例: `~/.zshrc` に追加する(ターミナルを開いたら ping):

```sh
command -v deadman >/dev/null && deadman ping >/dev/null 2>&1 || true
```

---

## アンインストール

```sh
deadman uninstall              # launchd agent を外す
sudo make uninstall            # /usr/local/bin/deadman を削除
# お好みで設定と状態も削除
rm -rf ~/.config/deadman ~/.local/state/deadman
```

---

## コマンドリファレンス

| コマンド | 説明 |
| --- | --- |
| `deadman ping` | チェックイン。タイマーをリセットし fired フラグもクリア |
| `deadman status` | 現在の状態を表示 |
| `deadman reset` | `ping` と同じだが明示的に「リセット」したい時に |
| `deadman test` | トリガースクリプトを試し実行(fired 状態を変更しない) |
| `deadman check` | launchd から呼ばれる内部コマンド(手動実行も可) |
| `deadman install [flags]` | launchd plist を設置して `launchctl load` |
| `deadman uninstall` | launchd plist を `unload` して削除 |
| `deadman config` | 設定を表示 |
| `deadman config set <key> <value>` | `timeout` または `trigger_script` を更新 |
| `deadman config edit` | `$EDITOR` で設定を開く |
| `deadman config path` | 設定ファイルのパスを表示 |
| `deadman logs [n]` | ログの末尾 n 行(デフォルト 50) |
| `deadman version` | バージョン表示 |
| `deadman help` | ヘルプ |

---

## トラブルシューティング

### launchd エージェントが動作しているか確認

```sh
launchctl list | grep deadman
```

一覧に `com.deadman.check` が出ていれば OK です。PID が `-` になっていても問題ありません(`StartInterval` 方式なので常時実行ではない)。

### 最近 `check` が実行されたか確認

```sh
tail -f ~/.local/state/deadman/deadman.log
# launchd 本体の出力を見たい場合
tail -f ~/.local/state/deadman/launchd.out.log
tail -f ~/.local/state/deadman/launchd.err.log
```

もしくは:

```sh
deadman logs 100
```

### 発火テストが完結しているかを確認

1. トリガースクリプトを単体で実行して正常に動作するか確かめる:
   ```sh
   sh ~/bin/deadman-panic.sh
   ```
2. `deadman test` で deadman 経由の実行を確かめる。
3. 最後に短いタイムアウトで実際の発火を試す:
   ```sh
   deadman config set timeout 60s
   deadman ping
   sleep 70
   deadman status   # FIRED になっているはず
   # 確認後、通常のタイムアウトに戻す
   deadman config set timeout 24h
   deadman reset
   ```

### plist を編集した後にリロード

```sh
launchctl unload ~/Library/LaunchAgents/com.deadman.check.plist
launchctl load   ~/Library/LaunchAgents/com.deadman.check.plist
```

`deadman install` を再実行しても同じ効果になります。

### macOS のスリープ中は?

`StartInterval` はスリープ中は発火しません。復帰直後に1回だけ `check` が実行されます。タイムアウトは壁時計ベース (`date +%s`) で評価されるので、スリープ中に経過した時間はそのままカウントされます。つまり、長時間スリープから復帰した直後に発火条件を満たしていれば、そのタイミングでトリガーが実行されます。

### フルディスクアクセス等の権限

トリガースクリプトから他アプリの操作 (例: Mail.app をスクリプト経由で起動) をしたい場合、macOS のプライバシー設定で該当の権限を許可する必要があります。最初は `deadman test` で手動テストし、ダイアログが出たら許可してください。

### タイムアウトが効いていないように見える

- `deadman status` の `status:` が `INACTIVE` になっていませんか? 初回 `deadman ping` をしていない可能性があります。
- `status:` が `FIRED` のままなら、既に1回発火済みで再発火しません。`deadman reset` か `deadman ping` で復帰します。

---

## セキュリティに関する注意

- `TRIGGER_SCRIPT` の内容は `/bin/sh -c` でそのまま実行されます。信頼できるパスのみ設定してください。
- deadman 自身の発火で秘密情報 (APIキー、認証トークン等) をログやメールに直接書き込まないよう注意してください。必要な秘密情報はトリガースクリプト側で `security` コマンドなどから取得する設計をおすすめします。
- `state` と `config` ファイルはユーザー権限で保存されます。共有アカウントで使わないでください。

---

## ライセンス

MIT License. 詳細は [LICENSE](LICENSE) を参照。
