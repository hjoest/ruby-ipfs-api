gem 'minitest' if RUBY_VERSION =~ /^1\.9/
require 'minitest/autorun'
require 'byebug'

$:.unshift File.expand_path('../../lib', __FILE__)
