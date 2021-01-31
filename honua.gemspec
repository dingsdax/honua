# frozen_string_literal: true

require_relative 'lib/honua/identity'

Gem::Specification.new do |spec|
  spec.name = Honua::Identity::NAME
  spec.version = Honua::Identity::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ['Joesi D.']
  spec.email = ['dingsdax@fastmail.fm']
  spec.homepage = 'https://github.com/dingsdax/honua'
  spec.summary = 'A Ruby geographic mapping library'
  spec.description = <<~DESCRIPTION
    A mapping library to stitch geographic map images based on map tiles
    provided by a rastered tile server.
  DESCRIPTION
  spec.license = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/dingsdax/honua/issues',
    'changelog_uri' => 'https://github.com/dingsdax/honua/blob/master/CHANGES.md',
    'documentation_uri' => 'https://github.com/dingsdax/honua',
    'source_code_uri' => 'https://github.com/dingsdax/honua'
  }

  spec.required_ruby_version = '~> 3.0'

  spec.add_dependency 'async'
  spec.add_dependency 'ruby-vips'
  spec.add_dependency 'zeitwerk'

  spec.files = Dir['lib/**/*']
  spec.extra_rdoc_files = Dir['README*', 'LICENSE*']
  spec.require_paths = ['lib']
end
