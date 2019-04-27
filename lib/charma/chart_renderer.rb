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

    def prepare_areas
      a = @areas = Areas.new
      title_h = 1
      main_h = 10
      legend_h = 1
      a.title, main, a.legend = @area.vsplit( title_h, main_h, legend_h )
      left0, left1, center, right1, right0 = main.hsplit( 1, 1, 10, 1, 1 )
      chart_h = 10
      x_tick_h = 0.7
      x_title_h = 1
      a.y_title, = left0.vsplit( chart_h, x_tick_h, x_title_h )
      a.y_tick, = left1.vsplit( chart_h, x_tick_h, x_title_h )
      a.chart, a.x_tick, a.x_title = center.vsplit( chart_h, x_tick_h, x_title_h )
      a.y2_tick, = right1.vsplit( chart_h, x_tick_h, x_title_h )
      a.y2_title, = right0.vsplit( chart_h, x_tick_h, x_title_h )
    end

    def render_title
      @canvas.text( @chart[:title], @areas.title )
      @canvas.text( @chart[:x_title], @areas.x_title )
      @canvas.rottext( @chart[:y_title], @areas.y_title, 90 )
    end

    def render
      render_title
    end
  end
end
