# frozen_string_literal: true

require 'forwardable'
require 'open-uri'
require 'ruby-vips'

# a tile is an image file representing a coordinate at a certain zoom level
# * request a tile from the tile server for a coordinate
# * use scaled version if not available at on of the next zoom levels
# * if row or column is out of bounds => start from the left again
# * if max_fetch_attempts are reached => use empty tile
module Honua
  class Tile
    extend Forwardable

    attr_reader :image, :offset, :coordinate

    def self.get(coordinate, offset)
      tile = Tile.new(coordinate, offset)
      tile.fetch

      tile
    end

    def initialize(coordinate, offset)
      @coordinate = coordinate
      @offset = offset

      @image = blank_tile
    end

    def_delegators :@coordinate, :column, :row, :zoom
    def_delegators 'Honua.configuration', :max_fetch_attempts, :tiles_url, :tile_width, :tile_height, :user_agent

    # fetch tile image through url that includes zoom level and the tile grid's x/y coordinates
    def fetch(attempt = 1, scale = 1)
      if attempt >= max_fetch_attempts
        @image = blank_tile
      else
        raw_tile = if url.start_with?('file://')
                     File.read(url.gsub('file://', ''))
                   else
                     URI.parse(url).open('User-Agent' => user_agent, &:read)
                   end

        @image = Vips::Image.new_from_buffer(raw_tile, '')
      end

      @image = @image.resize(scale) if scale > 1
    rescue OpenURI::HTTPError, Errno::ENOENT
      old_row = @coordinate.row
      old_column = @coordinate.column

      # out of bounds columns or rows => try starting from the left or top
      @coordinate.row    = @coordinate.row - (2**@coordinate.zoom)    if @coordinate.row > (2**@coordinate.zoom - 1)
      @coordinate.column = @coordinate.column - (2**@coordinate.zoom) if @coordinate.column > (2**@coordinate.zoom - 1)

      @coordinate.row    = @coordinate.row + (2**@coordinate.zoom)    if @coordinate.row.negative?
      @coordinate.column = @coordinate.column + (2**@coordinate.zoom) if @coordinate.column.negative?

      return fetch(attempt + 1) if old_row != @coordinate.row || old_column != @coordinate.column # if out of bounds

      # if tile was not available try next zoom level and scale
      recalculate!(scale)
      fetch(attempt + 1, scale * 2)
    end

    private

    # try the next lower zoom level if tile is not available
    def recalculate!(scale)
      neighbor = @coordinate.zoom_to(zoom - 1)
      parent = neighbor.container

      col_shift = 2 * (neighbor.column - parent.column)
      row_shift = 2 * (neighbor.row - parent.row)

      @offset.x -= scale * tile_width * col_shift
      @offset.y -= scale * tile_height * row_shift
      @coordinate = parent
    end

    def url
      format(tiles_url, zoom: zoom, column: column, row: row)
    end

    def blank_tile
      Vips::Image.grey(tile_width, tile_height)
    end
  end
end
