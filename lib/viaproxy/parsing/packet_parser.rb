#encoding: utf-8
#
require "rsec"
require "json"
require "pp"

require 'viaproxy/parsing/pipeline'

module ViaProxy

  class PacketParser
    include Rsec::Helpers

    def initialize(packet_definition)
      @delimiter = packet_definition["delimiter"]
      @packet_definition = packet_definition
      self.build_parser()
      @pipeline = Pipeline.new()
    end

    def build_parser()
      content = @packet_definition["content"]
      elem = self.make_hash_parser(content)
      @parser = seq(elem * (1..-1)).eof() do |arr|
        arr[0][0]
      end
    end

    def parse(string)
      result = @parser.parse!(string)
      return result
    end

    def make_parser_by_type(node)
      node_type = node["node_type"]
      node_parser = nil
      if node_type == "constant" then
        node_parser = self.make_constant_parser(node)
      elsif node_type == "scale" then
        node_parser = self.make_scale_parser(node)
      elsif node_type == "vector" then
        node_parser = self.make_vector_parser(node) 
      end
    end

    def make_hash_parser(nodes)
      parsers = []
      for c in nodes
        node_parser = make_parser_by_type(c)
        parsers << node_parser
      end
      elem = seq(*parsers) do |arr|
        hash = {}
        for e in arr
          type = e[0]
          if type == :scale then
            hash[e[1]] = e[2]
          elsif type == :vector then
            hash[e[1]] = e[2]
          else
          end
        end
        hash
      end
      return elem
    end

    def make_vector_parser(node)
      node_name = node["name"]
      children = node["children"]
      elem = self.make_hash_parser(children)
      vector_parser = seq(elem * (1..-1)) do |arr|
        [:vector, node_name, arr[0]]
      end
      return vector_parser
    end

    def make_constant_parser(node)
      node["value"].r { |token| [:constant] }
    end

    def make_scale_parser(node)
      scale_name = node["name"]
      max_length = node["max_length"]
      min_length = node["min_length"]
      delimiter_hex = @delimiter.to_s(16)
      pattern = "[^\\x#{delimiter_hex}]{#{min_length},#{max_length}}"
      parser = Regexp.new(pattern).r do |token| 
        #执行流水线
        scale_value = @pipeline.decode(node, token)
        [:scale, scale_name, scale_value] 
      end
      return parser
    end

  end

end
