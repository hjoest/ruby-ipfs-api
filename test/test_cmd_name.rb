$:.unshift File.expand_path('../..', __FILE__)

require 'test/common'
require 'ipfs-api'

include IPFS

class CommandNameTest < Minitest::Test

  def test_name_resolve
    ipfs = Connection.new
    resolved = ipfs.name.resolve
    assert resolved.start_with?('/ipfs/Qm')
  end

  def test_name_resolve_with_id
    ipfs = Connection.new
    resolved = ipfs.name.resolve('ipfs.io')
    assert resolved.start_with?('/ipfs/Qm')
  end

end
