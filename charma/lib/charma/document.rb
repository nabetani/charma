# frozen_string_literal: true

module Charma
  class Document
    def initialize( &block )
      @pages = []
      block[self]
    end

    def new_page(&block)
      page = Page.new(self)
      block[page]
      @pages.push page
    end

    def render( filename )
      raise "no page added" if @pages.empty?
      opts = @pages.first.create_opts
      Prawn::Document.generate(filename, opts) do |pdf|
        @pages.each.with_index do |page,ix|
          pdf.start_new_page(page.create_opts) if ix != 0
          page.render(pdf)
        end
      end
    end
  end
end
