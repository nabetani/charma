# Charma リファレンス

## `Charma::Document`

### `.new(font:, page_size, page_layout, &block)`

#### `font`
フォント名。未対応。
#### `page_size`
デフォルトのページサイズ。

以下の3つの形式に対応する：
* 紙の大きさを示す文字列。
  * `"A0"`〜`"A10"`
  * `"B0"`〜`"B10"` ( 未対応 )
  * `"LETTER"`, `"LEGAL"` ( 未対応 )
* 紙の横幅と縦幅を `'x'` でつないだ文字列。単位は mm。以下に例を示す。
  * `"380x270"`
  * `"545x394"`
* 紙の横幅と縦幅並べた配列。以下に例を示す。
  * `[380, 270]`
  * `[545, 394]`

#### `page_ layout`
デフォルトのページレイアウト。

以下の値のいずれか：

* `nil`
* `:landscape`
* `:portrait`

#### `block`

作られた Document を引数として block が呼ばれる。

以下のように使うことを想定している：

```ruby
Charma::Document.new(略) do |doc|
  # 略
  doc.render(略)
end
```

### `#add_page( font:, page_size:, layout:, &block )`

ドキュメントにページを追加する。

#### `font`
フォント名(未対応)

#### `page_size`
ページサイズ。形式は `Document.new` の `page_size` と同様

指定しなかったら `Document.new` で指定された値を使う

#### `layout`
ページレイアウト。形式は `Document.new` の `layout` と同様。

指定しなかったら `Document.new` で指定された値を使う

#### `block`

追加されたページを引数としてブロックが呼ばれる。

以下のように使うことを想定している：

```ruby
Charma::Document.new(略) do |doc|
  doc.add_page do |page|
    #略
  end
  doc.render(略)
end
```


### `#render( filename, file_type: )`

レンダリングし、結果を `filename` で指定されたファイルに出力する

#### filename

ファイル名。拡張子が `.pdf` か `.svg` ならその形式で出力する( `.svg` は未対応 )

#### file_type

形式を指定する。省略した場合は `filename` の拡張子から判断する。

指定可能な値は `:pdf` と `:svg` のみ ( `:svg` は未対応 )

## `Charma::Page`

`Document#add_page` の返戻値またはブロック引数の値として得られる。


### `#add_chart(chart)`

チャートをページに追加する。

何個でも追加できる。

複数個ある場合は、ページを分割して適当に配置される。

## `Charma::BarChart`

縦の棒グラフ

### `.new(opts)`

`opts` は `Hash`。

対応するキー/値 は以下の通り：

* `:title`: グラフのタイトル。文字列。
* `:series`: 系列。Hash の Array。必須。
* `:x_ticks`: x軸につけるラベル。文字列の配列。
* `:x_title`: x軸のタイトル(グラフ下端)。文字列。
* `:y_title`: y軸のタイトル(グラフ左端)。文字列。
* `:y2_title`: 第二y軸のタイトル(グラフ右端)。文字列。
* `:legend`: 凡例の位置。`:none` と `:bottom` のいずれか。省略時は `:bottom`。未対応。

`:series` の要素である `Hash` は以下のキー/値 を受け入れる：

* `:y`: 数値の配列。
* `:y2`: 数値の配列。第二y軸を使う。
* `:name`: 系列の名前。凡例に使う。

※ `:series` の要素である `Hash` は、`:y` または `:y2` のいずれか一方が必須。
※ `:y` と `:y2` の両者を持つのはNG。
※ `:y` を持つ系列がない(全てが `:y2` を持つ)のはNG。

## `Charma::ScatterChart`

散布図

### `.new(opts)`

`opts` は `Hash`。

対応するキー/値 は以下の通り：

* `:title`: グラフのタイトル。文字列。
* `:series`: 系列。Hash の Array。必須。
* `:x_title`: x軸のタイトル(グラフ下端)。文字列。
* `:y_title`: y軸のタイトル(グラフ左端)。文字列。
* `:y2_title`: 第二y軸のタイトル(グラフ右端)。文字列。
* `:legend`: 凡例の位置。`:none` と `:bottom` のいずれか。省略時は `:bottom`。未対応。
* `:x_scale`: x軸のスケール。`:linear` または `:log10`
* `:y_scale`: x軸のスケール。`:linear` または `:log10`
* `:y2_scale`: x軸のスケール。`:linear` または `:log10`

`:series` の要素である `Hash` は以下のキー/値 を受け入れる：

* `:xy`: 数値のペアの配列。y軸に第一y軸を使う。
* `:xy2`: 数値のペアの配列。第二y軸を使う。
* `:name`: 系列の名前。凡例に使う。

※ `:series` の要素である `Hash` は、`:xy` または `:xy2` のいずれか一方が必須。
※ `:xy` と `:xy2` の両者を持つのはNG。
※ `:xy` を持つ系列がない(全てが `:xy2` を持つ)のはNG。

## `Charma::ViolinChart`

バイオリンチャート

### `.new(opts)`

`opts` は `Hash`。

対応するキー/値 は以下の通り：

* `:title`: グラフのタイトル。文字列。
* `:series`: 系列。Hash の Array。必須。
* `:bins` : データを何要素に分割するか。
* `:x_ticks`: x軸につけるラベル。文字列の配列。
* `:x_title`: x軸のタイトル(グラフ下端)。文字列。
* `:y_title`: y軸のタイトル(グラフ左端)。文字列。
* `:legend`: 凡例の位置。`:none` と `:bottom` のいずれか。省略時は `:bottom`。未対応。
* `:y_scale`: x軸のスケール。`:linear` または `:log10`

`:series` の要素である `Hash` は以下のキー/値 を受け入れる：

* `:y`: 数値の配列の配列。必須。
* `:name`: 系列の名前。凡例に使う。

※ バイオリンチャートは 第2y軸に対応しない。

