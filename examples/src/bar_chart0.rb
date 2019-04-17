require "charma"

doc = Charma::Document.new
page = doc.add_page

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

# y の各要素の名前
x_ticks = %w(foo bar baz qux quux corge)

# グラフの下端につく、x軸を説明する文字列
x_title = "from foo to corge"

chart = Charma::BarChart.new(
  title:title,
  series:series,
  x_ticks:x_ticks,
  x_title:x_title
)
page.add_chart( chart )

doc.render( "hoge.pdf" ) # PDF を出力
# doc.render( "fuga.svg" ) # SVG を出力
