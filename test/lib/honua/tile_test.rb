# frozen_string_literal: true

require_relative '../../test_helper'
require 'pry'
module Honua
  class TileTest < Minitest::Test
    def setup
      Honua.configure do |config|
        config.tiles_url = 'http://fake_tile_server/tile/%<zoom>s/%<column>s/%<row>s.png'
        config.tile_width = 1
        config.tile_height = 1
      end

      @coordinate = Coordinate.new(1, 1, 2)
      @offset = Point.new(1, 2)
    end

    def test_coordinate_delegation
      tile = Tile.new(@coordinate, @offset)

      assert_equal tile.row, @coordinate.row
      assert_equal tile.column, @coordinate.column
      assert_equal tile.zoom, @coordinate.zoom
    end

    def test_configuration_delegation
      tile = Tile.new(@coordinate, @offset)

      assert_equal tile.tiles_url, Honua.configuration.tiles_url
    end

    def test_fetch
      stub_request(:get, 'http://fake_tile_server/tile/2/1/1.png').to_return(body: tile_image, status: 200)

      tile = Tile.get(@coordinate, @offset)

      refute tile.image.nil?
    end

    def test_recalculate
      stub_request(:get, 'http://fake_tile_server/tile/2/1/1.png').to_return(status: 404)
      stub_request(:get, 'http://fake_tile_server/tile/1/0/0.png').to_return(body: tile_image, status: 200)

      tile = Tile.get(@coordinate, @offset)

      assert 2, tile.image.width
      assert 2, tile.image.height
    end

    def test_max_attempts
      Honua.configuration.max_fetch_attempts = 1

      tile = Tile.get(@coordinate, @offset)

      assert_equal Vips::Image.grey(tile.tile_width, tile.tile_height), tile.image

      Honua.configuration.max_fetch_attempts = 3
    end

    def test_out_of_bounds
      Honua.configuration.max_fetch_attempts = 2

      stub_request(:get, 'http://fake_tile_server/tile/2/4/4.png').to_return(status: 400)
      stub_request(:get, 'http://fake_tile_server/tile/2/0/0.png').to_return(body: tile_image, status: 200)

      out_of_bounds = Coordinate.new(2**@coordinate.zoom, 2**@coordinate.zoom, @coordinate.zoom)

      tile = Tile.get(out_of_bounds, @offset)

      assert_equal Coordinate.new(0, 0, 2), tile.coordinate
    end

    def test_negative_out_of_bounds
      Honua.configuration.max_fetch_attempts = 2

      stub_request(:get, 'http://fake_tile_server/tile/2/-1/-1.png').to_return(status: 400)
      stub_request(:get, 'http://fake_tile_server/tile/3/3/2.png').to_return(body: tile_image, status: 200)

      out_of_bounds = Coordinate.new(-1, -1, @coordinate.zoom)

      tile = Tile.get(out_of_bounds, @offset)

      assert_equal Coordinate.new(3, 3, 2), tile.coordinate
    end

    def test_load_tile_from_file
      Honua.configure do |config|
        config.tiles_url = 'file://tile_directory/<zoom>s/%<column>s/%<row>s.png'
      end

      File.stubs(:read).returns(tile_image)

      tile = Tile.get(@coordinate, @offset)

      assert tile.image.is_a?(Vips::Image)
    end
  end
end
