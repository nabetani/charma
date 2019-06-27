# frozen_string_literal: true

module Charma

  # ドキュメントを描画するクラス。PDFRenderer などの基底クラス
  class Renderer

    # Renderer を構築する
    # pages :: ページ情報のリスト
    # opts :: オプション
    def initialize( pages, opts )
      @pages = pages
      @opts = opts
    end

    # チャートタイプに対応するチャートを描画するクラスを返す
    # ct :: チャートタイプ
    def chart_renderer(ct)
      case ct
      when :bar_chart
        BarChartRenderer
      when :scatter_chart
        ScatterChartRenderer
      when :violin_chart
        ViolinChartRenderer
      else
        raise Charma::Error, "unexpected chart type: #{ct}"
      end
    end

    # ページをいい感じに分割する
    # total :: ページの矩形
    # count :: 何個に分割するか
    def split_page( total, count )
      xcount = (1..count ).min_by{ |w|
        h = ( count.to_r / w.to_r ).ceil
        cw = total.w.to_f / w
        ch = total.h.to_f / h
        Math.log(cw/ch).abs
      }
      ycount = ( count.to_r / xcount.to_r ).ceil
      total.vsplit( *Array.new(ycount, 1) ).map{ |rc|
        rc.hsplit( *Array.new(xcount, 1) )
      }.flatten
    end

    # ページ内のチャートを描画する
    # @param [PDFCanvas, SVGCanvas] canvas 描画ターゲット
    # @param [Page] page 描画するページの情報
    # @param [Rect] charts_rect 全チャートを含む矩形
    def render_page_charts( canvas, page, charts_rect )
      rects = split_page( charts_rect, page.charts.size )
      canvas.font=page.font
      page.charts.zip(rects).each do |chart, rect|
        t = chart_renderer(chart.chart_type)
        t.new( chart, canvas, rect.reduce(0.1) ).render
      end
    end

    # ページを描画する
    # @param [PDFCanvas, SVGCanvas] canvas 描画ターゲット
    # @param [Page] page 描画するページの情報
    # @param [Numeric] page_number ページ番号(0-origin)
    def render_page( canvas, page, page_number )
      if page.charts.empty?
        raise Errors::NothingToRender, "No chart in page ##{page_number+1}"
      end
      if page.title
        title, charts = canvas.page_rect.vsplit(1,10)
        canvas.text(page.title, title )
        render_page_charts( canvas, page, charts )
      else
        render_page_charts( canvas, page, canvas.page_rect )
      end
    end
  end
end
