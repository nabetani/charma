# frozen_string_literal: true

module Charma
  class LineChart < Chart
    def initialize(opts)
      super(opts)
    end

    def scaled_values(sym)
      @opts[:series].map{ |e|
        v = e[sym]
        if v
          e[sym].map{ |v| scale_value(sym, v) }
        else
          (1..e[:y].size).map(&:to_f)
        end
      }
    end

    def calc_range( sym )
      r0 = scaled_values(sym).flatten.minmax
      dist = r0[1] - r0[0]
      delta = dist==0 ? 1 : dist*0.1
      raw_range =
        if 0<=r0[0]
          [[r0[0]-delta, 0].max, r0[1]+delta]
        else
          [r0[0]-delta, r0[1]+delta]
        end
      raw_range.map{ |e| unscale_value( sym, e ) }
    end

    def render_series( pdf, rect, xrange, yrange, s)
      xs = s[:x] || [*1..s[:y].size]
      ys = s[:y]
      points = xs.zip(ys).map{ |x,y|
        [
          abs_x_positoin( x, rect, xrange ),
          abs_y_positoin( y, rect, yrange )
        ]
      }
      pdf.stroke do
        pdf.move_to( *points.first )
        points.drop(1).each do |x,y|
          pdf.line_to(x,y)
        end
      end
    end

    def render_chart(pdf, rect, xrange, yrange)
      stroke_rect(pdf, rect)
      cols = colors(@opts[:series].size)
      pdf.save_graphics_state do
        pdf.line_width( 4 )
        @opts[:series].zip(cols).each do |s, col|
          pdf.stroke_color( col )
          render_series( pdf, rect, xrange, yrange, s)
        end
      end
    end

    def has_x_ticks?
      if @opts[:x_ticks].nil?
        !! @opts[:series].first[:x]
      else
        !! @opts[:x_ticks]
      end
    end

    def render_xticks(pdf, area, xrange, xticks)
      xtick_texts = @opts[:x_ticks] || xticks.map{ |e| "%g" % e }
      w = area.w*0.7 / xticks.size
      rects = xticks.map{ |rx|
        ax = abs_x_positoin( rx, area, xrange )
        Rect.new( ax-w/2, area.y, w, area.h )
      }
      draw_samesize_texts( pdf, rects, xtick_texts, valign: :top )
    end

    def render_x_grid(pdf, area, xrange, xvalues)
      pdf.save_graphics_state do
        pdf.line_width = 0.5
        xvalues.each do |v|
          if v==0
            pdf.stroke_color "000000"
            pdf.undash
          else
            pdf.stroke_color "888888"
            pdf.dash([2,2])
          end
          abs_x = abs_x_positoin( v, area, xrange )
          pdf.stroke_vertical_line area.y, area.bottom, at: abs_x
        end
      end
    end

    def tick_values(axis, range)
      ticks = @opts[:"#{axis}_ticks"]
      if @opts[:series].first[axis] || !ticks
        super(axis, range)
      else
        (1..ticks.size).map(&:to_f)
      end
    end

    def render( pdf, rect )
      stroke_rect(pdf, rect)
      title_text = @opts[:title]
      title, main, ticks, bottom = rect.vsplit(
        (title_text ? 1 : 0),
        7, 
        (has_x_ticks? ? 0.5 : 0),
        (bottom_legend? ? 0.5 : 0))
      draw_text( pdf, title, title_text ) if title_text
      hratio = [(@opts[:y_label] ? 1 : 0), 1, 10]
      ylabel, yticks, chart = main.hsplit(*hratio)
      xrange = @opts[:x_range] || calc_range(:x)
      yrange = @opts[:y_range] || calc_range(:y)
      render_chart(pdf, chart, xrange, yrange)
      xvalues = tick_values(:x, xrange )
      if has_x_ticks?
        _, _, xticks = ticks.hsplit(*hratio)
        render_xticks(pdf, xticks, xrange, xvalues)
      end
      render_x_grid(pdf, chart, xrange, xvalues)
      render_legend(pdf, bottom) if bottom_legend?
      yvalues = tick_values(:y, yrange)
      render_yticks(pdf, yticks, yrange, yvalues)
      render_y_grid(pdf, chart, yrange, yvalues)
    end  
  end
end
