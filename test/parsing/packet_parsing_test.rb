require 'test/unit'
require 'json'

$:.unshift "#{File.dirname(__FILE__)}/../../lib"

require 'viaproxy/parsing'

class PacketParsingTestCase < Test::Unit::TestCase

  LENGTH = "123"
  TRADE_CODE = "TRADE9700"
  HOST_SERIAL = "S20110613002"
  HOST_MSG = "Succeed!"
  PACKET_BUFFER = 
    "#{LENGTH}|#{TRADE_CODE}|#{HOST_SERIAL}|#{HOST_MSG}|A111|A100|111.11|A222|A200|2.22|A333|A300|333.33||"

  def get_packet_definition()
    f = IO.read("packet_desc.js")
    packets = JSON.parse(f)
    return packets[0]
  end

  def test_parsing
    packet = self.get_packet_definition()
    parser = ViaProxy::PacketParser.new(packet)
    result = parser.parse(PACKET_BUFFER)
    assert(LENGTH == result['length'])
    assert(HOST_SERIAL == result['host_serial'])
    assert(TRADE_CODE == result['trade_code'])

  end

  def test_generation
    packet = self.get_packet_definition()
    #TODO result 写成手工的
    parser = ViaProxy::PacketParser.new(packet)
    result = parser.parse(PACKET_BUFFER)

    generator = ViaProxy::PacketGenerator.new(packet)
    string2 = generator.generate(result)
    assert(PACKET_BUFFER == string2)
  end

end

