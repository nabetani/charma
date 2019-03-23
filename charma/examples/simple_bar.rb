# frozen_string_literal: true

require 'charma'

Charma::Document.new{ |doc|
  doc.new_page do |page|
    page.add_barchart(
      y_values:[3,1,4,1,5]
    )
  end
  doc.new_page do |page|
    page.add_barchart(
      y_values:[9,2,6,5,4,5,8,9,7,9]
    )
  end
}.render( "simple_bar.pdf" )
