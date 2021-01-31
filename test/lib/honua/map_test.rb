# frozen_string_literal: true

require_relative '../../test_helper'

module Honua
  class Map
    public :top_left, :fetch_tiles, :attribution

    attr_reader :tiles
  end

  class MapTest < Minitest::Test
    def setup
      stub_request(:get, %r{http://fake_tile_server/tile/1}).to_return(body: tile_image('5px'), status: 200)

      Honua.configure do |config|
        config.tiles_url = 'http://fake_tile_server/tile/%<zoom>s/%<column>s/%<row>s.png'
        config.tile_width = 5
        config.tile_height = 5
      end

      @location = locations[:vienna]
      @map = Map.new(center: @location.to_coordinate, width: 20, height: 20, zoom: 1)
    end

    def test_top_left
      coordinate, corner = @map.top_left

      assert_equal Coordinate.new(-2, -1, 1), coordinate
      assert_equal Point.new(0, -3), corner
    end

    def test_fetch_tiles
      Vips::Image.any_instance.expects(:composite2).never # no attribution

      canvas = @map.draw

      assert_equal 25, @map.tiles.count
      assert_equal 20, canvas.width
      assert_equal 20, canvas.height
    end

    def test_attribution
      Honua.configuration.attribution_text = 'test'

      map = Map.new(center: @location.to_coordinate, width: 100, height: 20, zoom: 1)

      Vips::Image.any_instance.expects(:composite2).once

      map.draw

      assert map.attribution.is_a? Vips::Image

      Honua.configuration.attribution_text = nil
    end

    def test_attribution_too_big
      Honua.configuration.attribution_text = 'test'

      Vips::Image.any_instance.expects(:composite2).never

      @map.draw

      Honua.configuration.attribution_text = nil
    end

    def test_location_to_point
      assert_equal Point.new(10, 10), @map.location2point(@location)
    end
  end
end
