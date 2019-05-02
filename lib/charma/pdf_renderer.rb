# frozen_string_literal: true

module Charma

  # PDF への描画をするクラス
  class PDFRenderer < Renderer

    # PDFRenderer を構築する
    # pages :: ページ情報のリスト
    # opts :: オプション
    def initialize( pages, opts )
      super
    end

    # ミリメートルをPDFポイントに変換する
    def mm_to_pdfpoint(mm)
      mm * (72/25.4)
    end

    # ページ情報をもとに Prawn にわたすオプションを作る
    # page :: ページ情報
    def create_opts( page )
      r={}
      size = page.size.rectangular.map{ |mm| mm_to_pdfpoint(mm) }
      r[:page_size] = r[:size] = size
      r
    end

    # Prawnドキュメントを生成するオプションを作る
    def prawn_opts
      {
        info:{
          Creator: "Charma",
          Producer: "Charma"
        }
      }.merge( create_opts( @pages.first ) )
    end

    # PDFを生成する
    # filename :: 出力ファイル名
    def render( filename )
      Prawn::Document.generate(filename, prawn_opts) do |pdf|
        @pages.each.with_index do |page,ix|
          pdf.start_new_page( create_opts(page) ) if ix != 0
          render_page(PDFCanvas.new(pdf), page, ix)
          pdf.stroke_axis # TODO: remove this line
        end
      end
    end
  end
end
