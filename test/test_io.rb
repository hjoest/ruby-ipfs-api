$:.unshift File.expand_path('..', __FILE__)

require 'samples'
require 'ipfs-api/io'

include IPFS::IO

class StreamProducerTest < Minitest::Test

  def setup
    @parts = Samples.some_byte_sequences
    enum = @parts.each
    producer = StreamProducer.new do |writer|
      enum.each do |part|
        writer << part
      end
    end
    @reader = producer.stream
  end

  def test_read_byte_wise
    result = ''
    while (byte = @reader.read(1))
      result << byte
      assert_equal result.size, @reader.pos
    end
    assert_eof @reader
    assert_equal @parts.join, result
  end

  def test_read_larger_chunks
    result = ''
    while (chunk = @reader.read(199))
      result << chunk
      assert_equal result.size, @reader.pos
      if chunk.size < 199
        assert_eof @reader
      else
        assert_not_eof @reader
      end
    end
    assert_eof @reader
    assert_equal @parts.join, result
  end

  def test_different_variants_of_read
    chunk = @reader.read(199)
    assert_equal 199, chunk.size
    assert_not_eof @reader
    chunk = @reader.read(0)
    assert_equal 0, chunk.size
    assert_not_eof @reader
    chunk = @reader.read
    assert_equal 243, chunk.size
    assert_eof @reader
    chunk = @reader.read
    assert_equal 0, chunk.size
    assert_eof @reader
  end

  private
  def assert_eof stream
    assert stream.eof?, "Stream should have reached end-of-file"
  end

  def assert_not_eof stream
    assert !stream.eof?, "Stream should not yet have reached end-of-file"
  end

end
