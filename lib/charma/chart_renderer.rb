# frozen_string_literal: true

module Charma
  Areas = Struct.new(
    :title,
    :x_title,
    :x_tick,
    :y_title,
    :y_tick,
    :chart,
    :y2_tick,
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
      ticks.each do |v|
        abs_y = abs_y_positoin( v, area, range )
        c = v.zero? ? "000" : "aaa"
        @canvas.horizontal_line(area.x, area.right, abs_y, color:c )
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

    def prepare_areas
      a = @areas = Areas.new
      title_h = @chart[:title] ? 1 : 0
      main_h = 10
      legend_h = 1
      a.title, main, a.legend = @area.vsplit( title_h, main_h, legend_h )
      left0_w = @chart[:y_title] ? 1 : 0
      left1_w = 1
      right1_w = @chart.has_y2? ? 1 : 0
      right0_w = @chart[:y2_title] ? 1 : 0
      left0, left1, center, right1, right0 =
        main.hsplit( left0_w, left1_w, 10, right1_w, right0_w )
      chart_h = 10
      x_tick_h = 0.7
      x_title_h = @chart[:x_title] ? 1 : 0
      a.y_title, = left0.vsplit( chart_h, x_tick_h, x_title_h )
      a.y_tick, = left1.vsplit( chart_h, x_tick_h, x_title_h )
      a.chart, a.x_tick, a.x_title = center.vsplit( chart_h, x_tick_h, x_title_h )
      a.y2_tick, = right1.vsplit( chart_h, x_tick_h, x_title_h )
      a.y2_title, = right0.vsplit( chart_h, x_tick_h, x_title_h )
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
