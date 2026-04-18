deadman
=======

[upa/deadman](https://github.com/upa/deadman) をベースとした、curses ベースのホスト死活監視ツールです。ICMP echo を用いて複数ホストの到達性と RTT をリアルタイムに表示します。Interop Tokyo ShowNet 発祥のツール "pingman" を起源としており、一時的な会場ネットワーク (カンファレンス、イベント) の死活監視用途に向いています。

このリポジトリは macOS 上での動作を主目的とした配布物で、中身は upa/deadman ([MIT License](LICENSE)) と同一です。

![demo](https://github.com/upa/deadman/raw/master/img/deadman-demo.gif)

機能
----

- 複数ホストを同時に ping し、UP/DOWN・RTT・ロス率・履歴バー(▁▂▃▄▅▆▇█) を curses 画面に表示
- `SIGHUP` でコンフィグリロード(履歴は保持される)
- `---` でグルーピング用セパレータを表示
- 同期 / 非同期送信 (`-a` / `--async-mode`)
- ssh 踏み台経由の ping (`relay=`)
- SNMP ping (`via=snmp`)
- TCP ping (`tcp=dstport:N`、要 `hping3`)
- Linux 専用: netns (`via=netns`)、vrf (`via=vrf`)

必要な環境 (macOS)
------------------

- Python 3 (macOS 標準の `/usr/bin/python3` で動作)
- `ping` (macOS 標準)
- 追加機能を使う場合のみ: `ssh` (標準)、`snmpping` (Net-SNMP)、`hping3` (`brew install hping`)

セットアップ
------------

```sh
# 1. 取得
git clone https://github.com/nnnnnnnnnke/deadman.git
cd deadman

# 2. そのまま実行可能
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
| `-b`, `--blink-arrow` | 非同期モード時にカーソル矢印を点滅させる |
| `-l LOGDIR`, `--logging LOGDIR` | ログファイル出力ディレクトリ |
| `-h`, `--help` | ヘルプ |

画面内のキーバインドは上下カーソルキーでターゲット選択、`q` で終了です。

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

### リレー・代替送信方法の例

```
# ssh 踏み台経由 (macOS/Linux)
google-via-ssh  173.194.117.176 relay=X.X.X.X os=Linux user=USER key=~/.ssh/id_rsa

# SNMPv2 ping (RFC4560)
gw-via-snmp     8.8.8.8 relay=X.X.X.X via=snmp community=public

# TCP ping (要 hping3)
wide-tcp80      203.178.136.59 tcp=dstport:80

# Linux 専用: network namespace
gw-via-netns    8.8.8.8 relay=netns1 via=netns

# Linux 専用: VRF
gw-via-vrf      8.8.8.8 relay=vrf1 via=vrf
```

コンフィグを書き換えた後は `kill -HUP <pid>` で反映でき、既存ターゲットの履歴は失われません。

帰属 (Credits)
--------------

- オリジナル: [upa/deadman](https://github.com/upa/deadman) by upa@haeena.net
- さらにその起源は Interop Tokyo ShowNet NOC team が開発した "pingman"
- ライセンス: MIT ([LICENSE](LICENSE) を参照)

問い合わせ先
------------

本ツールの上流である upa 氏への問い合わせは `upa@haeena.net` まで。
