$:.unshift File.expand_path('../..', __FILE__)

require 'test/samples'
require 'ipfs4r/io'

include IPFS::IO

class ReadFromWriterIOTest < Minitest::Test

  def test_read_write_io
    msg = ('a'..'z').to_a.join
    reader = ReadFromWriterIO.new do |writer|
      writer << msg
      writer.close
    end
    result = reader.read
    assert_equal msg, result
  end

end
