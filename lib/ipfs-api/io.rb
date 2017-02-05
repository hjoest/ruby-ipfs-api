require 'tempfile'
require 'rubygems/package'

module IPFS; end
module IPFS::IO # :nodoc:

  class StreamProducer # :nodoc:

    def initialize &block
      @block = block
    end

    def stream
      io = Tempfile.new('ruby-ipfs')
      begin
        @block.call io
      ensure
        io.close
      end
      File.open(io.path, 'r')
    end

  end

  module Tar # :nodoc:

    def extract stream, destination
      Gem::Package::TarReader.new(stream) do |tar|
        path = nil
        tar.each do |entry|
          if entry.full_name == '././@LongLink'
            path = File.join(destination, entry.read.strip)
            next
          end
          path ||= File.join(destination, entry.full_name)
          if entry.directory?
            if File.exist?(path) and not File.directory?(path)
              raise IOError.new("Not a directory: #{path}")
            end
            FileUtils.mkdir_p path, :mode => entry.header.mode, :verbose => false
          elsif entry.file?
            if File.exist?(path) and not File.file?(path)
              raise IOError.new("Not a file: #{path}")
            end
            File.open path, "wb" do |fd|
              while (chunk = entry.read(1024))
                fd.write chunk
              end
            end
            FileUtils.chmod entry.header.mode, path, :verbose => false
          end
          path = nil
        end
      end
      true
    end

    module_function :extract

  end

end
