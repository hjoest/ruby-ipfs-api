$:.unshift File.expand_path('../..', __FILE__)

require 'test/samples'
require 'ipfs-api'

include IPFS

class CommandCatTest < Minitest::Test

  def test_cat
    ipfs = Connection.new
    Samples.some_virtual_folders do |fixture, expectation|
      ipfs.add fixture
      actual = ipfs.cat('QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG')
      assert_equal "Hello World!\n", actual
    end
  end

end
