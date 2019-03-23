require "charma/version"
require "prawn"

module Charma
  class Error < StandardError; end

  class Chart
  end

  class BarChart < Chart
    def initialize(opts)
      @opts = opts
    end
  end

  class Page
    def initialize( doc )
      @doc = doc
      @graphs = []
    end

    def add_barchart(opts)
      @graphs.push BarChart.new(opts)
    end
  end

  class Document
    def initialize( &block )
      @pages = []
      block[self]
    end

    def new_page(&block)
      p @pages
      page = Page.new(self)
      block[page]
      @pages.push page
    end

    def render( filename )
      Prawn::Document.generate(filename) do |pdf|
        pdf.text( "hoge" )
      end
    end
  end
end
