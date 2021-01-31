# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :tools

require 'simplecov'
SimpleCov.start { enable_coverage :branch }

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/minitest'
require 'webmock/minitest'

require 'honua'

module MiniTest
  module Assertions
    # we don't take it too exact with comparing locations :)
    def assert_equal_location(location_a, location_b)
      lat_a = location_a.lat.round(3)
      lon_a = location_a.lon.round(3)

      lat_b = location_b.lat.round(3)
      lon_b = location_b.lon.round(3)

      assert(lat_a == lat_b && lon_a == lon_b,
             "expected #{lat_a}, #{lon_a} to equal #{lat_b}, #{lon_b}")
    end
  end
end

def tile_image(size = '1px')
  File.open(File.expand_path("support/#{size}.png", __dir__)).read
end

def locations
  {
    berlin:  Honua::Location.new(52.520008, 13.404954),
    sydney:  Honua::Location.new(-33.868820, 151.209290),
    tokyo:   Honua::Location.new(35.689487, 139.691711),
    toronto: Honua::Location.new(43.653225, -79.383186),
    vienna:  Honua::Location.new(48.208176, 16.373819)
  }
end
