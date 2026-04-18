deadman
=======

A curses-based multi-host liveness monitor using ICMP ping, tuned for use on macOS. This repository is a redistribution of [upa/deadman](https://github.com/upa/deadman), which itself originates from "pingman" developed by the Interop Tokyo ShowNet NOC team. Both share the same [MIT License](LICENSE).

![demo](img/deadman-demo.gif)

> Captured on macOS monitoring `192.168.1.1`〜`192.168.1.10`. Regenerate with `vhs img/demo.tape`.

Features
--------

- Monitor many hosts concurrently and show UP/DOWN, RTT, loss rate, and a recent-history bar (▁▂▃▄▅▆▇█) in a curses TUI
- Reload config on `SIGHUP` while preserving history
- Visual grouping via `---` separators in the config
- Synchronous or asynchronous probe mode (`-a` / `--async-mode`)
- Ping through an ssh jump host (`relay=`)
- SNMP ping (`via=snmp`, RFC 4560)
- TCP ping via `hping3` (`tcp=dstport:N`)
- Linux-only: network namespaces (`via=netns`), VRF (`via=vrf`)

Requirements (macOS)
--------------------

- Python 3 (the stock `/usr/bin/python3` works)
- `ping` (shipped with macOS)
- Optional, only when using the corresponding feature:
  - `ssh` (shipped with macOS)
  - `snmpping` from Net-SNMP
  - `hping3` (`brew install hping`)

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
deadman [-h] [-s SCALE] [-a] [-b] [-l LOGDIR] configfile
```

| Option | Description |
| --- | --- |
| `-s SCALE`, `--scale SCALE` | Milliseconds per step of the RTT bar graph (default: `10`) |
| `-a`, `--async-mode` | Probe all targets in parallel |
| `-b`, `--blink-arrow` | Blink the cursor arrow while in async mode |
| `-l LOGDIR`, `--logging LOGDIR` | Write logs under this directory |
| `-h`, `--help` | Show help |

In the TUI use arrow keys to move the cursor and `q` to quit.

Config file format
------------------

One target per line. A full example is in `deadman.conf`.

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

Advanced transports:

```
# ssh relay (macOS/Linux)
google-via-ssh  173.194.117.176 relay=X.X.X.X os=Linux user=USER key=~/.ssh/id_rsa

# SNMPv2 ping (RFC 4560)
gw-via-snmp     8.8.8.8 relay=X.X.X.X via=snmp community=public

# TCP ping via hping3
wide-tcp80      203.178.136.59 tcp=dstport:80

# Linux only
gw-via-netns    8.8.8.8 relay=netns1 via=netns
gw-via-vrf      8.8.8.8 relay=vrf1 via=vrf
```

After editing the config, send `SIGHUP` to reload without losing history:

```sh
kill -HUP $(pgrep -f 'deadman deadman.conf')
```

Credits
-------

- Upstream: [upa/deadman](https://github.com/upa/deadman) by upa@haeena.net
- Original "pingman": Interop Tokyo ShowNet NOC team
- License: MIT — see [LICENSE](LICENSE)

---

deadman (日本語版)
==================

ICMP ping で複数ホストの死活を curses 画面にリアルタイム表示するモニタです。macOS での利用を想定して [upa/deadman](https://github.com/upa/deadman) を再配布したリポジトリで、上流は Interop Tokyo ShowNet NOC team 発祥の "pingman" を起源としています。どちらも [MIT License](LICENSE)。

機能
----

- 複数ホストを同時 ping し、UP/DOWN・RTT・ロス率・履歴バー (▁▂▃▄▅▆▇█) を TUI で表示
- `SIGHUP` でコンフィグを再読込(履歴は保持)
- `---` でグルーピング用のセパレータを表示
- 同期 / 非同期モード (`-a` / `--async-mode`)
- ssh 踏み台経由 ping (`relay=`)
- SNMP ping (`via=snmp`、RFC4560)
- TCP ping (`tcp=dstport:N`、要 `hping3`)
- Linux 専用: netns (`via=netns`)、VRF (`via=vrf`)

必要な環境 (macOS)
------------------

- Python 3 (macOS 標準の `/usr/bin/python3` で動作)
- `ping` (macOS 標準)
- オプション機能を使う場合のみ:
  - `ssh` (標準)
  - `snmpping` (Net-SNMP)
  - `hping3` (`brew install hping`)

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
deadman [-h] [-s SCALE] [-a] [-b] [-l LOGDIR] configfile
```

| オプション | 説明 |
| --- | --- |
| `-s SCALE`, `--scale SCALE` | RTT バーグラフの1段階の大きさ (ms)。デフォルト `10` |
| `-a`, `--async-mode` | 非同期モード(全ターゲットに並列 ping) |
| `-b`, `--blink-arrow` | 非同期モード時にカーソル矢印を点滅 |
| `-l LOGDIR`, `--logging LOGDIR` | ログファイル出力ディレクトリ |
| `-h`, `--help` | ヘルプ |

TUI 内は上下カーソルキーでターゲット選択、`q` で終了。

コンフィグ
----------

1行1ターゲットの単純なテキスト形式。`deadman.conf` に雛形があります。

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

応用(リレー/代替送信):

```
# ssh 踏み台経由 (macOS/Linux)
google-via-ssh  173.194.117.176 relay=X.X.X.X os=Linux user=USER key=~/.ssh/id_rsa

# SNMPv2 ping (RFC4560)
gw-via-snmp     8.8.8.8 relay=X.X.X.X via=snmp community=public

# TCP ping (要 hping3)
wide-tcp80      203.178.136.59 tcp=dstport:80

# Linux 専用
gw-via-netns    8.8.8.8 relay=netns1 via=netns
gw-via-vrf      8.8.8.8 relay=vrf1 via=vrf
```

コンフィグ編集後は `SIGHUP` で既存ターゲットの履歴を保ったままリロードできます:

```sh
kill -HUP $(pgrep -f 'deadman deadman.conf')
```

帰属 (Credits)
--------------

- オリジナル: [upa/deadman](https://github.com/upa/deadman) by upa@haeena.net
- さらにその起源: Interop Tokyo ShowNet NOC team が開発した "pingman"
- ライセンス: MIT ([LICENSE](LICENSE))
