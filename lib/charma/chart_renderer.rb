# frozen_string_literal: true

module Charma
  Areas = Struct.new(
    :title,
    :x_title,
    :x_ticks,
    :y_title,
    :y_ticks,
    :chart,
    :y2_ticks,
    :y2_title,
    :legend
  )

  class ChartRenderer
    def initialize( chart, canvas, area )
      @chart = chart
      @canvas = canvas
      @area = area
      prepare_areas
    end

    def scale_value(axis, v)
      v
      # TODO: refer scale
      # case scale_type(axis)
      # when :log10
      #   Math.log10(v)
      # else
      #   v
      # end
    end

    def unscale_value( axis, v )
      v
      # TODO: refer scale
    end

    def tick_unit(v)
      base = (10**Math.log10(v).round).to_f
      man = v/base
      return 0.5*base if man<0.6
      return base if man<1.2
      base*2
    end

    def tick_values(axis, range)
      min, max = range.minmax.map{ |e| scale_value( axis, e ) }
      unit = tick_unit((max - min) * 0.1)
      i_low = (min / unit).ceil
      i_hi = (max / unit).floor
      (i_low..i_hi).map{ |i| unscale_value( axis, i*unit ) }
    end

    def abs_y_positoin( v, area, range )
      ry, min, max = [ v, *yrange ].map{ |e| scale_value(:y, e) }
      (ry-min) * rc.h / (max-min) + rc.bottom
    end

    def draw_y_ticks(area, range, ticks)
      h = (area.h / ticks.size) * 0.7
      rects = ticks.map{ |v|
        abs_y = abs_y_positoin( v, area, range )
        Rect.new( area.x+area.w*0.1, abs_y - h/2, area.w*0.8, h )
      }
      n = (3..20).find{ |w| ticks.map{ |e| "%*g" % [w,e] }.uniq.size == ticks.size }
      texts = ticks.map{ |v| "%*g " % [ n, v ] }
      @canvas.draw_samesize_texts( rects, texts, align: :right )
    end

    def draw_y_grid(area, range, ticks)
      zero_set = [ :solid, "000" ]
      nonzero_set = [ :dash, "888" ]
      ticks.each do |v|
        s, c = v.zero? ? zero_set : nonzero_set
        abs_y = abs_y_positoin( v, area, range )
        @canvas.horizontal_line(area.x, area.right, abs_y, style:s, color:c, color2:nil)
      end
    end

    def seq_colors(n)
      case n
      when 1..6
        %w(00f f00 0a0 f0f fa0 0af)[0,n]
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

    def abs_x_positoin(v, rc, xrange)
      rx, min, max = [ v, *xrange ].map{ |e| scale_value(:x, e) }
      (rx-min) * rc.w / (max-min) + rc.x
    end

    def abs_y_positoin(v, rc, yrange)
      ry, min, max = [ v, *yrange ].map{ |e| scale_value(:y, e) }
      (max-ry) * rc.h / (max-min) + rc.y
    end

    def bottom_regend?
      1 < @chart[:series].size && @chart[:series].all?{ |e| ! e[:name].nil? }
    end

    def prepare_areas
      a = @areas = Areas.new
      title_h = @chart[:title] ? 1 : 0
      main_h = 10
      legend_h = bottom_regend? ? 1 : 0
      a.title, main, bottom = @area.vsplit( title_h, main_h, legend_h )
      left0_w = @chart[:y_title] ? 1 : 0
      left1_w = 1
      right1_w = @chart.has_y2? ? 1 : 0
      right0_w = @chart[:y2_title] ? 1 : 0
      left0, left1, center, right1, right0 =
        main.hsplit( left0_w, left1_w, 10, right1_w, right0_w )
      _, _, a.legend, =
        bottom.hsplit( left0_w, left1_w, 10, right1_w, right0_w )
      chart_h = 10
      x_tick_h = @chart[:x_ticks] ? 0.7 : 0
      x_title_h = @chart[:x_title] ? 1 : 0
      a.y_title, = left0.vsplit( chart_h, x_tick_h, x_title_h )
      a.y_ticks, = left1.vsplit( chart_h, x_tick_h, x_title_h )
      a.chart, a.x_ticks, a.x_title = center.vsplit( chart_h, x_tick_h, x_title_h )
      a.y2_ticks, = right1.vsplit( chart_h, x_tick_h, x_title_h )
      a.y2_title, = right0.vsplit( chart_h, x_tick_h, x_title_h )
    end

    def draw_x_ticks( area, texts )
      rects = area.hsplit( *([1]*texts.size) ).map{ |rc|
        rc.hsplit(1,10,1)[1]
      }
      @canvas.draw_samesize_texts( rects, texts, align: :center )
    end

    def draw_bottom_regend(area, names, colors)
      ratio = [10,0.5,10,2]
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

    def render_titles
      @canvas.text( @chart[:title], @areas.title ) if @chart[:title]
      @canvas.text( @chart[:x_title], @areas.x_title ) if @chart[:x_title]
      @canvas.rottext( @chart[:y_title], @areas.y_title, 90 ) if @chart[:y_title]
      @canvas.rottext( @chart[:y2_title], @areas.y_title, 270 ) if @chart[:y2_title]
    end

    def render
      render_titles
      render_chart
    end
  end
end
