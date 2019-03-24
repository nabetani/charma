# frozen_string_literal: true

module Charma
  class BarChart < Chart
    def initialize(opts)
      @opts = opts
    end

    def draw_bar(pdf, rect, yrange, ys, cols)
      ratio = 0.75
      _, bars, = rect.hsplit( (1-ratio)/2, ratio, (1-ratio)/2 )
      bar_rects = bars.hsplit(*Array.new(ys.size,1))
      bar_rects.zip(ys, cols) do |bar, y, col|
        ay = abs_y_positoin(y, bar, yrange)
        zero = abs_y_positoin(0, bar, yrange)
        b, t = [ ay, zero ].minmax
        rc = Rect.new( bar.x, t, bar.w, (t-b) )
        fill_rect( pdf, rc, col )
      end
    end

    def render_chart(pdf, rect, yrange)
      stroke_rect(pdf, rect)
      y_values = values(:y).transpose
      bar_areas = rect.hsplit(*Array.new(y_values.size,1))
      cols = if y_values.first.size==1
        colors(y_values.size).map{ |e| [e] }
      else
        [colors(y_values.first.size)] * y_values.size
      end
      y_values.zip(bar_areas, cols).each do |ys, rc, c|
        draw_bar(pdf, rc, yrange, ys, c)
      end
    end

    def render_xticks(pdf, area)
      rects = area.hsplit(*Array.new(@opts[:x_ticks].size){ 1 }).map{ |rc0|
        rc0.hsplit(1,8,1)[1]
      }
      draw_samesize_texts( pdf, rects, @opts[:x_ticks], valign: :top )
    end

    def tick_unit(v)
      base = (10**Math.log10(v).round).to_f
      man = v/base
      return 0.5*base if man<0.6
      return base if man<1.2
      base*2
    end

    def ytick_values(yrange)
      unit = tick_unit((yrange.max - yrange.min) * 0.1)
      i_low = (yrange.min / unit).ceil
      i_hi = (yrange.max / unit).floor
      (i_low..i_hi).map{ |i| i*unit }
    end

    def render_yticks(pdf, area, yrange, yvalues)
      h = (area.h / yvalues.size) * 0.7
      rects = yvalues.map{ |v|
        abs_y = abs_y_positoin( v, area, yrange )
        Rect.new( area.x, abs_y + h/2, area.w*0.9, h )
      }
      svalues = yvalues.map{ |v| "%g " % v }
      draw_samesize_texts( pdf, rects, svalues, align: :right )
    end

    def render_y_grid(pdf, area, yrange, yvalues)
      pdf.save_graphics_state do
        pdf.line_width = 0.5
        yvalues.each do |v|
          if v==0
            pdf.stroke_color "000000"
            pdf.undash
          else
            pdf.stroke_color "888888"
            pdf.dash([2,2])
          end
          abs_y = abs_y_positoin( v, area, yrange )
          pdf.stroke_horizontal_line area.x, area.right, at: abs_y
        end
      end
    end

    def bar_range
      ymin = [0, values(:y).flatten.min * 1.1].min
      ymax = [0, values(:y).flatten.max * 1.1].max
      [ ymin, ymax ]
    end

    def render( pdf, rect )
      stroke_rect(pdf, rect)
      title_text = @opts[:title]
      title, main, ticks = rect.vsplit(
        (title_text ? 1 : 0),
        7, 
        (@opts[:x_ticks] ? 0.5 : 0))
      draw_text( pdf, title, title_text ) if title_text
      hratio = [(@opts[:y_label] ? 1 : 0), 1, 10]
      ylabel, yticks, chart = main.hsplit(*hratio)
      yrange = @opts[:y_range] || bar_range
      render_chart(pdf, chart, yrange)
      if @opts[:y_label]
        render_rottext(pdf, ylabel, @opts[:y_label] )
      end
      if @opts[:x_ticks]
        _, _, xticks = ticks.hsplit(*hratio)
        render_xticks(pdf, xticks)
      end
      yvalues = ytick_values(yrange)
      render_yticks(pdf, yticks, yrange, yvalues)
      render_y_grid(pdf, chart, yrange, yvalues)
    end
  end
end
