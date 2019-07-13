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

  it "various dot count" do |example|
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

  it "log10 scale" do |example|
    path = makepath(example, ".pdf" )
    charts = Array.new(4) do |ix|
      x = ix[0]==0 ? :linear : :log10
      xf = ix[0]==0 ? ->(v){ v } : ->(v){ 10**v }
      y = ix[1]==0 ? :linear : :log10
      yf = ix[1]==0 ? ->(v){ v } : ->(v){ 10**v }
      Charma::ScatterChart.new(
        x_scale: x,
        y_scale: y,
        title: "x:#{x}, y:#{y}",
        series: [
          {xy:(-1..4).map{ |e| [xf[e], yf[e]] }}
        ]
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

  it "chart with styles" do |example|
    path = makepath(example, ".pdf" )
    values = ->(type){
      size = 20*2**type
      Array.new(size){ |ix|
        t=ix*Math::PI*2/size
        r = (ix+size)/(2-Math.cos(t*(3+type*2)))/size
        [Math.cos(t)*r+type, Math.sin(t)*r]
      }
    }
    chart = Charma::ScatterChart.new(
      title: "many styles",
      series: [
        {xy:values[0], name:"none"},
        %i(dot line dot_and_line line_and_dot).map.with_index(1){ |s,ix|
          { xy:values[ix], name:s, style:s }
        }
      ].flatten
    )
    Charma::Document.new do |doc|
      doc.add_page do |page|
        page.add_chart( chart )
      end
      doc.add_page do |page|
        %i(dot line dot_and_line line_and_dot).each do |s|
          4.times do |ix|
            page.add_chart( Charma::ScatterChart.new(
              title: s,
              series: [
                xy:values[ix],
                style: s, 
                name: s
              ]
            ) )
          end
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end

  it "log10 scale with y2" do |example|
    path = makepath(example, ".pdf" )
    charts = Array.new(8) do |ix|
      x = ix[0]==0 ? :linear : :log10
      xf = ix[0]==0 ? ->(v){ v } : ->(v){ 10**v }
      y = ix[1]==0 ? :linear : :log10
      yf = ix[1]==0 ? ->(v){ v } : ->(v){ 10**v }
      y2 = ix[2]==0 ? :linear : :log10
      y2f = ix[2]==0 ? ->(v){ v } : ->(v){ 10**v }
      Charma::ScatterChart.new(
        x_scale: x,
        y_scale: y,
        y2_scale: y2,
        title: "x:#{x}, y:#{y}, y2:#{y2}",
        series: [
          {xy:(-1..4).map{ |e| [xf[e], yf[e]] }},
          {xy2:(-1..4).map{ |e| [xf[e+0.5], 1000*y2f[e]] }}
        ]
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
