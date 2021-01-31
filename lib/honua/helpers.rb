# frozen_string_literal: true

module Honua
  class Helpers
    class << self
      # returns the top left and bottom right coordinates at zoom level 0
      # these corners are used to define the map span
      def map_span(locations:)
        coordinates = locations.map(&:to_coordinate)

        top_left = Coordinate.new(
          coordinates.min_by(&:row).row,
          coordinates.min_by(&:column).column,
          coordinates.min_by(&:zoom).zoom
        )

        bottom_right = Coordinate.new(
          coordinates.max_by(&:row).row,
          coordinates.max_by(&:column).column,
          coordinates.max_by(&:zoom).zoom
        )

        [top_left, bottom_right]
      end

      # returns the center coordinate based on map spanning top left and bottom right coordinates
      def map_center_coordinate(top_left:, bottom_right:)
        row    = (top_left.row    + bottom_right.row)    / 2.0
        column = (top_left.column + bottom_right.column) / 2.0
        zoom   = (top_left.zoom   + bottom_right.zoom)   / 2.0

        Coordinate.new(row, column, zoom)
      end

      # returns zoom level based on map spanning coordinates and map dimensions
      # shameless copy from modestmaps.js
      def calculate_zoom(top_left:, bottom_right:, width:, height:)
        # multiplication factor between horizontal span and map width
        h_factor = (bottom_right.column - top_left.column) / (width.to_f / Honua.configuration.tile_width)

        # possible horizontal zoom to fit geographical extent in map width
        h_possible_zoom = top_left.zoom - (Math.log(h_factor) / Math.log(2)).ceil

        # multiplication factor between vertical span and map height
        v_factor = (bottom_right.row - top_left.row) / (height.to_f / Honua.configuration.tile_height)

        # possible vertical zoom to fit geographical extent in map height
        v_possible_zoom = top_left.zoom - (Math.log(v_factor) / Math.log(2)).ceil

        # initial zoom to fit extent vertically and horizontally
        [h_possible_zoom, v_possible_zoom].min
      end

      # returns map dimensions (in pixels) based on map spanning coordinates and a zoom value
      def calculate_map_dimensions(top_left:, bottom_right:, zoom:)
        top_left = top_left.zoom_to(zoom)
        bottom_right = bottom_right.zoom_to(zoom)

        # map width and height in pixels
        width = ((bottom_right.column - top_left.column) * Honua.configuration.tile_width).to_i
        height = ((bottom_right.row - top_left.row) * Honua.configuration.tile_height).to_i

        [width, height]
      end

      # text can contain some Pango markup
      # https://developer.gnome.org/pango/stable/pango-Markup.html
      def text_label(text:, dpi: 100, text_colour: [0, 0, 0, 255], shadow_colour: [255, 255, 255, 150], blur: 1.5)
        text_mask, = Vips::Image.text(text, dpi: dpi)

        canvas_width = text_mask.width + 10
        canvas_height = text_mask.height + 10
        text_mask = text_mask.gravity('west', canvas_width, canvas_height)
        # use 0 - 1 for the masks
        text_mask /= 255

        shadow_mask = text_mask.gaussblur(blur)
        # credit: https://github.com/libvips/pyvips/issues/204
        text_mask = text_mask * text_colour + ((text_mask * -1) + 1) * shadow_mask * shadow_colour

        text_mask.unpremultiply.copy(interpretation: 'srgb')
      end

      # convert hex color string to something VIPS understands
      def hex2rgb(hex)
        color_array = (hex.match(/#(..?)(..?)(..?)/))[1..3]
        color_array.map! { |x| x + x } if hex.size == 4 # e.g. #333
        color_array.map(&:hex)
      end
    end
  end
end
