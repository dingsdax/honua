# frozen_string_literal: true

module Honua
  # locations are actual places in the world
  # they are in latitude and longitude (EPSG:4326)
  Location = Struct.new(:lat, :lon) do
    def to_coordinate(zoom: 0)
      lat_rad = deg2rad(lat)
      n = 2.0**zoom
      column = ((lon + 180) / 360.0 * n)
      row = ((1 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / Math::PI) / 2 * n)

      Coordinate.new(row, column, zoom)
    end

    private

    # degrees to radians
    def deg2rad(degrees)
      (degrees * Math::PI) / 180
    end
  end
end
