# frozen_string_literal: true

class FakeCanvas
  def initialize
    @called = []
  end

  attr_reader( :called )

  def fill_rect( rc, color )
    @called << { method: :fill_rect, args:[ rc, color ] }
  end
end
