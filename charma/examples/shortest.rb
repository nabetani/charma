# frozen_string_literal: true

require 'charma'

Charma::Document.new do |doc|
  doc.new_page do |page|
    page.add_barchart( 
      series:[{y:[3,1,4,1,5]}],
      x_ticks:%w[ foo bar baz qux quux]
    )
  end
  doc.render( File.basename(__FILE__, ".*")+".pdf" )
end
