require 'stringio'
require 'rubygems/package'

module IPFS; end
module IPFS::IO # :nodoc:

  class ReadFromWriterIO # :nodoc:

    def initialize &block
      @block = block
      @stream = StringIO.new
      @d = @p = 0
      @eof = false
      fetch_data
    end

    def read length = nil, outbuf = ''
      return '' if length == 0
      outbuf.slice!(length..-1) if !length.nil?
      q = 0
      while @stream.size > 0
        s = @stream.size - @p
        s = [length - q, s].min if !length.nil?
        outbuf[q, s] = @stream.string[@p, s]
        @p, q = @p + s, q + s
        @eof = true if length.nil? and @p > 0 and @p == q
        break if q == length or @eof
        fetch_data if @stream.size == @p
      end
      if length.nil? || outbuf.size < length
        @eof = true
      end
      if q == 0 and not length.nil?
        outbuf = nil
      end
      outbuf
    end

    def pos
      @d + @p
    end

    def eof?
      @eof
    end

    private
    def fetch_data
      @p, @d = 0, @d + @p
      @stream.string = ''
      @block.call @stream if not @stream.closed?
    end

  end

  module Tar

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
