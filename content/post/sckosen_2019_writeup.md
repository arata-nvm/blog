---
title: "SCKOSEN 2019 write-up"
date: 2019-11-16T20:16:11+09:00
categories: ["write-up"]
---

友人2人とチーム"helix"として参加した。

## 00 サンプル
自明

`CTFKIT{kosen_security_contest}`

## 01 回答は半角で
問題分にフラグがURLエンコードされて書かれているのでデコードする。すると全角のフラグが手に入るので、全角と半角を変換してフラグを得る。

`CTFKIT{KOREHA_URL_ENCODE_DESU}`

## 02 伝統的な暗号
キーが3文字ということからヴィジュネル暗号でなんとなくといたらいけた。
鍵は`shk`

`CTFKIT{do_u_know_vigenere_cipher?}`

## 03 20回もやれば、暗号と認めてやっても良いだろう
base64で20回暗号化されていた。

`CTFKIT{20_times_base64!}`

## 04 復号せよ
dnSpyでEncrypt.exeを解析した。
AESとbase64を使用した暗号だった。

`CTFKIT{Enjoy_KOSEN_SECCON_2019}`

## 05 
未回答

## 06 無言のELF

`CTFKIT{hpb5iphbr_et3phet5o} `

## 07 暖かく包み込む
渡されたexeファイルがUPXで圧縮されていた。
これを解凍し、文字列を抽出するとそれっぽいものが断片的にあったので、それらからフラグを得る。

`CTFKIT{sao_alice_}`

## 08 拡張されたIPv6
IPv6を整数形式だけでなく複素形式で表現することによって、利用できるアドレスを増やすものらしい。

`CTFKIT{RFC8135}`

## 09 プログラミング言語を当てよう
ちょうど話題になっていたBlawnのプログラムだった。

`CTFKIT{Blawn}`

## 10 ツートントン
２色のみのpngファイルが渡される。
横1列に見ていくと1色が続くのは2または5ドッドしかないことに気づくので、2ドットはトン、5ドットはツーだと推測。
pythonで頑張るとフラグが入手できた。

`CTFKIT{TUU=TON=TON=TUU=TON}`

## 11 新人エンジニアの発明
未回答

## 12 大人たちの無意味な習慣
名前から察した。
pcapファイルからWiresharkでファイルを抽出する。
zipファイルが送られたあとにそのパスワードが送られていたので、解凍してフラグを得る。

`CTFKIT{majide_muimina_shuukan_dayonee}`

## 13 名前を解決したい
digコマンドで調べるとDNSのTXTレコードに"ip=153.126.212.45"と書かれていた。
そこにアクセスするとフラグがあった。

`CTFKIT{naki_nureshi_megami_no_kikan}`

## 14 お茶をさぐれ
apkファイルが渡されるので、適当なツール(dex2jarなど)を使ってソースファイルを得る。
`CTFKIT`でgrepをかけると一つファイルがヒットしたので、そのファイルの処理を読んでフラグを得る。

"お茶"はJavaのロゴのこと...?

`CTFKIT{uresino_tea_**}`

## 15 最後に消したファイル
FAT形式のイメージファイルが渡される。
testdiskを使用して削除されたファイルを探すとbeelzebub.keyというファイルがあった。
中身はRSAの秘密鍵だったので、暗号化されているファイルを探す。
するとmullin.encryptedというファイルが見つかったので、opensslコマンドで復号してフラグを得る。

`CTFKIT{Pandemonium_Mont_Blanc}`

## 16 メモリダンプ
未回答

## 17 目に見えなくても
HTMLのソースの中にコメントでフラグが書かれていた。

`CTFKIT{html_may_be_including_hidden_text}`

## 18 you are not admin
未回答

## 19 JWT
未回答

## 20 偉くなりたい
フォームの中に一つ隠されていたテキストボックスがあり、値が`is_not_admin`になっていた。
ここを`is_admin`にし、問題文にかかれていたId、パスワードでログインし、フラグを得る。

`CTFKIT{}`


