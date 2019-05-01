# frozen_string_literal: true

module Charma
  class Error < StandardError; end

  module Errors
    class InvalidPageSize < Error; end
    class InvalidPageLayout < Error; end
    class InvalidOption < Error; end
  end
end
