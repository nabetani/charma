require "charma"

doc = Charma::Document.new
page = doc.add_page

title = "Various Numbers"

series = [
  { name: "pi", y: Math::PI },
  { name: "sqrt(2)", y: 2**0.5 },
  { name: "Napier", y: Math::E },
  { name: "log(2)", y: Math.log(2) },
  { name: "sin(1)", y: Math.sin(1) },
  { name: "cos(1)", y: Math.cos(1) },
]

chart = Charma::BarChart.new(
  title:title,
  series:series,
)
page.add_chart( chart )

doc.render( "hoge.pdf" ) # PDF を出力
doc.render( "fuga.svg" ) # SVG を出力
