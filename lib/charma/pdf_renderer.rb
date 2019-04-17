# frozen_string_literal: true

module Charma
  class PDFRenderer < Renderer
    def initialize( pages, opts )
      super
    end

    def prawn_opts
      {}
    end

    def render( filename )
      Prawn::Document.generate(filename, prawn_opts) do |pdf|
        @pages.each.with_index do |page,ix|
          pdf.start_new_page(page.create_opts) if ix != 0
          render_page(PDFCanvas.new(pdf), page)
        end
      end
    end
  end
end
