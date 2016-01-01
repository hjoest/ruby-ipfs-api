$:.unshift File.expand_path('../..', __FILE__)

require 'test/samples'
require 'ipfs-api'

include IPFS

class CommandGetTest < Minitest::Test

  def test_get_as_tar_stream
    ipfs = Connection.new
    Samples.some_virtual_folders do |fixture, expectation|
      ipfs.add fixture
      hash = 'QmedYJNEKn656faSHaMv5UFVkgfSzwYf9u4zsYoXqgvnch'
      stream = ipfs.get(hash)
      tar = stream.read
      # take some samples of the TAR archive
      assert_equal 3072, tar.length
      [ 0x101, 0x301, 0x501 ].each do |seek|
        assert_equal 'ustar', tar[seek..seek+4]
      end
      [ 0x0, 0x200, 0x400 ].each do |seek|
        assert_equal hash, tar[seek..seek+45]
      end
    end
  end

  def test_get_and_extract
    ipfs = Connection.new
    Samples.some_virtual_folders do |fixture, expectation|
      ipfs.add fixture
      hash = 'QmedYJNEKn656faSHaMv5UFVkgfSzwYf9u4zsYoXqgvnch'
      Dir.mktmpdir(Samples::TEMP_DIR_PREFIX) do |target|
        ipfs.get hash, target
        actual = File.read(File.join(target, hash, 'b1/hello.txt'))
        assert_equal "Hello World!\n", actual
      end
    end
  end

end
