# frozen_string_literal: true

require 'charma'

Charma::Document.new{ |doc|
  [
    {
      y_values: [3,1,4,1,5],
      title: "Lorem ipsum",
    },
    {
      y_values: [9,2,6,5,4,5,8,9,7,9],
    },
    {
      y_values: [76, -28, -67, 155, 77, 160, 61, 48, -63, 26],
      title: "Excepteur sint occaecat cupidatat non proident",
    }
  ].each do |opts|
    doc.new_page do |page|
      page.add_barchart( opts )
    end
  end
}.render( "simple_bar.pdf" )
