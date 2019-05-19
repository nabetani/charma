# frozen_string_literal: true

module Charma
  module_function def value_within_range( min, max, v )
    v<min ? min : (max<v ? max : v)
  end
end
