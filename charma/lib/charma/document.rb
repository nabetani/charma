# frozen_string_literal: true

module Charma
  class Document
    def initialize(opts={}, &block )
      @pages = []
      @opts = opts
      block[self]
    end

    def new_page(opts={},&block)
      page = Page.new(opts)
      block[page]
      @pages.push page
    end

    def render( filename )
      raise "no page added" if @pages.empty?
      opts = @pages.first.create_opts.merge(@opts)
      Prawn::Document.generate(filename, opts) do |pdf|
        pdf.font( File.expand_path(@opts[:font]) ) if @opts[:font]
        @pages.each.with_index do |page,ix|
          pdf.start_new_page(page.create_opts) if ix != 0
          page.render(pdf)
        end
      end
    end
  end
end
