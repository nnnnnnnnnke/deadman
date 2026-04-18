deadman-macos
=============

A curses-like TUI multi-host liveness monitor for macOS, implemented in pure **Bash**. It reads a `name  address` config file, pings every target each second, and draws a live dashboard showing UP/DOWN, RTT, loss rate, and a recent-history bar.

The behaviour, config format, and screen layout mirror [upa/deadman](https://github.com/upa/deadman), which itself originates from "pingman" developed by the Interop Tokyo ShowNet NOC team. This repository is an independent Bash reimplementation rather than a redistribution. Same [MIT License](LICENSE).

![demo](img/deadman-demo.gif)

> Captured on macOS monitoring public anycast resolvers and root servers (`8.8.8.8`, `9.9.9.9`, `202.12.27.33` / M-root, `210.155.141.200` / KAME) plus their IPv6 counterparts. Regenerate with `vhs img/demo.tape`.

Features
--------

- Pure Bash — runs on the stock `/bin/bash` (3.2) shipped with macOS, no Python or compiled dependencies
- Parallel probes each cycle (always async)
- Reloads config on `SIGHUP` while preserving per-target history
- Visual grouping via `---` separators in the config
- IPv4 and IPv6 (via `ping6` or `ping -6`)
- Color-coded UP/DOWN rows, Unicode RTT bar (▁▂▃▄▅▆▇█, `X` on timeout)
- Optional per-target log output (`-l DIR`)
- `q` to quit, `r` to reset counters at runtime

Not supported in this Bash build (all are available upstream in upa/deadman): ssh-relay, SNMP ping, TCP ping via hping3, Linux netns / VRF, RouterOS API, source-interface binding, async-vs-sync switch, blink-arrow.

Requirements (macOS)
--------------------

- Bash (the default `/bin/bash` 3.2 is enough; Bash 5 from Homebrew also works)
- `ping` (shipped with macOS)
- `ping6` (shipped with macOS) — only needed for IPv6 targets
- `awk`, `tput`, `mktemp`, `hostname` — all shipped with macOS

Setup
-----

```sh
# 1. Clone
git clone https://github.com/nnnnnnnnnke/deadman-macos.git
cd deadman-macos

# 2. Run directly
./deadman deadman.conf

# 3. (optional) Install onto PATH
sudo install -m 755 deadman /usr/local/bin/deadman
deadman deadman.conf
```

Usage
-----

```sh
deadman [-s SCALE] [-a] [-b] [-l LOGDIR] [-h] configfile
```

| Option | Description |
| --- | --- |
| `-s SCALE`, `--scale SCALE` | Milliseconds per step of the RTT bar graph (default: `10`) |
| `-a`, `--async-mode` | Accepted for CLI compatibility with upa/deadman; probing is always async here |
| `-b`, `--blink-arrow` | Accepted for CLI compatibility; no-op in this build |
| `-l LOGDIR`, `--logging LOGDIR` | Append a line per probe to `LOGDIR/<name>.log` |
| `-h`, `--help` | Show help |

In the TUI, press `q` to quit or `r` to reset all counters.

Config file format
------------------

One target per line. A sample is provided in `deadman.conf`.

```
# Comments start with '#'
googleDNS       8.8.8.8
quad9           9.9.9.9
mroot           202.12.27.33
kame            210.155.141.200
---                               # horizontal separator in the TUI
mroot6          2001:dc3::35
kame6           2001:2f0:0:8800::1:1
```

Extra fields per line (`relay=`, `via=snmp`, `tcp=...`, etc.) are parsed in upstream upa/deadman; they are silently ignored by this Bash build, which uses only the first two whitespace-separated fields.

Send `SIGHUP` to reload without losing history:

```sh
kill -HUP $(pgrep -f 'deadman deadman.conf')
```

Credits
-------

- Upstream design and config format: [upa/deadman](https://github.com/upa/deadman) by upa@haeena.net
- Original "pingman": Interop Tokyo ShowNet NOC team
- License: MIT — see [LICENSE](LICENSE)

---

deadman-macos (日本語版)
========================

macOS 向けの、**Bash 単体で実装された** curses 風 TUI 死活監視ツールです。`name  address` 形式のコンフィグを読み、各ターゲットを1秒おきに ping し、UP/DOWN・RTT・ロス率・履歴バーをリアルタイムに表示します。

挙動・設定フォーマット・画面レイアウトは [upa/deadman](https://github.com/upa/deadman) (起源は Interop Tokyo ShowNet NOC team の "pingman") に倣っていますが、本リポジトリは Python ソースの再配布ではなく Bash による独立実装です。ライセンスは同じ [MIT License](LICENSE)。

機能
----

- 完全に Bash 製 — macOS 標準の `/bin/bash` (3.2) で動作、Python もコンパイルも不要
- 毎サイクル全ターゲットに並列 ping
- `SIGHUP` でコンフィグ再読込(履歴保持)
- `---` でグルーピング用のセパレータを表示
- IPv4 / IPv6 対応 (`ping6` または `ping -6`)
- UP/DOWN の色分け、Unicode RTT バー (▁▂▃▄▅▆▇█、タイムアウト時 `X`)
- 任意で per-target ログ出力 (`-l DIR`)
- `q` で終了、`r` でカウンタリセット

**この Bash 版で未サポート**(上流 upa/deadman にはある機能): ssh リレー、SNMP ping、hping3 による TCP ping、Linux netns / VRF、RouterOS API、ソースインターフェイス指定、同期/非同期切替、矢印点滅。

必要な環境 (macOS)
------------------

- Bash(macOS 標準の `/bin/bash` 3.2 で十分。Homebrew の bash 5 でも可)
- `ping` (macOS 標準)
- `ping6` (macOS 標準) — IPv6 を使う場合のみ
- `awk`, `tput`, `mktemp`, `hostname` — いずれも macOS 標準

セットアップ
------------

```sh
# 1. 取得
git clone https://github.com/nnnnnnnnnke/deadman-macos.git
cd deadman-macos

# 2. そのまま実行
./deadman deadman.conf

# 3. (任意) PATH に配置
sudo install -m 755 deadman /usr/local/bin/deadman
deadman deadman.conf
```

使い方
------

```sh
deadman [-s SCALE] [-a] [-b] [-l LOGDIR] [-h] configfile
```

| オプション | 説明 |
| --- | --- |
| `-s SCALE`, `--scale SCALE` | RTT バーグラフの1段階の ms 数 (デフォルト `10`) |
| `-a`, `--async-mode` | 上流との CLI 互換用(本実装は常に並列) |
| `-b`, `--blink-arrow` | 互換用 no-op |
| `-l LOGDIR`, `--logging LOGDIR` | `LOGDIR/<name>.log` に各 probe を1行追記 |
| `-h`, `--help` | ヘルプ |

TUI 内は `q` で終了、`r` でカウンタリセット。

コンフィグ
----------

1行1ターゲットの単純なテキスト形式です。`deadman.conf` に雛形があります。

```
# コメントは '#' から
googleDNS       8.8.8.8
quad9           9.9.9.9
mroot           202.12.27.33
kame            210.155.141.200
---                               # 画面上のセパレータ
mroot6          2001:dc3::35
kame6           2001:2f0:0:8800::1:1
```

上流で有効な追加フィールド(`relay=`, `via=snmp`, `tcp=...` など)は、この Bash 実装では黙って無視されます。最初の2語(名前・アドレス)のみ使用します。

コンフィグ編集後は `SIGHUP` で履歴を保ったままリロード:

```sh
kill -HUP $(pgrep -f 'deadman deadman.conf')
```

帰属 (Credits)
--------------

- 設計・コンフィグ形式の上流: [upa/deadman](https://github.com/upa/deadman) by upa@haeena.net
- さらにその起源: Interop Tokyo ShowNet NOC team が開発した "pingman"
- ライセンス: MIT ([LICENSE](LICENSE))
