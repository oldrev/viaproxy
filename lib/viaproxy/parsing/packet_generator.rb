#encoding: utf-8
#
require 'stringio'

require 'viaproxy/parsing/pipeline'

module ViaProxy

  class PacketGenerator

    def initialize(packet_definition)
      @packet_definition = packet_definition
      @pipeline = Pipeline.new()
    end

    def generate(msg)
      content_def = @packet_definition["content"]
      writer = StringIO.new
      for node in content_def
        type = node["node_type"]
        if type == "scale" then
          name = node["name"]
          self.generate_scale(writer, node, msg[name])
        elsif type == "constant" then
          self.generate_constant(writer, node)
        elsif type == "vector" then
          name = node["name"]
          self.generate_vector(writer, node, msg[name])
        end
      end
      str = writer.string
      writer.close()
      return str
    end

    def generate_vector(writer, node, msg_part)
      for item in msg_part
        node["children"].each do |subnode|
          type = subnode["node_type"]
          if type == "scale" then
            name = subnode["name"]
            self.generate_scale(writer, subnode, item[name])
          elsif type == "constant" then
            self.generate_constant(writer, subnode)
          elsif type == "vector" then
            name = subnode["name"]
            self.generate_vector(writer, subnode, item[name])
          end
        end
      end
    end

    def generate_constant(writer, node)
      writer.write(node["value"])
    end

    def generate_scale(writer, node, scale_value)
      #TODO 各种转换和后处理
      encoded_scale = @pipeline.encode(node, scale_value)
      writer.write(encoded_scale)
    end

  end


end
