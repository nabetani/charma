# frozen_string_literal: true

require 'charma'

Charma::Document.new do |doc|
  [
    {
      title: "Lorem ipsum",
      series:[
        {
          x: [2, 3, 5, 7, 11, 12, 13, 15, 17, 20],
          y: [0.2, 0.7, 0.7, 0.1, 2.9, 4.4, 2.9, 4.5, 7.9, 0.5],
          name: "The world is melon"
        },
        {
          x: [4, 5, 7, 8, 10, 13, 15, 17, 20],
          y: [1.0, 1.6, 0.9, 0.0, 0.3, 5.1, 2.1, 0.9, 4.9],
        }
      ],
    },
    {
      title: "Semi-log graph",
      y_scale: :log10,
      series:[
        {
          x: [*1..10],
          y: (1..10).map{ |x| 10.0**x },
          name: "10.0**x"
        },
        {
          x: [*1..10],
          y: (1..10).map{ |e| 2**(1.41**e) },
          name: "2**(1.41**e)"
        },
      ]
    },
    {
      title: "Log-log graph",
      x_scale: :log10,
      y_scale: :log10,
      series:[
        {
          x: (1..10).map{ |t| 10.0**t },
          y: (1..10).map{ |t| 10.0**t+1e7 },
          name: "10.0**x+1e7"
        },
        {
          x: (1..10).map{ |t| 10.0**t },
          y: (1..10).map{ |t| 10.0**t*3 },
          name: "10.0**t*3"
        },
      ]
    },
    {
      title: "Name only X",
      x_ticks: ["2017-Q1", "2017-Q2", "2017-Q3", "2017-Q4", "2018-Q1", "2018-Q2", "2018-Q3", "2018-Q4"],
      series:[
        {
          y: [41, -23, 52, -6, 18, 62, 70, 98],
          name: "foo",
        },
        {
          y: [63, -19, 2, 91, -2, 132, 93, 13],
          name: "bar",
        },
      ]
    },
    {
      title: "Y only",
      series:[
        {
          y: Array.new(100){ |n| Math.sin(n*0.01*Math::PI*2) },
          name: "sin",
        },
        {
          y: Array.new(100){ |n| Math.cos(n*0.01*Math::PI*2) },
          name: "cos",
        },
      ]
    },
    Array.new(4){ |g|
      {
        title:" Graph No. #{g}",
        series: Array.new(4){ |n|
          len=100
          r = Math::PI*2/len
          {
            name: "sin(t*#{g})+sin(t**0.5*#{n})",
            y:Array.new(len){ |t| Math.sin(t*r*g)+Math.sin((t*r)**0.5*n) }
          }
        }
      }
    }
  ].each do |opts|
    doc.new_page do |page|
      case opts
      when Hash
        page.add_linechart( opts )
      when Array
        opts.each{ |o| page.add_linechart( o ) }
      else
        raise "unexpected input #{opts.inspect}"
      end
    end
  end
  doc.render( File.basename(__FILE__, ".*")+".pdf" )
end
