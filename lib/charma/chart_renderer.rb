# frozen_string_literal: true

module Charma
  class ChartRenderer
    def initialize( chart, canvas, area )
      @chart = chart
      @canvas = canvas
      @area = area
    end

    def render_title
      @canvas.text( @chart[:title], @area )
      @canvas.text( "test", Rect.new( 0, 0, 100, 100 ) )
      @canvas.text( "test", Rect.new( 440, 0, 100, 100 ) )
      @canvas.text( "test", Rect.new( 0, 620, 100, 100 ) )
      @canvas.text( "test", Rect.new( 440, 620, 100, 100 ) )
    end

    def render
      render_title
    end
  end
end
