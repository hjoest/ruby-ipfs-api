$:.unshift File.expand_path('..', __FILE__)

require 'samples'
require 'ipfs-api'

include IPFS

class CommandIdTest < Minitest::Test

  def test_id
    ipfs = Connection.new
    id = ipfs.id
    if id.start_with?('Qm')
      assert_equal 46, id.size
    else
      assert_equal 52, id.size
    end
  end

end
