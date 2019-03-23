# frozen_string_literal: true

require 'charma'

Charma::Document.new{ |doc|
  doc.new_page do |page|
    page.add_barchart(
      y_values:[3,1,4,1,5],
    )
  end
}.render( "simple_bar.pdf" )
