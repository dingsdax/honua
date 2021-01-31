# frozen_string_literal: true

require_relative '../lib/honua'
require 'vips'

# maps of Vancouver in different sizes using a local OSM tile server
# download https://download.geofabrik.de/north-america/canada.html and import before running this example

Honua.configure do |config|
  config.tiles_url = 'https://a.tile.openstreetmap.org/%<zoom>s/%<column>s/%<row>s.png'
  config.attribution_text = '<b>© OpenStreetMap contributors</b>'
end

center = Honua::Location.new(49.24966, -123.11934) # Vancouver

# try out different sizes and zoom levels
[
  { width: 500, height: 500, zoom: 0 },
  { width: 500, height: 500, zoom: 1 },
  { width: 500, height: 500, zoom: 2 },
  { width: 500, height: 500, zoom: 3 },
  { width: 500, height: 500, zoom: 4 },
  { width: 500, height: 500, zoom: 5 },
  { width: 500, height: 500, zoom: 6 },
  { width: 500, height: 500, zoom: 7 },
  { width: 500, height: 500, zoom: 8 },
  { width: 500, height: 500, zoom: 9 },
  { width: 500, height: 500, zoom: 10 },
  { width: 500, height: 500, zoom: 11 },
  { width: 500, height: 500, zoom: 12 },
  { width: 500, height: 500, zoom: 13 },
  { width: 500, height: 500, zoom: 14 },
  { width: 500, height: 500, zoom: 15 },
  { width: 500, height: 500, zoom: 16 },
  { width: 500, height: 500, zoom: 17 },
  { width: 500, height: 500, zoom: 18 },
  { width: 500, height: 500, zoom: 19 },
  { width: 500, height: 500, zoom: 14 },
  { width: 100, height: 100, zoom: 14 },
  { width: 256, height: 256, zoom: 14 },
  { width: 100, height: 200, zoom: 14 },
  { width: 200, height: 200, zoom: 4 },
  { width: 500, height: 100, zoom: 1 },
  { width: 100, height: 600, zoom: 3 }
].each do |dimension|
  pin = Vips::Image.new_from_file('marker.png').resize(0.1)
  offset_x = pin.width / 2
  offset_y = pin.height

  map = Honua::Map.new(center: center.to_coordinate, width: dimension[:width], height: dimension[:height],
zoom: dimension[:zoom])
  map_image = map.draw

  marker = map.location2point(center)
  map_image = map_image.composite(pin, :over, x: marker.x - offset_x, y: marker.y - offset_y)

  filename = "../tmp/vancouver_#{map.width}x#{map.height}z#{map.zoom}.png"

  map_image.write_to_file(File.expand_path(filename, __dir__))
end
