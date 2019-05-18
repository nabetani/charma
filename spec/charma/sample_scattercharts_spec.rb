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
      series: [xy:(1..4).map{ |e| [e,e] }]
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
