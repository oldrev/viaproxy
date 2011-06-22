#encoding: utf-8
#
require "json"
require "pp"
require 'stringio'


module ViaProxy

  class PacketGenerator

    def initialize(packet_definition)
      @packet_definition = packet_definition
    end

    def generate(msg)
      content_def = @packet_definition["content"]
      writer = StringIO.new
      for node in content_def
        type = node["node_type"]
        if type == "field" then
          name = node["name"]
          self.generate_field(writer, node, msg[name])
        elsif type == "constant" then
          self.generate_constant(writer, node)
        elsif type == "group" then
          name = node["name"]
          self.generate_group(writer, node, msg[name])
        end
      end
      str = writer.string
      writer.close()
      return str
    end

    def generate_group(writer, node, msg_part)
      for item in msg_part
        node["children"].each do |subnode|
          type = subnode["node_type"]
          if type == "field" then
            name = subnode["name"]
            self.generate_field(writer, subnode, item[name])
          elsif type == "constant" then
            self.generate_constant(writer, subnode)
          elsif type == "group" then
            name = subnode["name"]
            self.generate_group(writer, subnode, item[name])
          end
        end
      end
    end

    def generate_constant(writer, node)
      writer.write(node["value"])
    end

    def generate_field(writer, node, field_value)
      #TODO 各种转换和后处理
      writer.write(field_value)
    end

  end



end
