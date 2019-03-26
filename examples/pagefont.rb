# frozen_string_literal: true

require 'charma'
require "rbconfig"

def macos?
  case RbConfig::CONFIG['host_os']
  when /darwin/, /mac\s*os/i
    true
  else
    false
  end
end

unless macos?
  warn( "This sample runs only on macOS" )
  exit
end

Charma::Document.new do |doc|
  [
    "/System/Library/Fonts/Menlo.ttc",
    "/System/Library/Fonts/Times.ttc",
    "/System/Library/Fonts/Courier.dfont",
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/LucidaGrande.ttc",
  ].each do |fontpath|
    title = File.basename(fontpath,".*").capitalize
    doc.new_page(font:fontpath) do |page|
      page.add_barchart(
        title:title,
        series:[{y:title.chars.map(&:ord)}],
        x_ticks:title.chars,
      )
    end
  end
  doc.render( File.basename(__FILE__, ".*")+".pdf" )
end
