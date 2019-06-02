# frozen_string_literal: true

require 'spec_helper'
require "pry"

RSpec.describe :ViolinChartSamples do
  before do |example|
    FileUtils.mkdir_p( SPEC_OUTPUT_DIR )
    path = makepath(example, ".pdf" )
    File.delete( path ) if File.exist?( path )
  end

  it "can be simple chart" do |example|
    path = makepath(example, ".pdf" )
    opt ={
      bins:10,
      series:[
        {y:[[1,2,2],[4,4,4],[3,3,2]]},
        {y:[[3,3,5],[4,4,4],[3,4,10]]},
      ]
    }
    Charma::Document.new do |doc|
      doc.add_page do |page|
        page.add_chart( Charma::ViolinChart.new(opt) )
      end
      doc.render( path )
    end
    expect( File.exist?( path ) ).to be true
  end

  it "can be various charts" do |example|
    path = makepath(example, ".pdf" )
    opts = []
    opts.push(
      bins:300,
      x_ticks:%w(foo bar baz),
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
    n=100
    rng = Random.new(1)
    procs = [
      ->(x){ x.sum/x.size.to_f },
      ->(x){ x.max },
      ->(x){ x.min },
      ->(x){ x.sort[x.size/2] }
    ]
    opts.push(
      x_ticks:%w(foo bar),
      bins:100,
      series:procs.map{ |proc|
        {
          y:Array.new(2){ |x|
            Array.new(n*2){ |i|
              proc[Array.new(11){rng.rand + i % (x+1)}] * (2-x)
            }
          }
        }
      }
    )
    opts.push(
      x_title:"x title",
      y_title:"y title",
      title:"title",
      bins:100,
      series:Array.new(4){ |s|
        {
          name:"s=#{s}",
          y:[
            Array.new(1000){ |i|
              Array.new(11){rng.rand + i % (s+1)}.sum / (s+1)
            }
          ]
        }
      }
    )
    opts.push(
      title:"title",
      bins:2000,
      x_ticks:%w( foo bar baz qux quux ),
      series:[
        {
          y:Array.new(5){ |x|
            e = (2**x)
            Array.new(1000){ |i|
              Array.new(11){rng.rand + i % e}.sum / e
            }
          }
        }
      ]
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

  it "can use log10 scale" do |example|
    path = makepath(example, ".pdf")
    opts=[]
    opts.push(
      title:"Equally spaced",
      bins:100,
      x_ticks:%w( foo bar baz ),
      y_scale: :log10,
      series:Array.new(2){ |s|
        {
          y:Array.new(3){ |x|
            Array.new(10){ |e|
              10**(e*(s+1)+x)
            }
          }
        }
      }
    )
    deltas = [0.5,0.6,0.7]
    opts.push(
      title:"Random walk by multiplication",
      bins:100,
      x_ticks:deltas,
      y_scale: :log10,
      series:Array.new(4){ |s|
        {
          name:"seed=#{s}",
          y:deltas.map{ |d|
            rng = Random.new(s)
            (1..100).inject([1]){ |acc,| acc+[acc.last*(rng.rand+d)] }
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
