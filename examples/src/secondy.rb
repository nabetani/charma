# frozen_string_literal: true

require "charma"

def out_path(type)
  title = File.basename( __FILE__, ".*" )
  File.join( File.split(__FILE__)[0], "../#{type}/#{title}.#{type}" )
end

%x( rm #{out_path("pdf")} )

def make_series( val, keta, count )
  s = "%.*f" % [ keta*count, val ]
  s.chars.grep( /\d/ ).each_slice(keta).map{ |e| e.join.to_f }.take(count)
end

Charma::Document.new do |doc|
  doc.add_page do |page|
    page.add_chart(
      Charma::BarChart.new(
        y_title:"left y",
        y2_title:"right y",
        series:[
          {
            name:"use left y",
            y: make_series(Math::PI, 1, 3)
          },
          {
            name:"use right y",
            y2: make_series(Math::PI, 2, 3)
          }
        ]
      )
    )
  end
  doc.render( out_path("pdf") )
end
