# frozen_string_literal: true

require 'spec_helper'
require "pry"

RSpec.describe :ScatterChartSamples do
  before do |example|
    FileUtils.mkdir_p( SPEC_OUTPUT_DIR )
    path = makepath(example, ".pdf" )
    File.delete( path ) if File.exist?( path )
  end

  it "simple chart" do |example|
    path = makepath(example, ".pdf" )
    chart = Charma::ScatterChart.new(
      title: "foo and bar",
      x_title: "hoge",
      y_title: "fuga",
      series: [
        {name:"foo", xy:(-1..4).map{ |e| [e,e] }},
        {name:"bar", xy:(-1..4).map{ |e| [e,4-e] }},
      ]
    )
    Charma::Document.new do |doc|
      doc.add_page do |page|
        page.add_chart( chart )
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end

  it "dot count" do |example|
    vals = lambda do |c,n|
      rot = c**0.3
      Array.new(c) do |ix|
        t = Math::PI * 2 * ix / c * rot + n
        [ Math.cos(t)* ix, Math.sin(t) * ix ]
      end
    end
    path = makepath(example, ".pdf" )
    charts = Array.new(9) do |ix|
      count = 2**ix
      Charma::ScatterChart.new(
        series: Array.new(ix+1){ |serinum|
          {name:"series ##{serinum}", xy:vals[count,serinum]}
        }
      )
    end
    Charma::Document.new do |doc|
      doc.add_page do |page|
        charts.each do |chart|
          page.add_chart( chart )
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end
end
