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
    opts=[]
    opts.push( {
      bins:10,
      series:[
        {y:[[1,2,2],[3,2,2],[3,3,2]]},
        {y:[[3,3,5],[4,4,4],[3,4,10]]},
      ]
    } )
    opts.push(
      bins:300,
      series:Array.new(2){ |s|
        {
          name:"s=#{s}",
          y:Array.new(3){ |x|
            Array.new(1000){ |i|
              if s==0
                Math.sin(i)+(x+1)
              else
                mask = 0xaaaaaaaaaa
                (Math.sin(i&mask)+Math.sin(i&~mask))+(x+1)
              end
            }
          }
        }
      }
    )
    Charma::Document.new do |doc|
      doc.add_page do |page|
        opts.each do |opt|
          page.add_chart( Charma::ViolinChart.new(opt) )
        end
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end
end
