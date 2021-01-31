# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/audit/task'
require 'gemsmith/rake/setup'
require 'git/lint/rake/setup'
require 'rake/testtask'
require 'rubocop/rake_task'

Bundler::Audit::Task.new
RuboCop::RakeTask.new

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.warning = false
  t.verbose = true
  t.pattern = 'test/**/*_test.rb'
end

desc 'Run code quality checks'
task code_quality: %i[bundle:audit git_lint rubocop]

task default: %i[code_quality test]
