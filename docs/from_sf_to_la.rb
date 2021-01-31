# frozen_string_literal: true

require_relative '../lib/honua'
require 'pry'
# Show a map of California from San Francisco to Los Angeles.
# Zoom level is fixed, map dimensions will be calculated.

# Tile server attribution:
# Map tiles by Stamen Design (http://stamen.com),
# under CC BY 3.0 (http://creativecommons.org/licenses/by/3.0).
# Data by OpenStreetMap (http://openstreetmap.org), under ODbL (http://www.openstreetmap.org/copyright).

Honua.configure do |config|
  config.tiles_url = 'http://tile.stamen.com/toner/%<zoom>s/%<column>s/%<row>s.png'
  config.attribution_text = '<b>Stamen Design | © OpenStreetMap contributors</b>'
end

places = {
  la: Honua::Location.new(34.052235, -118.243683),
  sf: Honua::Location.new(37.773972, -122.431297)
}

zoom = 7

# get map span
top_left, bottom_right = Honua::Helpers.map_span(locations: places.values)

# find geographic map center
center = Honua::Helpers.map_center_coordinate(top_left: top_left, bottom_right: bottom_right)

# calculate dimensions
wdith, height = Honua::Helpers.calculate_map_dimensions(top_left: top_left, bottom_right: bottom_right, zoom: zoom)

# get map
map = Honua::Map.new(center: center, width: wdith + 100, height: height + 100, zoom: zoom)
map_image = map.draw

filename = '../tmp/california.png'
map_image.write_to_file(File.expand_path(filename, __dir__))

`open #{filename}` # open image
