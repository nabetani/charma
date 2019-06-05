# frozen_string_literal: true

require 'spec_helper'
require "pry"

RSpec.describe :PageSamples do
  before do |example|
    FileUtils.mkdir_p( SPEC_OUTPUT_DIR )
    path = makepath(example, ".pdf" )
    File.delete( path ) if File.exist?( path )
  end

  it "has various page sizes" do |example|
    path = makepath(example, ".pdf" )
    chart = Charma::ScatterChart.new(
      title: "sin and cos",
      x_title: "hoge",
      y_title: "fuga",
      series: [
        {name:"sin", xy:0.step(by:0.1, to:Math::PI).map{ |e| [e,Math.sin(e)] }},
        {name:"cos", xy:0.step(by:0.1, to:Math::PI).map{ |e| [e,Math.cos(e)] }},
      ]
    )
    page_sizes = [
      "A4", "A5", 
      "100x300", "300x100",
      [100,300], [300,100],
    ]
    Charma::Document.new do |doc|
      page_sizes.each do |size|
        doc.add_page(page_size:size) do |page|
          page.add_chart( chart )
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end

  it "specifies layout" do |example|
    path = makepath(example, ".pdf" )
    chart = Charma::ScatterChart.new(
      x_title: "hoge",
      y_title: "fuga",
      series: [
        {name:"1/(2+sin(x))", xy:0.step(by:0.1, to:Math::PI*2).map{ |e| [e,1/(2+Math.sin(e))] }},
        {name:"1/(2+cos(x))", xy:0.step(by:0.1, to:Math::PI*2).map{ |e| [e,1/(2+Math.cos(e))] }},
      ]
    )
    layouts = [
      { size:"A4", layout: :portrait },
      { size:"A4", layout: :landscape },
      { size:"100x300", layout: :portrait },
      { size:"100x300", layout: :landscape },
      { size:"300x100", layout: :portrait },
      { size:"300x100", layout: :landscape },
    ]
    Charma::Document.new do |doc|
      layouts.each do |size:, layout:|
        doc.add_page(page_size:size, page_layout: layout) do |page|
          page.add_chart( chart )
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end

  it "specifies font" do |example|
    path = makepath(example, ".pdf" )
    opt = {
      x_title:"日本語",
      y_title:"ほげふが",
      series: [1.5,2,4].map do |n|
        {
          name:"1/(#{n}+sincos(t))",
          xy:0.step(by:0.1, to:Math::PI*2).map{ |t|
            [1/(n+Math.cos(t)), 1/(n+Math.sin(t))]
          }
        }
      end
    }

    fonts = if ENV["SystemRoot"]
      root = File.join( ENV["SystemRoot"], "Fonts" )
      [
        File.join( root, "HGRSKP.TTF" ),
        File.join( root, "HGRSMP.TTF" ),
        "游明朝 Light",
        "源真ゴシックP ExtraLight",
        "源真ゴシックP Heavy",
      ]
    else
      [
        "~/Library/Fonts/NotoSans-Regular.ttf", # fullpath with "~"
        "/System/Library/Fonts/SFNSText.ttf", # fullpath
        "SetoFont", # postscript name
        "Migu 1C Bold", # 正式名称
        "IPAex明朝", # 日本語正式名称
        "源真ゴシックP ExtraLight",
        "源真ゴシックP Heavy"
      ]
    end

    Charma::Document.new do |doc|
      fonts.each do |font|
        doc.add_page(font:font) do |page|
          page.add_chart( Charma::ScatterChart.new(opt.merge( title:font ) ) )
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end
end
