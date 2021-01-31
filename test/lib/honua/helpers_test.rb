# frozen_string_literal: true

require_relative '../../test_helper'

module Honua
  class HelpersTest < Minitest::Test
    def setup
      Honua.configure do |config|
        config.tile_width = 10
        config.tile_height = 10
      end
    end

    def test_map_span
      top_left, bottom_right = Helpers.map_span(locations: locations.values)

      top_left_coordinate = Coordinate.new(
        locations[:berlin].to_coordinate.row,
        locations[:toronto].to_coordinate.column
      )

      assert_equal top_left, top_left_coordinate
      assert_equal bottom_right, locations[:sydney].to_coordinate
    end

    def test_map_center_coordinate
      top_left = locations[:berlin].to_coordinate
      bottom_right = locations[:sydney].to_coordinate

      assert_equal Coordinate.new(1, 2, 2),
                   Helpers.map_center_coordinate(top_left: top_left, bottom_right: bottom_right).zoom_to(2).container
    end

    def test_calculate_zoom
      top_left = locations[:tokyo].to_coordinate
      bottom_right = locations[:sydney].to_coordinate

      assert_equal 6, Helpers.calculate_zoom(top_left: top_left, bottom_right: bottom_right, width: 200, height: 200)
    end

    def test_calculate_map_dimensions
      top_left = locations[:tokyo].to_coordinate
      bottom_right = locations[:sydney].to_coordinate

      assert_equal [20, 132], Helpers.calculate_map_dimensions(top_left: top_left, bottom_right: bottom_right, zoom: 6)
    end

    def test_hex2rgb
      assert_equal [250, 250, 250], Helpers.hex2rgb('#fafafa')
      assert_equal [51, 51, 51], Helpers.hex2rgb('#333')
    end

    def test_text_label
      label = Helpers.text_label(text: 'bla')

      assert Helpers.text_label(text: 'bla').is_a?(Vips::Image)
      assert_equal 4, label.bands
    end
  end
end
