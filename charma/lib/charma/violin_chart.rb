# frozen_string_literal: true

module Charma
  class ViolinChart < Chart
    def initialize(opts)
      super(opts)
    end

    # TODO: LineChart に同じようなメソッドがあるのでなんとかする
    def calc_range(sym)
      r0 = @opts[:series].map{ |e| e[sym] }.flatten.minmax
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

    # TODO: BarChart に同じメソッドがあるのでなんとかする
    def render_xticks(pdf, area)
      rects = area.hsplit(*Array.new(@opts[:x_ticks].size){ 1 }).map{ |rc0|
        rc0.hsplit(1,8,1)[1]
      }
      draw_samesize_texts( pdf, rects, @opts[:x_ticks], valign: :top )
    end

    def draw_violin(pdf, rect, yrange, hists, cols)
      ratio = 0.75
      _, violins, = rect.hsplit( (1-ratio)/2, ratio, (1-ratio)/2 )
      v_rects = violins.hsplit(*Array.new(hists.size,1))
      v_rects.zip(hists, cols) do |rc, hist, col|
        cx = rc.x + rc.w/2
        h = rc.h / hist.size.to_f
        hist.each.with_index do |f, ix|
          w = rc.w * f
          top = rc.bottom + h*(ix+1)
          edge = 1e-1 # バーの隙間を埋める
          fill_rect( pdf, Rect.new( cx-w/2, top + edge, w, h + edge*2 ), col )
        end
      end
    end

    def meansize( vals )
      sum=0.0
      count=0
      vals.each do |vvv|
        vvv.each do |vv|
          sum += vv.size
          count+=1
        end
      end
      sum / count
    end

    def make_histograms( vals, range )
      hist_size = @opts[:bins] || [10,Math.sqrt( meansize(vals) ).round].max
      min = range.min
      step = (range.max - min).to_f / hist_size
      bottoms = Array.new(hist_size){ |ix| min + (ix+1)*step }
      raw_h = vals.map{ |vvv|
        vvv.map{ |vv|
          vv.each.with_object([0]*hist_size){ |v,o|
            ix = bottoms.index{ |b| v<b }
            o[ix]+=1
          }
        }
      }
      ratio = 1.0 / raw_h.flatten.max
      raw_h.map{ |vvv|
        vvv.map{ |vv|
          vv.map{ |e| e*ratio }
        }
      }
    end

    def render_chart(pdf, rect, yrange)
      stroke_rect(pdf, rect)
      y_values = @opts[:series].map{ |s| s[:y] }.transpose
      bar_areas = rect.hsplit(*Array.new(y_values.size,1))
      cols = if y_values.first.size==1
        colors(y_values.size).map{ |e| [e] }
      else
        [colors(y_values.first.size)] * y_values.size
      end
      hists = make_histograms(y_values, yrange)
      hists.zip(bar_areas, cols).each do |h, rc, c|
        draw_violin(pdf, rc, yrange, h, c)
      end
    end

    # BarChart の render とほぼ同じなのでなんとかする
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
      yrange = @opts[:y_range] || calc_range(:y)
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
