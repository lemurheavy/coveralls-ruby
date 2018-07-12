#!/usr/bin/env rake
# frozen_string_literal: true

require 'bundler/gem_tasks'

# Travis!
require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc 'Run RSpec'
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

task default: :spec
