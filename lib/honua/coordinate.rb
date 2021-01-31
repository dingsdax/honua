# frozen_string_literal: true

# a coordinate is used to indentify a tile based on the zoom level and the tile grid's x/y coordinates
module Honua
  class Coordinate
    attr_accessor :row, :column, :zoom

    def initialize(row, column, zoom = 0)
      @row    = row
      @column = column
      @zoom   = zoom
    end

    def zoom_to(zoom_level)
      Coordinate.new(
        row * (2**(zoom_level - zoom)),
        column * (2**(zoom_level - zoom)),
        zoom_level
      )
    end

    # the top left most coordinate within the same tile
    # used to identify the tile within the the tile rid
    def container
      Coordinate.new(row.to_i, column.to_i, zoom)
    end

    def up(distance = 1)
      Coordinate.new(row - distance, column, zoom)
    end

    def right(distance = 1)
      Coordinate.new(row, column + distance, zoom)
    end

    def down(distance = 1)
      Coordinate.new(row + distance, column, zoom)
    end

    def left(distance = 1)
      Coordinate.new(row, column - distance, zoom)
    end

    def to_location
      n = 2.0**zoom
      lon = column / n * 360.0 - 180
      lat_rad = Math.atan(Math.sinh(Math::PI * (1 - 2 * row / n)))
      lat = rad2deg(lat_rad)

      Location.new(lat, lon)
    end

    def ==(other)
      row == other.row &&
        column == other.column &&
        zoom == other.zoom
    end

    private

    # radians to degrees
    def rad2deg(radians)
      radians * (180 / Math::PI)
    end
  end
end
