# frozen_string_literal: true

module Charma
  class LineChart < Chart
    def initialize(opts)
      @opts = opts
      @opts[:colors] ||= colors(@opts[:series].size)
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
      pdf.save_graphics_state do
        pdf.line_width( 4 )
        stroke_rect(pdf, rect)
        @opts[:series].each.with_index do |s,ix|
          pdf.stroke_color( @opts[:colors][ix] )
          render_series( pdf, rect, xrange, yrange, s)
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
      xrange = @opts[:y_range] || calc_range(:x)
      yrange = @opts[:y_range] || calc_range(:y)
      render_chart(pdf, chart, xrange, yrange)
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
    end  end
end
