$:.unshift File.expand_path('../..', __FILE__)

require 'test/common'
require 'ipfs4r'

include IPFS

class CommandNameTest < Minitest::Test

  def test_name_resolve
    ipfs = Connection.new
    resolved = ipfs.name.resolve
    assert resolved.start_with?('/ipfs/Qm')
  end

end
