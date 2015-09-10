$:.unshift File.expand_path('../..', __FILE__)

require 'test/samples'
require 'ipfs4r/upload'

class NodeTest < Minitest::Test

  include IPFS

  def test_tree_walker
    Samples.some_virtual_folders do |fixture, expectations|
      walker = Upload::TreeWalker.depth_first(fixture)
      actual = walker.to_a
      assert_equal 15, actual.size
      paths = actual.map { |item| item.first.path }
      assert_equal expectations.map { |item| item.first }, paths
    end
  end

end
