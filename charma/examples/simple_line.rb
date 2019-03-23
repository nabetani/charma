# frozen_string_literal: true

require 'charma'

Charma::Document.new{ |doc|
  [
    {
      title: "Lorem ipsum",
      series:[
        {
          x_values: [2, 3, 5, 7, 11, 12, 13, 15, 17, 20],
          y_values: [0.2, 0.7, 0.7, 0.1, 2.9, 4.4, 2.9, 4.5, 7.9, 0.5],
        },
        {
          x_values: [4, 5, 7, 8, 10, 13, 15, 16, 17, 20],
          y_values: [1.0, 1.6, 0.9, 0.0, 0.3, 5.1, 2.1, 0.9, 4.9, 7.8],
        }
      ],
    },
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
}.render( "simple_line.pdf" )
