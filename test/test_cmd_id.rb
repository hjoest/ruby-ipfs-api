$:.unshift File.expand_path('../..', __FILE__)

require 'test/common'
require 'ipfs-api'

include IPFS

class CommandIdTest < Minitest::Test

  def test_id
    ipfs = Connection.new
    id = ipfs.id
    assert_equal 46, id.size
    assert id.start_with?('Qm')
  end

end
