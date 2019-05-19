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
end
