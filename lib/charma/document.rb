# frozen_string_literal: true

module Charma
  # Charma Document
  class Document
    # ドキュメントを生成
    # font :: デフォルトフォント名。String。
    # page_size :: デフォルトページサイズ。"A4" のような形式か、"210x297" のような形式。あるいは [100,200] のような配列
    # page_layout :: :landscape (横長) または :portrait (縦長)。あるいは nil。
    # ブロック引数を取り、自分を引数としたブロック呼び出しになる
    def initialize(
      font:nil,
      page_size: DEFAULT_PAGE_SIZE,
      page_layout: nil,
      &block
    )
      @opts = {}
      @pages = []
      @font = font
      @page_size = page_size
      unless [ :landscape, :portrait, nil].include?(page_layout)
        raise Charma::Errors::InvalidOption, "#{page_layout.inspect} is not supported page_layout"
      end
      @page_layout = page_layout
      block[self] if block
    end

    # ページを追加する
    # @param [String, nil] page_title ページタイトル
    # @param [String, nil] font フォント名。フルパスでも、PostScript名でも、正式名でも。
    # @param [String, Array(Numeric,Numeric), nil] page_size ページサイズ。"A4" のような形式か、"210x297" のような形式。あるいは [100,200] のような配列
    # @param [Symbol, nil] page_layout :landscape (横長) または :portrait (縦長)。あるいは nil。
    # @param [String, nil] note ページ下部のノート
    # ブロック引数を取り、作られたページを引数としたブロック呼び出しになる。
    # @return [Page] つくられたページ
    def add_page(
      page_title:nil,
      font:nil,
      page_size:nil,
      page_layout:nil,
      note:nil,
      &block
    )
      font ||= @font
      page_size ||= @page_size
      page = Page.new(
        page_title: page_title,
        font:(font||@font),
        page_size:(page_size||@page_size),
        page_layout:(page_layout||@page_layout),
        note:note
      )
      block[page] if block
      @pages.push page
      page
    end

    # ファイル名からファイルタイプ( :pdf または :svg )を得る。
    # filename :: ファイル名。
    def filetype_from( filename )
      ext = File.extname(filename)
      case ext.downcase
      when ".pdf"
        :pdf
      when ".svg"
        :svg
      else
        raise Errors::InvalidFileType, "#{ext} is not supported filetype"
      end
    end

    # ファイルタイプに応じたレンダラを返す
    # ft :: :pdf または :svg。
    def renderer_for( ft )
      case ft
      when :pdf
        PDFRenderer
      when :svg
        SVGRenderer
      else
        raise Errors::InvalidFileType, "#{ft.inspect} is not supported type"
      end
    end

    # PDFまたはSVGを出力する。
    def render( filename, file_type:nil )
      if @pages.empty?
        raise Errors::NothingToRender, "No page to render"
      end
      t = renderer_for( file_type || filetype_from(filename))
      t.new(@pages, @opts).render(filename)
    end
  end
end
