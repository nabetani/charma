# frozen_string_literal: true

require 'charma'

SampleMaker = Struct.new(:size) do
  def r
    n=0.5
    4.times.inject(0){ |acc,| acc + rand(-n..n) }
  end

  def samples(*peaks)
    srand(0)
    Array.new(size){
      r + peaks.sample
    }
  end
end

foobar = SampleMaker.new(20000)

small = SampleMaker.new(6)

Charma::Document.new{ |doc|
  [
    {
      title: "Lorem ipsum",
      series:[
        {
          name: "foo",
          y: Array.new(4){ |n| foobar.samples(n+2, (n+2)*2) }
        },
        {
          name: "bar",
          y: Array.new(4){ |n| foobar.samples(n+2, (n+2)*2, 6) }
        },
      ],
      x_ticks: %w(Q1 Q2 Q3 Q4),
    },
    {
      title: "Small size sample",
      series:[
        {
          name: "foo",
          y: Array.new(4){ |n| small.samples(n+2, (n+2)*2) }
        },
        {
          name: "bar",
          y: Array.new(4){ |n| small.samples(n+2, (n+2)*2, 6) }
        },
      ],
      x_ticks: %w(Q1 Q2 Q3 Q4),
    },
  ].each do |opts|
    doc.new_page do |page|
      case opts
      when Hash
        page.add_violinchart( opts )
      when Array
        opts.each{ |o| page.add_violinchart( o ) }
      else
        raise "unexpected input #{opts.inspect}"
      end
    end
  end
}.render( File.basename(__FILE__, ".*")+".pdf" )
