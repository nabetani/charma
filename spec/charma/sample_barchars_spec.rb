# frozen_string_literal: true

require 'spec_helper'
require "pry"

RSpec.describe :BarChartSamples do
  before do |example|
    FileUtils.mkdir_p( SPEC_OUTPUT_DIR )
    path = makepath(example, ".pdf" )
    File.delete( path ) if File.exist?( path )
  end

  it "simple bar chart" do |example|
    path = makepath(example, ".pdf" )
    chart = Charma::BarChart.new( 
      series: [y:[*1..4]]
    )
    Charma::Document.new do |doc|
      doc.add_page do |page|
        page.add_chart( chart )
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end

  it "two charts in a page" do |example|
    path = makepath(example, ".pdf" )
    charts = [
      Charma::BarChart.new(
        title: "first chart",
        series: [y:[*1..5]]
      ),
      Charma::BarChart.new(
        title: "second chart",
        series: [y:[*1..6]]
      )
    ]
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

  it "multi series chart" do |example|
    path = makepath(example, ".pdf" )
    charts = Array.new(4) do |ix|
      series = Array.new(ix*2+2) do |is|
        { y:[*1..(ix+3)].map{ |e| e-is*0.01 } }
      end
      Charma::BarChart.new( series:series )
    end
    Charma::Document.new do |doc|
      doc.add_page do |page|
        charts.each do |chart|
          page.add_chart(chart)
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end

  it "with y2" do |example|
    path = makepath(example, ".pdf" )
    charts = [
      Charma::BarChart.new(
        series:[
          { name:"y-first", y:[1,2,3,4] },
          { name:"y-second", y:[4,3,2,1] },
          { name:"y2-first", y2:[50,60,70,80] },
          { name:"y2-second", y2:[90,80,70,60] },
        ]
      ),
      Charma::BarChart.new(
        series:[
          { name:"y-first", y:[1,2,3,-4] },
          { name:"y-second", y:[4,3,2,1] },
          { name:"y2-first", y2:[-50,60,70,80] },
          { name:"y2-second", y2:[90,80,70,60] },
        ]
      ),
      Charma::BarChart.new(
        series:[
          { name:"y-first", y:[-1,-2,-3,-4] },
          { name:"y-second", y:[4,3,2,1] },
          { name:"y2-first", y2:[50,60,70,80] },
          { name:"y2-second", y2:[90,80,70,60] },
        ]
      ),
      Charma::BarChart.new(
        series:[
          { name:"y-first", y:[-1,-2,-3,-4] },
          { name:"y-second", y:[-4,-3,-2,-1] },
          { name:"y2-first", y2:[50,60,70,80] },
          { name:"y2-second", y2:[90,80,70,60] },
        ]
      ),
      Charma::BarChart.new(
        series:[
          { name:"y-first", y:[1,2,3,4] },
          { name:"y-second", y:[4,3,2,1] },
          { name:"y2-first", y2:[-50,-60,-70,-80] },
          { name:"y2-second", y2:[-90,-80,-70,-60] },
        ]
      )
    ]
    Charma::Document.new do |doc|
      doc.add_page do |page|
        charts.each do |chart|
          page.add_chart(chart)
        end
      end
      doc.render( path )
      expect( File.exist?( path ) ).to be true
    end
  end

  it "with titles" do |example|
    path = makepath(example, ".pdf" )
    charts = Array.new(16) do |ix|
      Charma::BarChart.new(
        title: ix[0].zero? ? "title ##{ix}" : nil,
        x_title: ix[1].zero? ? "x title ##{ix}" : nil,
        y_title: ix[2].zero? ? "y title ##{ix}" : nil,
        y2_title: ix[3].zero? ? "y2 title ##{ix}" : nil,
        series: [
          {y:[*1..(ix+2)]},
          {y2:[*1..(ix+2)].map{ |e| e*100 }},
        ]
      )
    end
    Charma::Document.new do |doc|
      doc.add_page do |page|
        charts.each do |chart|
          page.add_chart(chart)
        end
      end
      doc.render( path )
      expect( File.exist?( path ) ).to be true
    end
  end

  it "with x_ticks" do |example|
    path = makepath(example, ".pdf" )
    charts = Array.new(4) do |ix|
      num = ix*2+1
      Charma::BarChart.new(
        title: "chart ##{ix}",
        series: [y:[*1..num]],
        x_ticks: [*1..num].map(&:to_s)
      )
    end
    Charma::Document.new do |doc|
      doc.add_page do |page|
        charts.each do |chart|
          page.add_chart(chart)
        end
      end
      doc.render( path )
      expect( File.exist?( path ) ).to be true
    end
  end

  it "various page size with three charts" do |example|
    path = makepath(example, ".pdf" )
    charts = [
      Charma::BarChart.new(
        title: "first chart",
        series: [y:[*1..7]]
      ),
      Charma::BarChart.new(
        title: "second chart",
        series: [y:[*1..8]]
      ),
      Charma::BarChart.new(
        title: "third chart",
        series: [y:[*1..9]]
      )
    ]
    Charma::Document.new do |doc|
      [nil, :landscape, :portrait].each do |layout|
        [ "A4", "100x300", [300,100] ].each do |size|
          doc.add_page(page_size:size, page_layout:layout) do |page|
            charts.each do |chart|
              page.add_chart( chart )
            end
          end
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end
end
