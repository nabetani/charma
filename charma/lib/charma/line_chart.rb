# frozen_string_literal: true

module Charma
  class LineChart < Chart
    def initialize(opts)
      super(opts)
    end

    def calc_range( sym )
      r0 = @opts[:series].flat_map{ |e|
        e[sym]
      }.minmax
      dist = r0[1] - r0[0]
      delta = dist==0 ? 1 : dist*0.1
      if 0<=r0[0]
        [[r0[0]-delta, 0].max, r0[1]+delta]
      else
        [r0[0]-delta, r0[1]+delta]
      end
    end

    def render_series( pdf, rect, xrange, yrange, s)
      xs = s[:x]
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
        true
      else
        !! @opts[:x_ticks]
      end
    end

    def render_xticks(pdf, area, xrange)
      xtick_texts = tick_values( xrange ).map{ |e| "%g" % e }
      rects = area.hsplit(*([1]*xtick_texts.size)).map{ |rc0|
        rc0.hsplit(1,8,1)[1]
      }
      draw_samesize_texts( pdf, rects, xtick_texts, valign: :top )
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
      if has_x_ticks?
        _, _, xticks = ticks.hsplit(*hratio)
        render_xticks(pdf, xticks, xrange)
      end
      
      render_legend(pdf, bottom) if bottom_legend?
      # if @opts[:y_label]
      #   render_rottext(pdf, ylabel, @opts[:y_label] )
      # end
      # if @opts[:x_ticks]
      #   _, _, xticks = ticks.hsplit(*hratio)
      #   render_xticks(pdf, xticks)
      # end
      # yvalues = ytick_values(yrange)
      # render_yticks(pdf, yticks, yrange, yvalues)
      # render_y_grid(pdf, chart, yrange, yvalues)
    end  
  end
end
