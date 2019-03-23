# frozen_string_literal: true

require 'charma'

Charma::Document.new{ |doc|
  [
    [ [3,1,4,1,5], "Lorem ipsum" ],
    [ [9,2,6,5,4,5,8,9,7,9], nil ],
    [ [76, -28, -67, 155, 77, 160, 61, 48, -63, 26], "Excepteur sint occaecat cupidatat non proident"],
  ].each do |y, title|
    doc.new_page do |page|
      page.add_barchart(
        y_values: y,
        title: title
      )
    end
  end
}.render( "simple_bar.pdf" )
