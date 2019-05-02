# frozen_string_literal: true

module Charma
  # Charma Document
  class Document
    # ドキュメントを生成
    # @param [String] font デフォルトフォント名。
    # @param [String] page_size デフォルトページサイズ。"A4" のような形式か、"210x297" のような形式。
    # @param [Symbol] page_layout :landscape (横長) または :portlait (縦長)。
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
      unless [ :landscape, :portlait, nil].include?(page_layout)
        raise Charma::Errors::InvalidOption, "#{page_layout.inspect} is not supported page_layout"
      end
      @page_layout = page_layout
      block[self] if block
    end

    # ページを追加
    def add_page(
      font:nil,
      page_size:nil,
      page_layout:nil,
      &block
    )
      font ||= @font
      page_size ||= @page_size
      page = Page.new(
        font:(font||@font),
        page_size:(page_size||@page_size),
        page_layout:(page_layout||@page_layout) )
      block[page] if block
      @pages.push page
      page
    end

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

    def render( filename, file_type:nil )
      if @pages.empty?
        raise Errors::NothingToRender, "No page to render"
      end
      t = renderer_for( file_type || filetype_from(filename))
      t.new(@pages, @opts).render(filename)
    end
  end
end
