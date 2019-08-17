# frozen_string_literal: true

module Charma

  # チャート全体の領域に名前をつけたもの
  Areas = Struct.new(
    :title,
    :x_title,
    :x_ticks,
    :x_marks,
    :y_title,
    :y_ticks,
    :y_marks,
    :chart,
    :y2_ticks,
    :y2_title,
    :y2_marks,
    :legend
  )

  # チャートを描画するロジックの共通部分
  class ChartRenderer

    # チャートを描画するオブジェクトを生成する
    # @param [Object] chart チャートに関する情報
    # @param [PDFCanvas, SVGCanvas] canvas チャートの描画ターゲット。
    # @param [Rect] area チャートが占める領域。Rect 型。
    def initialize( chart, canvas, area )
      @chart = chart
      @canvas = canvas
      @area = area
      prepare_areas
    end

    # 軸に応じたスケーリングの種類を返す
    # @param [Symbol] axis 軸。 :x, :y, :y2 のいずれか
    # @return [Symbol] :linear または :log10
    def scale_type(axis)
      case axis
      when :x
        @chart[:x_scale] || :linear
      when :y
        @chart[:y_scale] || :linear
      when :y2
        @chart[:y2_scale] || :linear
      else
        raise Errors::LogicError, "unexpected axis: #{axis.inspect}"
      end
    end

    # 対数グラフに対応するために、生の値からスケール変更済みの値を求める
    # @param [Symbol] axis 軸。:y, :y2, :x のいずれか
    # @param [Numeric] v 生の値。
    # @return [Numeric] スケール変更済みの値
    def scale_value(axis, v)
      case scale_type(axis)
      when :log10
        Math.log10(v)
      when :linear
        v
      else
        raise Errors::LogicError, "unexpected scale type: #{scale_type(axis).inspect}"
      end
    end

    # 対数グラフに対応するために、スケール変更済みの値から生の値を求める
    # @param [Symbol] axis 軸。:y, :y2, :x のいずれか
    # @param [Numeric] v スケール変更済みの値
    # @return [Nmeric] スケール変更前の値
    def unscale_value( axis, v )
      case scale_type(axis)
      when :log10
        10**v
      when :linear
        v
      else
        raise Errors::LogicError, "unexpected scale type: #{scale_type(axis).inspect}"
      end
    end

    # グリッドのために適当に切りの良い値を求める
    def tick_unit(v)
      base = (10**Math.log10(v).round).to_f
      [
        base, base/2, base/2.5, base/5,
        base/10, base/20, base/25, base/50,
      ].find{ |u| 5<v/u }
    end

    # グリッドに使う値のリストを求める
    # @param [Symbol] axis 軸。:x, :y, :y2 のいずれか
    # @param [Array<Numeric>] range その軸で扱う値の範囲
    # @return [Array<Numeric>] グリッドで使う値のリスト
    def tick_values(axis, range)
      min, max = range.minmax.map{ |e| scale_value( axis, e ) }
      unit = tick_unit(max - min)
      i_low = (min / unit).ceil
      i_hi = (max / unit).floor
      (i_low..i_hi).map{ |i| unscale_value( axis, i*unit ) }
    end

    # y軸の値ラベル( y_ticks )を描画する
    # @param [Rect] area y_ticks を描画する領域
    # @param [Array<Numeric>] ticks y_ticks に描画する値のリスト
    def draw_y_ticks(axis, area, range, ticks)
      h = (area.h / ticks.size) * 0.7
      rects = ticks.map{ |v|
        abs_y = abs_y_position(axis, v, area, range )
        Rect.new( area.x+area.w*0.1, abs_y - h/2, area.w*0.8, h )
      }
      n = (3..20).find{ |w| ticks.map{ |e| "%*g" % [w,e] }.uniq.size == ticks.size }
      texts = ticks.map{ |v| "%*g " % [ n, v ] }
      @canvas.draw_samesize_texts( rects, texts, align: :right )
    end

    # y軸の値ラベル( x_ticks )を描画する
    # @param [Rect] area x_ticks を描画する領域
    # @param [Array<Numeric>] ticks x_ticks に描画する値のリスト
    def draw_x_ticks(area, range, ticks)
      w = (area.w / ticks.size) * 0.7
      rects = ticks.map{ |v|
        abs_x = abs_x_position( v, area, range )
        Rect.new( abs_x - w/2, area.y+area.h*0.1, w, area.h*0.8 )
      }
      n = (3..20).find{ |w| ticks.map{ |e| "%*g" % [w,e] }.uniq.size == ticks.size }
      texts = ticks.map{ |v| "%*g " % [ n, v ] }
      @canvas.draw_samesize_texts( rects, texts, align: :center )
    end

    # チャート内の水平線を描画する
    # @param [Rect] area チャートの領域
    # @param [Array<Numeric>] range y の値の範囲
    # @param [Array<Numeric>] ticks 横線を描画する値のリスト
    # @note y==0 の場合は実線、それ以外は点線を描画する
    def draw_y_grid(axis, area, range, ticks)
      zero_set = [ :solid, "000" ]
      nonzero_set = [ :dash, "888" ]
      ticks.each do |v|
        s, c = v.zero? ? zero_set : nonzero_set
        abs_y = abs_y_position(axis, v, area, range )
        @canvas.horizontal_line(area.x, area.right, abs_y, style:s, color:c, color2:nil)
      end
    end

    # チャート内の垂直線を描画する
    # @param [Rect] area チャートの領域
    # @param [Array<Numeric>] range x の値の範囲
    # @param [Array<Numeric>] ticks 横線を描画する値のリスト
    # @note x==0 の場合は実線、それ以外は点線を描画する
    def draw_x_grid(area, range, ticks)
      zero_set = [ :solid, "000" ]
      nonzero_set = [ :dash, "888" ]
      ticks.each do |v|
        s, c = v.zero? ? zero_set : nonzero_set
        abs_x = abs_x_position( v, area, range )
        @canvas.vertical_line(area.y, area.bottom, abs_x, style:s, color:c, color2:nil)
      end
    end

    # チャートの左右の縁にある短い水平線(マーク)を描画する
    # @param [Rect] area マークの領域
    # @param [Array<Numeric>] range y の値の範囲
    # @param [Array<Numeric>] ticks マークを描画する値のリスト
    def draw_y_marks(axis, area, range, ticks)
      opts = {style: :solid, color:"000"}
      ticks.each do |v|
        abs_y = abs_y_position(axis, v, area, range )
        @canvas.horizontal_line(area.x, area.right, abs_y, **opts)
      end
    end

    # チャートの下の縁にある短い垂直線(マーク)を描画する
    # @param [Rect] area チャートの領域
    # @param [Array<Numeric>] range x の値の範囲
    # @param [Array<Numeric>] ticks 横線を描画する値のリスト
    def draw_x_marks(area, range, ticks)
      opts = {style: :solid, color:"000"}
      ticks.each do |v|
        abs_x = abs_x_position( v, area, range )
        @canvas.vertical_line(area.y, area.bottom, abs_x, **opts)
      end
    end

    # 色のリストをつくる
    # @param [Integer] n 作る色の数
    # @note n<=6 の場合は、固定の色のリストから取ってくる。7<=n の場合は虹色っぽく適当に作る。
    # @return [Array<String>] 色を表す文字列のリスト
    def seq_colors(n)
      case n
      when 1..6
        %w(00f f00 008000 f0f 0cc aa0)[0,n]
      else
        f = lambda{ |t0|
          v = lambda{ |t|
            case t
            when 0..1 then t
            when 1..2 then 2-t
            else 0
            end
          }[t0 % 3]
          "%02x" % (v**0.5*255).round
        }
        Array.new(n){ |i|
          t = i*3.0/n+2
          [f[t],f[t+1],f[t+2]].join
        }
      end
    end

    # 相対位置から絶対位置に変換する
    # @param [Numeric] v 変換される相対位置
    # @param [Rect] rc 領域。左端が xrange[0] ,右端が xrange[1] に対応する。
    # @param [Array<Numeric>] xrange 値の範囲
    # @return [Numeric] 引数 v に対応する絶対位置
    def abs_x_position(v, rc, xrange)
      rx, min, max = [ v, *xrange ].map{ |e| scale_value(:x, e) }
      (rx-min) * rc.w / (max-min) + rc.x
    end

    # 相対位置から絶対位置に変換する
    # @param [Symbol] v の軸。:y または :y2
    # @param [Numeric] v 変換される相対位置
    # @param [Rect] rc 領域。上端が yrange[0] ,下端が yrange[1] に対応する。
    # @param [Array<Numeric>] yrange 値の範囲
    # @return [Numeric] 引数 v に対応する絶対位置
    def abs_y_position(axis, v, rc, yrange)
      ry, min, max = [ v, *yrange ].map{ |e| scale_value(axis, e) }
      (max-ry) * rc.h / (max-min) + rc.y
    end

    # 下端に legend があるかどうか
    # @note 系列が複数あり、すべての系列に名前がついていれば 真
    # @return [Boolean] 下端に legend があるかどうか
    def bottom_legend?
      1 < @chart[:series].size && @chart[:series].all?{ |e| ! e[:name].nil? }
    end

    # 領域を分割し、 @areas に格納する
    def prepare_areas
      a = @areas = Areas.new
      title_h = @chart[:title] ? 1 : 0
      main_h = 10
      legend_h = bottom_legend? ? 1 : 0
      a.title, main, bottom = @area.vsplit( title_h, main_h, legend_h )
      left0_w = @chart[:y_title] ? 1 : 0
      left1_w = 1
      right1_w = @chart.y2? ? 1 : 0
      mark_w = 0.15
      right_mark_w = @chart.y2? ? mark_w : 0
      right0_w = @chart[:y2_title] ? 1 : 0
      hsplit_ratio = [left0_w, left1_w, mark_w, 10, right_mark_w, right1_w, right0_w]
      left0, left1, left2, center, right2, right1, right0 =
        main.hsplit( *hsplit_ratio )
      _, _, _, a.legend, =
        bottom.hsplit( *hsplit_ratio )
      chart_h = 10
      x_tick_h = x_ticks_area? ? 0.7 : 0
      x_marks_h = x_marks_area? ? 0.15 : 0
      x_title_h = @chart[:x_title] ? 1 : 0
      vsplit_ratio = [chart_h, x_marks_h, x_tick_h, x_title_h]
      a.y_title, = left0.vsplit( *vsplit_ratio )
      a.y_ticks, = left1.vsplit( *vsplit_ratio )
      a.y_marks, = left2.vsplit( *vsplit_ratio )
      a.chart, a.x_marks, a.x_ticks, a.x_title = center.vsplit( *vsplit_ratio )
      a.y2_ticks, = right1.vsplit( *vsplit_ratio )
      a.y2_title, = right0.vsplit( *vsplit_ratio )
      a.y2_marks, = right2.vsplit( *vsplit_ratio )
    end

    # x_ticks を描画する
    # @params [Rect] area x_ticks に使える領域
    # @params [Array<String>] texts x_ticks に描画する文字列のリスト
    def draw_x_tick_texts( area, texts )
      rects = area.hsplit( *([1]*texts.size) ).map{ |rc|
        rc.hsplit(1,10,1)[1]
      }
      @canvas.draw_samesize_texts( rects, texts, align: :center )
    end

    # 下端に legend を描画する
    # @param [Rect] area legend を描画する領域
    # @param [Array<String>] names 凡例の各要素のテキスト
    # @param [Array<String>] colors 凡例の各要素の色
    def draw_bottom_regend(area, names, colors)
      ratio = [5,0.5,10,2]
      xcount = (1..names.size).max_by{ |w|
        h = ( names.size.to_r / w.to_r ).ceil
        cw = area.w.to_f / w * ratio[2] / ratio.sum
        ch = area.h.to_f / h
        rects = [ Rect.new( 0, 0, cw, ch ) ]*names.size
        @canvas.measure_samesize_texts( rects, names )
      }
      ycount = ( names.size.to_r / xcount.to_r ).ceil
      rects = area.vsplit( *Array.new(ycount, 1) ).map{ |rc|
        rc.hsplit( *Array.new(xcount, 1) )
      }.flatten[0,names.size]
      left_rects, _, text_rects, = rects.map{ |e| e.hsplit(*ratio) }.transpose
      bar_rects = left_rects.map{ |e| e.vsplit(1,1,1)[1] }
      bar_rects.zip(colors).each do |rc, col|
        @canvas.fill_rect( rc, col )
      end
      @canvas.draw_samesize_texts( text_rects, names, align: :left )
    end

    # タイトルを描画する
    # グラフタイトル、x軸タイトル、y軸タイトル、第二y軸タイトル を描画する（必要なら）
    def render_titles
      @canvas.text( @chart[:title], @areas.title ) if @chart[:title]
      @canvas.text( @chart[:x_title], @areas.x_title ) if @chart[:x_title]
      @canvas.rottext( @chart[:y_title], @areas.y_title, 90 ) if @chart[:y_title]
      @canvas.rottext( @chart[:y2_title], @areas.y2_title, 270 ) if @chart[:y2_title]
    end

    # 何もかも描画する
    def render
      render_titles
      render_chart
    end
  end
end
