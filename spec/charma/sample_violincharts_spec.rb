# frozen_string_literal: true

require 'spec_helper'
require "pry"

RSpec.describe :ViolinChartSamples do
  before do |example|
    FileUtils.mkdir_p( SPEC_OUTPUT_DIR )
    path = makepath(example, ".pdf" )
    File.delete( path ) if File.exist?( path )
  end

  it "simple violin chart" do |example|
    path = makepath(example, ".pdf" )
    chart = Charma::ViolinChart.new(
      series:[
        {y:[[1,2,2],[3,2,2],[3,3,2]]},
        {y:[[3,3,5],[4,4,4],[3,4,6]]},
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
