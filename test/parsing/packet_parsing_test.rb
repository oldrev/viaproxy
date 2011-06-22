require 'test/unit'
require 'json'

$:.unshift "#{File.dirname(__FILE__)}/../../lib"

require 'viaproxy/parsing/packet_parser'
require 'viaproxy/parsing/packet_generator'

class PacketParsingTestCase < Test::Unit::TestCase

  def test_parsing_and_generation

    f = IO.read("packet_desc.js")
    packets = JSON.parse(f)
    packet = packets[0]

    parser = ViaProxy::PacketParser.new(packet)
    string1 = '123|TRADE9700|S20110613002|Succeed!|A111|A100|111.11|A222|A200|2.22|A333|A300|333.33||'
    result = parser.parse(string1)
    gen = ViaProxy::PacketGenerator.new(packet)
    string2 = gen.generate(result)
    assert(p string1 == string2)
  end

end

