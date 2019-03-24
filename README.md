# Charma

Create pages filled with charts in PDF format

## もうちょっと詳しく

適当にデータを突っ込んだらいい感じのグラフを作ってくれることを目指している。
出力は PDF のみ。

入力は `Hash`。CSV を読んだりする機能はない。

### 対応しているグラフ

* 棒グラフ
* 折れ線グラフ
* Violin Plot

### 対応しない予定のグラフ

* 円グラフ
* レーダーチャート
* 3Dグラフ
* 箱ひげ図

## 利用例

```ruby
require 'charma'

Charma::Document.new do |doc|
  doc.new_page do |page|
    page.add_barchart(
      series:[{y:[3,1,4,1,5]}],
      x_ticks:%w[ foo bar baz qux quux]
    )
  end
  doc.render( File.basename(__FILE__, ".*")+".pdf" )
end
```

その他の利用例や出来上がる PDF については examples フォルダを参照のこと。
