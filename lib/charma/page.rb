# frozen_string_literal: true

module Charma
  # Charma の Page 情報
  class Page

    # Page を構築する
    # @param [String, nil] title ページタイトル
    # @param [String, nil] font フォント名。フルパスでも、PostScript名でも、正式名でも。
    # @param [String, Array(Numeric,Numeric), nil] page_size ページサイズ。"A4" のような形式か、"210x297" のような形式。あるいは [100,200] のような配列
    # @param [Symbol, nil] page_layout :landscape (横長) または :portrait (縦長)。あるいは nil。
    # ブロック引数を取り、自分を引数としたブロック呼び出しになる
    def initialize(
      page_title: nil,
      font:nil,
      page_size:DEFAULT_PAGE_SIZE,
      page_layout: nil,
      &block
    )
      @title = page_title.to_s
      @charts = []
      @font = font
      @size = parse_papersize( page_size, page_layout )
      block[self] if block
    end

    # ページタイトル
    attr_reader :title

    # ページサイズ。複素数。実部が横幅。虚部が縦幅。
    attr_reader :size

    # ページ内のチャートのリスト
    attr_reader :charts

    # フォント
    attr_reader :font

    # ページサイズを計算する
    # size :: ページサイズ。page_layout が nil の場合、実部が横幅。虚部が縦幅。
    # page_layout :: :landscape または :portrait または nil
    def adjust_layout(size, page_layout)
      s,l = size.rectangular.minmax
      case page_layout
      when :landscape
        l+s*1i
      when :portrait
        s+l*1i
      when nil
        size
      else
        raise Errors::InvalidPageLayout, "#{@page_layout.inspect} is not supported page_layout"
      end
    end

    # 紙のサイズを示す入力を、紙のサイズを示す複素数に変換する
    # page_size :: "A4" だったり "200x300" だったり [100,200] だったりするもの
    # page_layout :: :landscape または :portrait または nil
    def parse_papersize( page_size, page_layout )
      case page_size
      when /^[AB]\d+$/
        s = PAPER_SIZES[page_size.to_sym]
        raise Errors::InvalidPageSize, "#{page_size.inspect} is not supported paper size" unless s
        adjust_layout(s, page_layout)
      when /^([0-9]+(?:\.[0-9]*)?)[^0-9\.]+([0-9]+(?:\.[0-9]*)?)/
        w, h = [$1,$2].map(&:to_f)
        adjust_layout(w + h * 1.0i, page_layout)
      when Array
        w, h = page_size
        adjust_layout(w + h * 1.0i, page_layout)
      else
        raise Errors::InvalidPageSize, "unexpected size : #{page_size}"
      end
    end

    # ページの幅
    def w
      size.real
    end

    # ページの高さ
    def h
      size.imag
    end

    # チャートを追加する
    def add_chart( chart )
      @charts.push chart
    end
  end
end
