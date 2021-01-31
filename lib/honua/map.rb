# frozen_string_literal: true

require 'async'
require 'forwardable'
require 'ruby-vips'

module Honua
  class Map
    extend Forwardable

    attr_reader :width, :height, :zoom

    def initialize(center:, width:, height:, zoom:)
      @width = width
      @height = height
      @reference, @offset = reference_point(center.zoom_to(zoom))
      @tiles = []
      @zoom = zoom
    end

    def_delegators 'Honua.configuration',
                   :tile_width, :tile_height,
                   :attribution_text, :attribution_fgcolor, :attribution_bgcolor

    def draw
      fetch_tiles
      render
    end

    # return an x,y point on the map image for a geographical location
    def location2point(location)
      x = @offset.x
      y = @offset.y
      coordinate = location.to_coordinate(zoom: @reference.zoom)

      # distance from the know coordinate offset
      x += tile_width * (coordinate.column - @reference.column)
      y += tile_height * (coordinate.row - @reference.row)

      x += @width / 2
      y += @height / 2

      Point.new(x.to_i, y.to_i)
    end

    def point2location(point)
      # TODO: to be implemented
    end

    private

    # returns the initial tile coordinate and its offset relative to the map center
    def reference_point(coordinate)
      # top left coordinate of tile containing center coordinate
      top_left_coordinate = coordinate.container

      # initial tile position offset, assuming centered tile in grid
      offset_x = ((top_left_coordinate.column - coordinate.column) * Honua.configuration.tile_width).round
      offset_y = ((top_left_coordinate.row - coordinate.row) * Honua.configuration.tile_height).round
      offset = Point.new(offset_x, offset_y)

      [top_left_coordinate, offset]
    end

    def fetch_tiles
      coordinate, corner = top_left

      Async do
        (corner.y..@height).step(tile_height).each do |y|
          current_coordinate = coordinate.dup
          (corner.x..@width).step(tile_width).each do |x|
            Async do
              @tiles << Tile.get(current_coordinate, Point.new(x, y))
            end
            current_coordinate = current_coordinate.right
          end
          coordinate = coordinate.down
        end
      end
    end

    # get top left coordinate and offset to map
    def top_left
      x_shift = 0
      y_shift = 0

      corner = Point.new(@offset.x + @width / 2, @offset.y + @height / 2)

      # move left on the map until we have the starting coordinate and offset
      while corner.x.positive?
        corner.x -= tile_width
        x_shift += 1
      end

      # move up on the map until we have the starting coordinate and offset
      while corner.y.positive?
        corner.y -= tile_height
        y_shift += 1
      end

      coordinate = Coordinate.new(@reference.row - y_shift, @reference.column - x_shift, @reference.zoom)

      [coordinate, corner]
    end

    # create a canvas and draw tile images based on their offset onto it
    def render
      canvas = Vips::Image.grey(@width, @height)

      @tiles.each do |tile|
        canvas = canvas.insert(tile.image, tile.offset.x, tile.offset.y) # rubocop:disable Style/RedundantSelfAssignment
      end

      # add attribution image to bottom corner if available & attribution fits into image
      if add_attribution?
        options = { x: canvas.width - attribution.width, y: canvas.height - attribution.height }
        canvas = canvas.composite2(attribution, :over, **options)
      end

      canvas
    end

    # create attribution image
    def attribution
      @attribution ||= begin
        mask = Vips::Image.text(attribution_text)
        mask = mask.embed(4, 2, mask.width + 8, mask.height + 4)
        mask.ifthenelse(Helpers.hex2rgb(attribution_fgcolor), Helpers.hex2rgb(attribution_bgcolor), blend: true)
      end
    end

    def add_attribution?
      !attribution_text.nil? && attribution.width < @width && attribution.height < @height
    end
  end
end
