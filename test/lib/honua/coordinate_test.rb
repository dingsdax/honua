# frozen_string_literal: true

require_relative '../../test_helper'

module Honua
  class CoordinateTest < Minitest::Test
    def setup
      @coordinate = Coordinate.new(0, 1, 2)
    end

    def test_container
      assert_equal Coordinate.new(0, 1, 2), Coordinate.new(0.5, 1.2, 2).container
    end

    def test_up
      assert_equal Coordinate.new(-1, 1, 2), @coordinate.up
    end

    def test_down
      assert_equal Coordinate.new(1, 1, 2), @coordinate.down
    end

    def test_left
      assert_equal Coordinate.new(0, 2, 2), @coordinate.left(-1)
    end

    def test_right
      assert_equal Coordinate.new(0, 3, 2), @coordinate.right(2)
    end

    def test_zoom_to
      assert_equal Coordinate.new(0, 4, 4), @coordinate.zoom_to(4)
    end

    def test_to_location
      location = Coordinate.new(2.7739876754517754, 4.363862644444445, 3).to_location

      assert_equal_location locations[:vienna], location
    end
  end
end
