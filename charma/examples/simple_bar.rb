# frozen_string_literal: true

require 'charma'

Charma::Document.new{ |doc|
  [
    {
      series: [
        {
          name: "pi",
          y: [3,1,4,1,5]
        },
        {
          name: "sqrt(2)",
          y: [1,4,1,4,2]
        },
        {
          name: "sqrt(5)",
          y: [2,2,3,6,2]
        },
      ],
      title: "Lorem ipsum",
      x_ticks: %w(foo bar baz qux quux),
    },
    {
      series: [{y: [9,2,6,5,4,5,8,9,7,9]}],
    },
    {
      series: [{y: [76, -28, -67, 155, 77, 160, 61, 48, -63, 26]}],
      title: "Excepteur sint occaecat cupidatat non proident",
      x_ticks:%w(foo bar baz qux quux corge grault garply waldo fred),
    },
    {
      series: [{y: [7e+06, 2.8e+07, 1.2e+07, 1.5e+07, 2.7e+07, 2.5e+07, 1.3e+07]}],
      x_ticks: %w(Alcyone Atlas Electra Maia Merope Taygeta Pleione),
      y_label: "Random Number",
    },
    [
      {
        series: [{y:[6,8,3,17,-12,38]}],
        title:"salamander",
      },
      {
        series: [{y:[100,-4,-8,14,-17,57]}],
        title:"gradius",
      },
    ],
    Array.new(11){ |n|
      {
        series: [{y: ->{ srand(n); m=rand+0.1; Array.new(7){ m*(rand+rand-rand) } }[]}],
        title:"graph #{n}",
        y_range: [-1.1, 2.2],
      }
    }
  ].each do |opts|
    doc.new_page do |page|
      case opts
      when Hash
        page.add_barchart( opts )
      when Array
        opts.each{ |o| page.add_barchart( o ) }
      else
        raise "unexpected input #{opts.inspect}"
      end
    end
  end
}.render( "simple_bar.pdf" )
