# frozen_string_literal: true

require_relative '../lib/honua'

# https://visibleearth.nasa.gov/images/147190/explorer-base-map/147193
# NASA Earth Observatory map by Joshua Stevens using data from NASA’s MODIS Land Cover,
# the Shuttle Radar Topography Mission (SRTM), the General Bathymetric Chart of the Oceans (GEBCO),
# and Natural Earth boundaries.

Honua.configure do |config|
  config.tiles_url = 'file://./../osm_data/eo_tiles/%<zoom>s/%<column>s/%<row>s.png'
end

# get map
map = Honua::Map.new(center: Honua::Coordinate.new(5, 3, 3), width: 600, height: 128, zoom: 2)
map_image = map.draw

blue = [10, 40, 200, 200]
green = [20, 200, 100, 200]
label = Honua::Helpers.text_label(text: '<b>HONUA</b>', dpi: 500, text_colour: blue, shadow_colour: green, blur: 3)
map_image = map_image.composite(label, :over, x: (600 - label.width) / 2, y: (128 - label.height) / 2)

filename = '../tmp/header.png'
map_image.write_to_file(File.expand_path(filename, __dir__))

`open #{filename}` # open image
