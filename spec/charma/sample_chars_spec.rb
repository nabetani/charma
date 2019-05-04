# frozen_string_literal: true

require 'spec_helper'
require "pry"

RSpec.describe :Samples do

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
    expect{
      Charma::Document.new do |doc|
        doc.add_page do |page|
          page.add_chart( chart )
        end
        doc.render( path )
      end
    }.not_to raise_error
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
    expect{
      Charma::Document.new do |doc|
        doc.add_page do |page|
          charts.each do |chart|
            page.add_chart( chart )
          end
        end
        doc.render( path )
      end
    }.not_to raise_error
    expect( File.exist?( path ) ).to be true
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
    expect{
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
    }.not_to raise_error
    expect( File.exist?( path ) ).to be true
  end
end
