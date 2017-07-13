require 'cgi'
require 'json'
require 'net/http'

module IPFS

  class Connection

    def initialize base_url = 'http://127.0.0.1:5001'
      @base_url = base_url
    end

    def add nodes, &block
      boundary = generate_boundary
      tree_walker = Upload::TreeWalker.depth_first(nodes)
      node_map = {}
      producer = IO::StreamProducer.new do |buf|
        buf << %Q{\
--#{boundary}\r\n\
Content-Disposition: file; filename="root"\r\n\
Content-Type: application/x-directory\r\n\
\r\n\
\r\n\
}
        tree_walker.each do |node, depth|
          node_map[node.path] = node
          if node.folder?
            buf << %Q{\
--#{boundary}\r\n\
Content-Disposition: file; filename="root#{node.path.gsub('/', '%2F')}"\r\n\
Content-Type: application/x-directory\r\n\
\r\n\
\r\n\
}
          elsif node.file?
            buf << %Q{\
--#{boundary}\r\n\
Content-Disposition: file; filename="root#{node.path.gsub('/', '%2F')}"\r\n\
Content-Type: application/octet-stream\r\n\
\r\n\
#{node.content}\r\n\
}
          else
            raise "Unknown node type: #{node}"
          end
        end
        buf << %Q{\
--#{boundary}\r\n\
}
      end
      headers = {
        'Content-Type' => "multipart/form-data; boundary=#{boundary}"
      }
      stream = producer.stream
      uploaded_nodes = []
      post("add?encoding=json&r=true&progress=true", stream, headers) do |chunk|
        next if chunk.empty?
        upload = nil
        begin
          upload = JSON.parse(chunk)
        rescue JSON::ParserError
        end
        next if upload.nil?
        path, bytes, hash = ['Name', 'Bytes', 'Hash'].map { |p| upload[p] }
        next if not path.start_with?('root/')
        path = path[4..-1]
        node = node_map[path]
        next if not node
        node.bytes = bytes if bytes
        node.hash = hash if hash
        if block_given?
          block.call(node)
        elsif hash
          uploaded_nodes << node
        end
      end
      block_given? ? nil : uploaded_nodes
    end

    def cat path
      result = ''
      post("cat?arg=#{CGI.escape(path)}") do |chunk|
        result << chunk
      end
      result
    end

    def get path, destination = nil
      producer = IO::StreamProducer.new do |buf|
        post("get?arg=#{CGI.escape(path)}") do |chunk|
          buf << chunk
        end
        buf.close
      end
      if destination.nil?
        return producer.stream
      else
        return IO::Tar.extract(producer.stream, destination)
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

      def resolve id = nil
        @connection.instance_exec(self) do
          if id
            JSON.parse(post("name/resolve?arg=#{CGI.escape(id)}").body)['Path']
          else
            JSON.parse(post('name/resolve').body)['Path']
          end
        end
      end

      def publish node, key = nil
        params = "arg=#{CGI.escape(node.hash)}"
        params << "&key=#{CGI.escape(key)}" if key
        @connection.instance_exec(self) do
          JSON.parse(post("name/publish?#{params}").body)['Name']
        end
      end

    end

  end

end
