# frozen_string_literal: true

module Charma
  class BarChart < Chart
    def initialize(opts)
      super(opts)
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

    def bar_range
      ymin = [0, values(:y).flatten.min * 1.1].min
      ymax = [0, values(:y).flatten.max * 1.1].max
      [ ymin, ymax ]
    end

    def render( pdf, rect )
      title_text = @opts[:title]
      title, main, ticks, bottom = rect.vsplit(
        (title_text ? 1 : 0),
        7,
        (@opts[:x_ticks] ? 0.5 : 0),
        (bottom_legend? ? 0.5 : 0))
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
      yvalues = tick_values(:y, yrange)
      render_yticks(pdf, yticks, yrange, yvalues)
      render_y_grid(pdf, chart, yrange, yvalues)
      render_legend(pdf, bottom) if bottom_legend?
    end
  end
end
