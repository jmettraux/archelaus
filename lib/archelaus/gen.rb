
module Archelaus::Gen

  class << self

    def make(*args)

      Archelaus::Gen::Node.new(*args)
    end

    def wrapt(text)

      Archelaus::Gen::TextContent.new(text)
    end

    def wrapf(path)

      Archelaus::Gen::FileContent.new(path)
    end

    def makec(parent, text)

      Archelaus::Gen::Comment.new(parent, text)
    end
  end

  class Node

    attr_reader :atts

    def initialize(*args)

      parent = nil
      @tag = nil
      @atts = nil
      @children = nil

      parent = args.shift if args[0].is_a?(Archelaus::Gen::Node)
      @tag = args.shift

      fail ArgumentError.new("tag must be a Symbol or a String") \
        unless @tag.is_a?(Symbol) || @tag.is_a?(String)

      while arg = args.shift

        if arg.is_a?(Hash)
          @atts ||= arg
        elsif arg.respond_to?(:write_to_io)
          (@children ||= []) << arg
        else
          (@children ||= []) << Archelaus::Gen::TextContent.new(arg)
        end
      end

      parent << self if parent
    end

    def <<(node)

      (@children ||= []) << node

      node
    end

    def to_s(o=StringIO.new)

      write_to_io(StringIO.new).string
    end

    def write_to_io(o)

      #o << '<' << @tag
      o << "\n<" << @tag

      @atts.each { |k, v| o << ' ' << k.to_s << '=' << v.to_s.inspect } \
        if @atts

      if @children && @children.any?
        o << '>'
        @children.each { |c| c.write_to_io(o) }
        o << '</' << @tag << '>'
      else
        o << '/>'
      end

      o
    end
  end

  class TextContent

    def initialize(text)

      @text = text.to_s
    end

    def write_to_io(o)

      o << @text
    end
  end

  class FileContent

    def initialize(path)

      @path = path
    end

    def write_to_io(o)

      File.open(@path) { |f| o.write(f.read) }
    end
  end

  class Comment

    def initialize(parent, text)

      parent << self
      @text = text
    end

    def write_to_io(o)

      o << "\n<!-- " << @text << ' -->'
    end
  end
end

