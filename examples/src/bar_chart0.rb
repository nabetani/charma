# frozen_string_literal: true

require "charma"

doc = Charma::Document.new
page1 = doc.add_page( page_size:"A4", page_layout: :portrait )

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

single_series = [
  {
    name: "Napier's constant",
    y: Math::E.to_s.chars.select{ |e| (?0..?9)===e }.map(&:to_f)
  }
]

# y の各要素の名前
x_ticks = %w(foo bar baz qux quux corge)

# グラフの下端につく、x軸を説明する文字列
x_title = "from foo to corge"

# グラフの左端につく、y軸を説明する文字列
y_title = "meaningless value"

chart0 = Charma::BarChart.new(
  title:"Meaningless chart",
  series:series,
  x_ticks:x_ticks,
  x_title:x_title,
  y_title:y_title
)

chart1 = Charma::BarChart.new(
  title:"Negative meaningless chart",
  series:series.map{ |e| { name:e[:name], y:e[:y].map(&:-@) } },
  x_ticks:x_ticks,
  x_title:x_title,
  y_title:y_title
)

chart2 = Charma::BarChart.new(
  title:"Positive and egative meaningless chart",
  series:series.map{ |e| { name:e[:name], y:e[:y].map{ |v| v-4.5 } } },
  x_ticks:x_ticks,
  x_title:x_title,
  y_title:y_title
)

chart3 = Charma::BarChart.new(
  title:"Single Series chart",
  series:single_series,
  x_title:x_title,
  y_title:y_title
)

[chart0, chart1, chart2, chart3].each do |chart|
  page1.add_chart chart
end

%i( landscape portrait ).each do |la|
  pa = doc.add_page( page_size:[100, 300], page_layout: la )
  [chart0, chart1, chart2].each do |chart|
    pa.add_chart chart
  end
end

def out_path(type)
  title = File.basename( __FILE__, ".*" )
  File.join( File.split(__FILE__)[0], "../#{type}/#{title}.#{type}" )
end

%x( rm #{out_path("pdf")} )

doc.render( out_path("pdf") ) # PDF を出力
# doc.render( "fuga.svg" ) # SVG を出力
