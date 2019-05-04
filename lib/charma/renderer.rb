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

    # ページを描画する
    # canvas :: 描画ターゲット
    # page :: 描画するページの情報
    # page_number :: ページ番号(0-origin)
    def render_page( canvas, page, page_number )
      if page.charts.empty?
        raise Errors::NothingToRender, "No chart in page ##{page_number+1}"
      end
      rects = split_page( canvas.page_rect, page.charts.size )
      page.charts.zip(rects).each do |chart, rect|
        t = chart_renderer(chart.chart_type)
        t.new( chart, canvas, rect.reduce(0.1) ).render
      end
    end
  end
end
