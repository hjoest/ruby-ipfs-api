gem 'minitest' if RUBY_VERSION =~ /^1\.9/
require 'minitest/autorun'
if ENV['DEBUG']
  require 'byebug'
else
  def byebug; end
end

$:.unshift File.expand_path('../../lib', __FILE__)
