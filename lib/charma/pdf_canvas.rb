# frozen_string_literal: true

require 'ttfunk'

module Charma
  # prawn を使って PDF に描画するためのクラス
  class PDFCanvas

    # PDFCanvas を構築する
    # pdf :: Prawn::Document 型の、描画ターゲット
    def initialize( pdf )
      @pdf = pdf
    end

    def utf8_text(name)
      # see https://docs.microsoft.com/en-us/typography/opentype/spec/name
      # see 
      key = [name.platform_id, name.encoding_id, name.language_id ].join("_")
      # TODO: 文字コードの指定が不十分と思われる
      r=case key
      when /^0_0_/ # Unicode, Unicode 1.0, n/a
        name.force_encoding( "UTF-16BE" )
      when /^0_3_/ # Unicode, Unicode BMP, n/a
        name.force_encoding( "UTF-16BE" )
      when "1_0_0" # Macintosh, Roman, English
        name.force_encoding( "utf-8" )
      when "1_0_1041" # Macintosh, Roman, unknown
        name.force_encoding( "utf-8" )
      when "1_1_11" # Macintosh, Japanese, Japanese
        name.force_encoding( "cp932" )
      when "1_3_23" # Macintosh, Korean, Korean
        name.force_encoding( "utf-8" )
      when "3_0_1033" # Windows, Symbol, English(US)
        name.force_encoding( "utf-8" )
      when /^3_10_/ # Windows, Unicode full repertoire, any
        name.force_encoding( "utf-8" )
      when /^3_1_/ # Windows, Unicode BMP, *
        name.force_encoding( "UTF-16BE" )
      else
        raise "unknown key #{key}" # TODO: 投げない
      end
      begin
        r.encode("utf-8")
      rescue Encoding::InvalidByteSequenceError=>e
        # ignore error
        r
      end
    end

    def font=(name)
      return unless name
      if File.extname(name).downcase==".ttf" && File.exist?(File.expand_path(name))
        @pdf.font(File.expand_path(name))
        return
      end
      # TODO: 検索結果をキャッシュする
      systemroot = ENV["SystemRoot"]
      [ "/Library/Fonts/*.ttf", 
        File.expand_path("~/Library/Fonts/*.ttf"),
        "/System/Library/Fonts/*.ttf",
        systemroot && File.join( systemroot, "Fonts/*.ttf" ),
        File.expand_path("~/AppData/Local/Microsoft/Windows/Fonts/*.ttf"),
      ].compact.each do |pat0|
        pat = pat0.gsub( "\\", "/" )
        Dir.glob(pat) do |fn|
          file = TTFunk::File.open(fn)
          if file.name.font_name.any?{ |n| utf8_text(n)==name.encode("utf-8") }
            @pdf.font(fn)
            return
          end
        end
      end
      raise Charma::Errors::LogicError, "failed to find font named #{name}" # ちゃんとする
    end

    # ページ全体(余白除く)の矩形を返す
    def page_rect
      mb = @pdf.margin_box
      Rect.new(mb.left, mb.height - mb.top, mb.width, mb.height)
    end

    # y座標を普通の座標系から PDF座標系に変換する
    def pdf_y( y )
      mb = @pdf.margin_box
      mb.top - y
    end

    def pdf_points(points)
      top = @pdf.margin_box.top
      points.map{ |x,y|
        [x, top-y]
      }
    end

    # 矩形を普通の座標系から PDF座標系に変換する
    def pdf_rect( rc )
      mb = @pdf.margin_box
      Rect.new(
        rc.x,
        mb.top - rc.y - rc.h,
        rc.w, rc.h
      )
    end

    # 回転したテキストを描画する
    # t :: 描画する文字列
    # rect :: この矩形内に文字列を描画する
    # angle :: 回転角。90 または 270。
    def rottext( t, rect, angle )
      pr = pdf_rect(rect).rot
      @pdf.rotate(angle, origin: pr.center) do
        w = @pdf.width_of(t, size:1)
        h = @pdf.height_of(t, size:1)
        font_size = [pr.w.to_f/w ,pr.h.to_f/h].min
        # TODO: bounding box の描画を撤去する
        @pdf.bounding_box([pr.x, pr.bottom], width:pr.w, height:pr.h ) do
          @pdf.transparent(1) { @pdf.stroke_bounds }
        end
        @pdf.text_box(
          t,
          at: [pr.x, pr.bottom],
          width: pr.w,
          height: pr.h,
          align: :center,
          valign: :center,
            size:font_size )
      end
    end

    # テキストを描画する
    # @param [String] t 描画する文字列
    # @param [Rect] rect この矩形内に文字列を描画する
    # @option opts [Numeric] :font_size フォントサイズ
    # @option opts [Symbol] :align 左右のアライメント。:left, :right, :center のいずれか
    # @option opts [Symbol] :valign 上下のアライメント。:left, :right, :center のいずれか
    def text( t0, rect, opts = {} )
      t = t0.to_s
      pr = pdf_rect(rect)
      w = @pdf.width_of(t, size:1)
      h = @pdf.height_of(t, size:1)
      font_size = opts[:font_size] || [pr.w.to_f/w, pr.h.to_f/h].min * 0.95

      # TODO: remove bounding box
      @pdf.bounding_box([pr.x, pr.bottom], width:pr.w, height:pr.h ) do
        @pdf.transparent(1) { @pdf.stroke_bounds }
      end

      @pdf.text_box(
        t,
        at:[pr.x, pr.bottom],
        width:pr.w,
        height:pr.h,
        align: opts[:align] || :center,
        valign: opts[:valign] || :center,
        size:font_size
      )
    end

    # canvas の色をPDFの色に変換する
    # color :: 色。3文字の文字列(16進数でRGB)または6文字の文字列(16進数でRRGGBB)。
    def pdf_color(color)
      case color.size
      when 3
        (0..2).map{ |x| color[x]*2 }.join
      when 6
        color
      else
        raise "#{color.inspect} is not expected color format"
      end
    end

    # 折れ線を描画する
    # @param [Array<Array<Numeric>>] pts x, y 値の配列。
    # @param [Numeric] width 線の幅
    # @param [String] color 線の色
    def polyline( pts0, width, color )
      pts = pdf_points(pts0)
      @pdf.save_graphics_state do
        @pdf.fill_color 0, 0, 0, 0
        @pdf.stroke_color(pdf_color(color))
        @pdf.stroke do
          @pdf.line_width = width
          @pdf.move_to(pts[0])
          (1...pts.size).each do |ix|
            @pdf.line_to(pts[ix])
          end
        end
      end
    end

    def fill_circle( cx, cy, r, color )
      @pdf.save_graphics_state do
        y = pdf_y(cy)
        @pdf.fill{
          @pdf.fill_color( pdf_color(color) )
          @pdf.circle( [cx,y], r )
        }
      end
    end

    # 矩形をフィルする
    # rect :: この矩形をフィルする
    # color :: この色でフィルする
    def fill_rect( rect, color )
      @pdf.save_graphics_state do
        pr = pdf_rect(rect)
        @pdf.fill{
          @pdf.fill_color( pdf_color(color) )
          @pdf.rectangle( [pr.x, pr.bottom], pr.w, pr.h )
        }
      end
    end

    # 矩形の枠を書く
    # rect :: この矩形の枠を書く
    def stroke_rect(rect)
      @pdf.save_graphics_state do
        pr = pdf_rect(rect)
        @pdf.stroke{
          @pdf.rectangle( [pr.x, pr.bottom], pr.w, pr.h )
        }
      end
    end

    def stroke_polygon(points, color:"000", width:nil)
      @pdf.save_graphics_state do
        @pdf.stroke{
          @pdf.line_width( width ) if width
          @pdf.stroke_color( pdf_color(color) )
          @pdf.polygon(*pdf_points(points))
        }
      end
    end

    # 多角形を fill する
    # @param points [Array] 点列。[[x0,y0],[x1,y1],...]
    # @param color [String] 色
    def fill_polygon(points, color)
      @pdf.save_graphics_state do
        @pdf.fill{
          @pdf.fill_color( pdf_color(color) )
          @pdf.polygon(*pdf_points(points))
        }
      end
    end

    # テキストのサイズを計算する
    # rects :: この矩形に入るサイズを計算する
    # texts :: このテキストを描画できるサイズを計算する
    # rects[i] の中に texts[i] が描画できるサイズを返す
    def measure_samesize_texts( rects, texts )
      texts.map(&:to_s).zip(rects).map{ |txt,rc|
        w = @pdf.width_of(txt, size:1)
        h = @pdf.height_of(txt, size:1)
        [rc.w.to_f/w, rc.h.to_f/h].min
      }.min*0.95 # "*0.95" しないと次の行を描画しようと上付きになることがある
    end

    # 複数の矩形と文字列を指定して、同じ大きさの文字を各矩形に描画する
    # rects :: 矩形のリスト
    # texts :: 文字列のリスト
    # align :: テキストアライメント
    def draw_samesize_texts( rects, texts, align: :center )
      @pdf.save_graphics_state do
        size = measure_samesize_texts( rects, texts )
        texts.zip(rects).each do |txt, rc|
          text( txt, rc, font_size:size, align:align )
        end
      end
    end

    def vertical_line( top, bottom, x, style: :solid, color:"000", color2:"fff" )
      @pdf.save_graphics_state do
        case style
        when :solid
          unless color.nil?
            @pdf.stroke_color pdf_color(color)
            @pdf.stroke_vertical_line(pdf_y(top), pdf_y(bottom), at:x)
          end
        when :dash
          unless color.nil?
            @pdf.dash([2,2])
            @pdf.stroke_color pdf_color(color)
            @pdf.stroke_vertical_line(pdf_y(top), pdf_y(bottom), at:x)
          end
          unless color2.nil?
            @pdf.dash([2,2], phase:2)
            @pdf.stroke_color pdf_color(color2)
            @pdf.stroke_vertical_line(pdf_y(top), pdf_y(bottom), at:x)
          end
        else
          raise Errors::InternalError, "unexpected line style: #{style.inspect}"
        end
      end
    end

    # 水平線を描画する
    # left :: 左端
    # right :: 右端
    # y :: y座標
    # style :: 線のスタイル。:solid または :dash
    # color :: 線の色。
    # color2 :: style が dash の場合に使われる第二の色
    def horizontal_line( left, right, y, style: :solid, color:"000", color2:nil )
      @pdf.save_graphics_state do
        case style
        when :solid
          unless color.nil?
            @pdf.stroke_color pdf_color(color)
            @pdf.stroke_horizontal_line(left, right, at:pdf_y(y))
          end
        when :dash
          unless color.nil?
            @pdf.dash([2,2])
            @pdf.stroke_color pdf_color(color)
            @pdf.stroke_horizontal_line(left, right, at:pdf_y(y))
          end
          unless color2.nil?
            @pdf.dash([2,2], phase:2)
            @pdf.stroke_color pdf_color(color2)
            @pdf.stroke_horizontal_line(left, right, at:pdf_y(y))
          end
        else
          raise Errors::InternalError, "unexpected line style: #{style.inspect}"
        end
      end
    end
  end
end
