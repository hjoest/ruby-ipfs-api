require 'minitest/autorun'
if ENV['DEBUG']
  require 'byebug'
else
  def byebug; end
end

$:.unshift File.expand_path('../../lib', __FILE__)
