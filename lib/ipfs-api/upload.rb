module IPFS; end
module IPFS::Upload

  ##
  # Define a file with the given name.
  #    file = IPFS::Upload.file('hello.txt') do |fd|
  #      fd.write 'Hello'
  #    end
  #    ipfs.add file do |node|
  #      print "Successfully uploaded #{node.path}\n" if node.finished?
  #    end
  def file name, content = nil, &block
    FileNode.new(name, content, &block)
  end

  ##
  # Define a folder with the given *name*.
  #    folder = IPFS::Upload.folder('test') do |test|
  #      test.add_file('hello.txt') do |fd|
  #        fd.write 'Hello'
  #      end
  #    end
  #    ipfs.add folder do |node|
  #      print "Successfully uploaded #{node.path}\n" if node.finished?
  #    end
  def folder name, &block
    FolderNode.new(name, &block)
  end

  module_function :file, :folder

  private

    class Node # :nodoc:

      attr_accessor :name, :parent, :bytes, :hash

      def initialize name, parent = nil
        raise "Name #{} must be a String" if not name.is_a?(String)
        @name = name
        @parent = parent
      end

      def path
        @parent.nil? ? "/#{@name}" : "#{@parent.path}/#{@name}"
      end

      def file?
        false
      end

      def folder?
        false
      end

      def to_s
        inspect
      end

      def finished?
        !@hash.nil?
      end

      def inspect
        s = "<#{@name}"
        s << ":#{@bytes}" if defined?(@bytes)
        s << ":#{@hash}" if defined?(@hash)
        s << '>'
      end

    end

    class FileNode < Node # :nodoc:

      attr_reader :content

      def initialize name, parent = nil, content = nil
        super(name, parent)
        if block_given?
          @content = ''
          yield self
        else
          @content = content.to_s
        end
      end

      def write s
        @content << s
      end

      def file?
        true
      end

      def inspect
        "file:#{super}"
      end

    end

    class FolderNode < Node # :nodoc:

      attr_accessor :children

      def initialize name, parent = nil, &block
        super(name, parent)
        @children = []
        block.call(self) if block_given?
      end

      def folder?
        true
      end

      def add_node node
        node.parent = self
        (@children << node).last
      end

      def add_file file, content = nil, &block
        (@children << FileNode.new(file, self, content, &block)).last
      end

      def add_folder folder, &block
        (@children << FolderNode.new(folder, self, &block)).last
      end

      def inspect
        "folder:#{super}#{children}"
      end

    end

    module TreeWalker # :nodoc:

      def depth_first nodes
        nodes = [ nodes ] if not nodes.is_a?(Array)
        stack = [ [ nodes.shift, 0 ] ]
        Enumerator.new do |yielder|
          while not stack.empty?
            node, depth = stack.pop
            node = resolve_node(node)
            next if not node
            yielder << [ node, depth ]
            if node.folder?
              stack += node.children.reverse.map { |n| [ n, depth + 1 ] }
            end
            if stack.empty? and not nodes.empty?
              stack << [ nodes.shift, 0 ]
            end
          end
        end
      end

      def resolve_node node
        if node.is_a?(Node)
          node
        elsif node.is_a?(Dir)
          FolderNode.new(File.basename(node.path)) do |d|
            node.each do |child|
              if child != '.' and child != '..'
                child_path = File.join(node.path, child)
                if File.directory?(child_path)
                  d.add_node resolve_node(Dir.new(child_path))
                else
                  d.add_node resolve_node(File.new(child_path))
                end
              end
            end
          end
        elsif node.is_a?(File)
          FileNode.new(File.basename(node.path)) do |d|
            d.write File.read(node.path)
          end
        end
      end

      module_function :depth_first, :resolve_node

    end

end
