---
title: '海外留学用奨学金データベースを作ってみた'
tags: [Career]
status: published
type: post
published: True

emaillist: true
toc: true
toc_label: "outline"
toc_icon: "guitar"
comments: true
header:
  overlay_image: /assets/images/blog/2022-06-10-scholarship-database.png
  overlay_filter: rgba(0,0,0,0.8)
  teaser: /assets/images/blog/2022-06-10-scholarship-database.png
classes:
  - wide

permalink: /blog/:year/:month/:day/:title


excerpt: UJA（海外日本人研究者ネートワーク）で関わりのある、福留さん（インディアナ大学）が200件以上の海外留学用奨学金・フェローシップの情報をまとめたスプレッドシートを作られているのをみて、個人の条件に合わせて検索できたら便利なのではと思い、検索機能を作ってみたいと考えた。
--- 
# 留学用の奨学金やフェローシップを検索できるデータベースを作ってみた

## 動機

UJA（海外日本人研究者ネートワーク）で関わりのある、福留さん（インディアナ大学）が200件以上の海外留学用奨学金・フェローシップの情報をまとめたスプレッドシートを作られているのをみて、個人の条件に合わせて検索できたら便利なのではと思い、検索機能を作ってみたいと考えた。


## 制作過程

そもそもWebアプリ的なものを作ったことがなかったのでどこから始めたらよいかわからなかったが、少しググってみるとGoogleスプレッドシートを読んだり書いたりするにはGoogleが提供しているGoogle App Scriptを使う必要がありそうだとわかりひとまずやってみることにした。どうやら基本Javascriptで、GoogleスプレッドシートやGoogleフォームなど、Googleのアプリと連携するのにそれ用の関数が存在しているようだった。

## 完成！

あれこれ試行錯誤しながらなんとか完成した、UJAのウェブサイトに埋め込んで公開となった。Twitterを中心に多くの人が拡散してくれたおかげで、公開3週間で述べ1000回以上検索機能を使っていただいている。また福留さんが、随時掲載プログラムを追加してくださっているおかげで公開当初からすでに20件以上増えている。今後もどんどん内容・機能ともにアップデートをし続ける予定だ。
