# frozen_string_literal: true

require 'charma'

fontpath = "~/Library/Fonts/ipaexg.ttf"

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

unless File.exist?( File.expand_path(fontpath) )
  warn( "このサンプルを実行するには、IPAexゴシック Regular をインストールする必要があります" )
  exit
end

Charma::Document.new( font:"~/Library/Fonts/ipaexg.ttf" ) do |doc|
  doc.new_page do |page|
    page.add_barchart( 
      series:[{y:[3,1,4,1,5]}],
      x_ticks:%w[ ほげ ふが ぴよ 魑魅魍魎 𩸽と𩹉 ],
    )
  end
  doc.render( File.basename(__FILE__, ".*")+".pdf" )
end
