$:.unshift File.expand_path('../..', __FILE__)

require 'test/samples'
require 'ipfs4r'

include IPFS

class CommandGetTest < Minitest::Test

  def test_get
    ipfs = Connection.new
    Samples.some_virtual_folders do |fixture, expectation|
      ipfs.add fixture
      # FIXME: provides only raw response yet
      actual = ipfs.get('QmedYJNEKn656faSHaMv5UFVkgfSzwYf9u4zsYoXqgvnch')
    end
  end

end
