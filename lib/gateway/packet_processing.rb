#encoding: utf-8
#
require "rsec"
require "json"
require "win32/process"
require "pp"

class PacketParser
  include Rsec::Helpers

  def initialize(packet_definition)
    @delimiter = "|"
    @packet_definition = packet_definition
    self.build_parser()
  end

  def build_parser()
    content = @packet_definition["content"]
    @parser = self.make_container_parser(content)
  end

  def parse(string)
    result = @parser.parse! string
    return result[2][0]
  end

  def make_container_parser(node)
    parsers = []
    node_name = node["name"]
    for c in node["children"]
      node_type = c["node_type"]
      node_parser = nil
      if node_type == "constant" then
        node_parser = self.make_constant_parser(c)
      elsif node_type == "field" then
        node_parser = self.make_field_parser(c)
      elsif node_type == "container" then
        node_parser = self.make_container_parser(c) 
      end
      parsers << node_parser
    end
    elem = seq(*parsers) do |arr|
      hash = {}
      for e in arr
        type = e[0]
        if type == :field then
          hash[e[1]] = e[2]
        elsif type == :container then
          hash[e[1]] = e[2]
        else
        end
      end
      hash
    end
    container_parser = seq(elem * (1..-1)) do |arr|
      [:container, node_name, arr[0]]
    end
    return container_parser
  end

  def make_constant_parser(node)
    node["value"].r { |token| [:constant] }
  end

  def make_field_parser(node)
    field_name = node["name"]
    parser = /[^\|]+/.r { |token| [:field, field_name, token] }
    return parser
  end

end

require 'stringio'

class PacketGenerator

  def initialize(packet_definition)
    @packet_definition = packet_definition
  end

  def generate(msg)
    content_def = @packet_definition["content"]["children"]
    writer = StringIO.new
    for node in content_def
      type = node["node_type"]
      if type == "field" then
        name = node["name"]
        self.generate_field(writer, node, msg[name])
      elsif type == "constant" then
        self.generate_constant(writer, node)
      elsif type == "container" then
        name = node["name"]
        self.generate_container(writer, node, msg[name])
      end
    end
    str = writer.string
    writer.close()
    return str
  end

  def generate_container(writer, node, msg_part)
    for item in msg_part
      node["children"].each do |subnode|
        type = subnode["node_type"]
        if type == "field" then
          name = subnode["name"]
          generate_field(writer, subnode, item[name])
        elsif type == "constant" then
          generate_constant(writer, subnode)
        elsif type == "container" then
          name = subnode["name"]
          generate_container(writer, subnode, item[name])
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

string1 = '123|TRADE9700|S20110613002|Succeed!|A111|A100|111.11|A222|A200|2.22|A333|A300|333.33||'

f = IO.read("packet_desc.js")
packet = JSON.parse(f)
parser = PacketParser.new(packet)
result = parser.parse(string1)
p "Result:"
pp result

gen = PacketGenerator.new(packet)
p string1
string2 = gen.generate(result)
p string2
p string1 == string2


