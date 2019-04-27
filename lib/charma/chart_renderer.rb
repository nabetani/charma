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
      # case scale_type(axis)
      # when :log10
      #   Math.log10(v)
      # else
      #   v
      # end
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
    end

    def render
      render_titles
      render_chart
    end
  end
end
