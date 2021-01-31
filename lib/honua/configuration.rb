# frozen_string_literal: true

module Honua
  class Configuration
    attr_accessor :attribution_bgcolor, :attribution_fgcolor, :attribution_text,
                  :max_fetch_attempts, :tile_height, :tile_width,
                  :tiles_url, :user_agent

    def initialize
      # max attempts to fetch a tile until given up and returning an empty tile
      @max_fetch_attempts = 3

      # OSM map tiles are typically 256x256
      # https://wiki.openstreetmap.org/wiki/Tiles
      @tile_height = 256
      @tile_width = 256

      # user agent that's used to make requests to the tile server
      @user_agent = Honua::Identity::VERSION_LABEL

      # attribution_text can contain some Pango markup
      # https://developer.gnome.org/pango/stable/pango-Markup.html
      @attribution_text = nil
      @attribution_fgcolor = '#fff'
      @attribution_bgcolor = '#000'
    end
  end
end
