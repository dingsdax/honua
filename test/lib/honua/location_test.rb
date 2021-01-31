# frozen_string_literal: true

require_relative '../../test_helper'

module Honua
  class LocationTest < Minitest::Test
    # zoom level 0
    def test_to_coordinate
      location = locations[:vienna].to_coordinate(zoom: 3)

      assert_equal Coordinate.new(2.7739876754517754, 4.363862644444445, 3), location
    end
  end
end
