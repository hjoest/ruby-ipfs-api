require 'cgi'
require 'json'
require 'net/http'

module IPFS

  class Connection

    def initialize base_url = 'http://127.0.0.1:5001'
      @base_url = base_url
    end

    def add nodes, &block
      boundaries = [ generate_boundary ]
      headers = {
        'Content-Disposition' => 'form-data: name="files"',
        'Content-Type' => "multipart/form-data; boundary=#{boundaries[0]}"
      }
      walker = Upload::TreeWalker.depth_first(nodes)
      node_map = {}
      stream = IO::ReadFromWriterIO.new do |buf|
        next if walker.nil?
        begin
          node, depth = walker.next
          node_map[node.path] = node
        rescue StopIteration
          depth = -1
          walker = nil
        end
        while boundaries.size > depth+1 && boundary = boundaries.shift
          buf << %Q{\
--#{boundary}--\r\n\
\r\n\
\r\n\
}
        end
        next if walker.nil?
        if node.folder?
          boundaries.unshift generate_boundary
          buf << %Q{\
--#{boundaries[1]}\r\n\
Content-Disposition: form-data; name="file"; filename="#{node.path}"\r\n\
Content-Type: multipart/mixed; boundary=#{boundaries[0]}\r\n\
\r\n\
\r\n\
}
        elsif node.file?
          buf << %Q{\
--#{boundaries[0]}\r\n\
Content-Disposition: file; filename="#{node.path}"\r\n\
Content-Type: application/octet-stream\r\n\
\r\n\
#{node.content}\r\n\
}
        else
          raise "Unknown node type: #{node}"
        end
      end
      nodes = []
      post("add?encoding=json&r=true&progress=true", stream, headers) do |chunk|
        next if chunk.empty?
        upload = JSON.parse(chunk)
        path, bytes, hash = ['Name', 'Bytes', 'Hash'].map { |p| upload[p] }
        node = node_map[path]
        node.bytes = bytes if bytes
        node.hash = hash if hash
        if block_given?
          block.call(node)
        elsif hash
          nodes << node
        end
      end
      block_given? ? nil : nodes
    end

    def cat path
      result = ''
      post("cat?arg=#{CGI.escape(path)}") do |chunk|
        result << chunk
      end
      result
    end

    def get path, destination = nil
      stream = IO::ReadFromWriterIO.new do |buf|
        post("get?arg=#{CGI.escape(path)}") do |chunk|
          buf << chunk
        end
        buf.close
      end
      if destination.nil?
        return stream
      else
        return IO::Tar.extract(stream, destination)
      end
    end

    def id
      JSON.parse(post('id').body)['ID']
    end

    def ls path
      JSON.parse(post("ls?arg=#{CGI.escape(path)}").body)
    end

    def name
      NameCommand.new(self)
    end

    private
    def post command, stream = nil, headers = {}, params = {}, &block # :nodoc:
      uri = URI.parse("#{@base_url}/api/v0/#{command}")
      http = Net::HTTP.new(uri.host, uri.port)
#http.set_debug_output $stderr
      headers['User-Agent'] = "ruby-ipfs-api/#{VERSION}/"
      headers['Transfer-Encoding'] = 'chunked'
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      if stream
        request.body_stream = stream
      else
        params['encoding'] = 'json'
        params['stream-channels'] = 'true'
        request.set_form_data(params)
      end
      http.request(request) do |response|
        raise "Request failed: #{response.body}" if !response.kind_of?(Net::HTTPOK)
        if block
          response.read_body do |chunk|
            block.call chunk
          end
        end
      end
    end

    def generate_boundary # :nodoc:
      (1..60).map { rand(16).to_s(16) }.join
    end

    class NameCommand # :nodoc:

      def initialize connection
        @connection = connection
      end

      def resolve
        @connection.instance_exec(self) do
          JSON.parse(post('name/resolve').body)['Path']
        end
      end

    end

  end

end
