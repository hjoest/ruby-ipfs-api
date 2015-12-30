require 'stringio'

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

end
