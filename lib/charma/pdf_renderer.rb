# frozen_string_literal: true

module Charma
  class PDFRenderer < Renderer
    def initialize( pages, opts )
      super
    end

    def mm_to_pdfpoint(mm)
      mm * (72/25.4)
    end

    def create_opts( page )
      r={}
      size = page.size.rectangular.map{ |mm| mm_to_pdfpoint(mm) }
      r[:page_size] = r[:size] = size
      r
    end

    def prawn_opts
      {
        info:{
          Creator: "Charma",
          Producer: "Charma"
        }
      }.merge( create_opts( @pages.first ) )
    end

    def render( filename )
      Prawn::Document.generate(filename, prawn_opts) do |pdf|
        @pages.each.with_index do |page,ix|
          pdf.start_new_page( create_opts(page) ) if ix != 0
          render_page(PDFCanvas.new(pdf), page)
          pdf.stroke_axis # TODO: remove this line
        end
      end
    end
  end
end
