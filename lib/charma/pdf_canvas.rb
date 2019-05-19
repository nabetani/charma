# frozen_string_literal: true

module Charma
  # prawn を使って PDF に描画するためのクラス
  class PDFCanvas

    # PDFCanvas を構築する
    # pdf :: Prawn::Document 型の、描画ターゲット
    def initialize( pdf )
      @pdf = pdf
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
    # t :: 描画する文字列
    # rect :: この矩形内に文字列を描画する
    # opts :: オプション
    # opts[:font_size] フォントサイズ
    # opts[:align] 左右のアライメント。:left, :right, :center のいずれか
    # opts[:valign] 左右のアライメント。:top, :bottom, :center のいずれか
    def text( t, rect, opts = {} )
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

    # テキストのサイズを計算する
    # rects :: この矩形に入るサイズを計算する
    # texts :: このテキストを描画できるサイズを計算する
    # rects[i] の中に texts[i] が描画できるサイズを返す
    def measure_samesize_texts( rects, texts )
      texts.zip(rects).map{ |txt,rc|
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
