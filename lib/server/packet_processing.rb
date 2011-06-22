#encoding: utf-8
#
require "rsec"
require "json"
require "pp"

class PacketParser
  include Rsec::Helpers

  def initialize(packet_definition)
    @delimiter = packet_definition["delimiter"]
    @packet_definition = packet_definition
    self.build_parser()
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
      elsif node_type == "field" then
        node_parser = self.make_field_parser(node)
      elsif node_type == "group" then
        node_parser = self.make_group_parser(node) 
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
        if type == :field then
          hash[e[1]] = e[2]
        elsif type == :group then
          hash[e[1]] = e[2]
        else
        end
      end
      hash
    end
    return elem
  end

  def make_group_parser(node)
    node_name = node["name"]
    children = node["children"]
    elem = self.make_hash_parser(children)
    group_parser = seq(elem * (1..-1)) do |arr|
      [:group, node_name, arr[0]]
    end
    return group_parser
  end

  def make_constant_parser(node)
    node["value"].r { |token| [:constant] }
  end

  def make_field_parser(node)
    field_name = node["name"]
    max_length = node["max_length"]
    min_length = node["min_length"]
    delimiter_hex = @delimiter.to_s(16)
    pattern = "[^\\x#{delimiter_hex}]{#{min_length},#{max_length}}"
    parser = Regexp.new(pattern).r { |token| [:field, field_name, token] }
    return parser
  end

end

require 'stringio'

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

string1 = '123|TRADE9700|S20110613002|Succeed!|A111|A100|111.11|A222|A200|2.22|A333|A300|333.33||'

f = IO.read("packet_desc.js")
packets = JSON.parse(f)
packet = packets[0]
parser = PacketParser.new(packet)
result = parser.parse(string1)
p "Result:"
pp result

gen = PacketGenerator.new(packet)
p string1
string2 = gen.generate(result)
p string2
p string1 == string2
