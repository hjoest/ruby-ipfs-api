require 'stringio'

module IPFS; end
module IPFS::IO # :nodoc:

  class ReadFromWriterIO # :nodoc:

    def initialize &block
      @block = block
      @stream = StringIO.new
      fetch_data
    end

    def read length = nil, outbuf = ''
      return nil if @stream.size == 0
      outbuf.slice!(length..-1) if !length.nil?
      q = 0
      while @stream.size > 0
        s = @stream.size - @p
        s = [length - q, s].min if !length.nil?
        outbuf[q, s] = @stream.string[@p, s]
        @p += s
        q += s
        break if q == length
        fetch_data if @stream.size == @p
      end
      outbuf
    end

    private
      def fetch_data
        @p = 0
        @stream.string = ""
        @block.call @stream if not @stream.closed?
      end

  end

end
