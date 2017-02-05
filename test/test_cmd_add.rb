$:.unshift File.expand_path('..', __FILE__)

require 'samples'
require 'ipfs-api'

include IPFS

class CommandAddTest < Minitest::Test

  def test_adding_some_filesystem_folders
    ipfs = Connection.new
    Samples.some_filesystem_folders do |fixture, expectation|
      actual = ipfs.add(fixture)
      assert_equal expectation, Hash[actual.map { |n| [ n.path, n.hash ] }]
    end
  end

  def test_adding_some_filesystem_folders_with_block
    ipfs = Connection.new
    Samples.some_filesystem_folders do |fixture, expectation|
      actual = {}
      ipfs.add fixture do |node|
        actual[node.path] = node.hash
      end
      assert_equal expectation, actual
    end
  end

  def test_adding_some_virtual_folders
    ipfs = Connection.new
    Samples.some_virtual_folders do |fixture, expectation|
      actual = {}
      ipfs.add fixture do |node|
        actual[node.path] = node.hash
      end
      assert_equal expectation, actual
    end
  end

end
