# frozen_string_literal: true

module Charma
  class BarChart < Chart
    def initialize(opts)
      @opts = opts
      @opts[:colors] ||= colors(@opts[:y_values].size)
    end

    def draw_bar(pdf, rect, y, col)
      ratio = 0.75
      bar = Rect.new(
        rect.x + rect.w*(1-ratio)/2,
        y.max,
        rect.w*ratio,
        y.max - y.min )
      fill_rect( pdf, bar, col )
    end

    def abs_y_positoin(v, rc, yrange)
      (v-yrange[0]) * rc.h / (yrange[1]-yrange[0]) + rc.bottom
    end

    def render_chart(pdf, rect, yrange)
      stroke_rect(pdf, rect)
      y_values = @opts[:y_values].map(&:to_f)
      bar_areas = rect.hsplit(*Array.new(y_values.size){1})
      f = lambda{|v, rc|
        abs_y_positoin( v, rc, yrange)
      }
      y_values.zip(bar_areas, @opts[:colors]).each do |v, rc, col|
        draw_bar(pdf, rc, [f[v,rc], f[0,rc]], col)
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

    def render_yticks(pdf, area, yrange, values)
      h = (area.h / values.size) * 0.7
      rects = values.map{ |v|
        abs_y = abs_y_positoin( v, area, yrange )
        Rect.new( area.x, abs_y + h/2, area.w*0.9, h )
      }
      svalues = values.map{ |v| "%g " % v }
      draw_samesize_texts( pdf, rects, svalues, align: :right )
    end

    def render_y_grid(pdf, area, yrange, values)
      pdf.save_graphics_state do
        pdf.line_width = 0.5
        values.each do |v|
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
      ymin = [0, @opts[:y_values].min * 1.1].min
      ymax = [0, @opts[:y_values].max * 1.1].max
      yrange = @opts[:y_range] || [ymin, ymax]
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
