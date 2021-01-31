# frozen_string_literal: true

require_relative '../lib/honua'

# show map of world add markers with labels of certain cities
# map dimensions are fixed, zoom level will be calculated

# Tile server attribution:
# Map tiles by Stamen Design (http://stamen.com),
# under CC BY 3.0 (http://creativecommons.org/licenses/by/3.0).
# Data by OpenStreetMap (http://openstreetmap.org), under ODbL (http://www.openstreetmap.org/copyright).

Honua.configure do |config|
  config.tiles_url = 'http://tile.stamen.com/terrain/%<zoom>s/%<column>s/%<row>s.png'
  config.attribution_text = '<b>Stamen Design | © OpenStreetMap contributors</b>'
end

places = {
  Berlin:   Honua::Location.new(52.520008, 13.404954),
  Honolulu: Honua::Location.new(21.315603, -157.858093),
  Sydney:   Honua::Location.new(-33.868820, 151.209290),
  東京:      Honua::Location.new(35.689487, 139.691711),
  Toronto:  Honua::Location.new(43.653225, -79.383186)
}

# get map span
top_left, bottom_right = Honua::Helpers.map_span(locations: places.values)

# find geographic map center
center = Honua::Helpers.map_center_coordinate(top_left: top_left, bottom_right: bottom_right)

# calculate zoom
zoom = Honua::Helpers.calculate_zoom(top_left: top_left, bottom_right: bottom_right, width: 1000, height: 300)

# get map
map = Honua::Map.new(center: center, width: 1000, height: 350, zoom: zoom)
map_image = map.draw

# add simple markers with labels
places.each do |name, location|
  marker = map.location2point(location)
  blue = [10, 100, 200, 255]

  # draw a circle as marker
  map_image = map_image.draw_circle([240, 240, 240, 255], marker.x, marker.y, 5, fill: true)
  map_image = map_image.draw_circle(blue, marker.x, marker.y, 4, fill: true)

  label = Honua::Helpers.text_label(text: "<b>#{name}</b>", text_colour: blue)

  # composite the place name on the image
  map_image = map_image.composite(label, :over, x: marker.x + 8, y: marker.y - 7)
end

filename = '../tmp/world.png'
map_image.write_to_file(File.expand_path(filename, __dir__))

`open #{filename}` # open image
