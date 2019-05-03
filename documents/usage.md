# Charma の使い方

## Charma ドキュメントを作る

作るのは簡単。以下の通り：

```ruby
require "charma"

doc = Charma::Document.new
```

## ページを作る

```ruby
page = doc.add_page
```

## ページにグラフを追加する

```ruby
title = "Meaningless chart"

series = [
  {
    name: "pi", 
    y: [3, 1, 4, 1, 5, 9],
  },
  {
    name: "sqrt(2)", 
    y: [1, 4, 1, 4, 2, 1],
  },
]

# series[x][:y] の数と x_ticks の数を合わせる
x_ticks = %w( foo bar baz qux quux corge )

# グラフの下端につく、x軸を説明する文字列
x_title = "from foo to corge"

chart = Charma::BarChart.new(
  title:title,
  series:series,
  x_ticks:x_ticks,
  x_title:x_title
)
page.add_chart( chart )
```

## 出力する

```ruby
doc.render( "hoge.pdf" ) # PDF を出力
doc.render( "fuga.svg" ) # SVG を出力(対応予定)
```
