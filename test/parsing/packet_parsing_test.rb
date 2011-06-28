require 'test/unit'
require 'json'

$:.unshift "#{File.dirname(__FILE__)}/../../lib"

require 'viaproxy/parsing'

class PacketParsingTestCase < Test::Unit::TestCase

  LENGTH = 123
  TRADE_CODE = "TRADE9700"
  HOST_SERIAL = "S20110613002"
  HOST_MSG = "Succeed!"
  PACKET_BUFFER = 
    "#{LENGTH}|#{TRADE_CODE}|#{HOST_SERIAL}|#{HOST_MSG}|A111|A100|111.11|A222|A200|2.22|A333|A300|333.33||"
  PACKET_BUFFER2 = "#{LENGTH}|A111|111.11|A222|222.22|A333|333.33||"

  def get_packet_definition(pdl_name)
    packetdef_path = File.join(File.dirname(__FILE__), pdl_name)
    f = IO.read(packetdef_path)
    packets = JSON.parse(f)
    return packets[0]
  end

  def test_simple_parsing()
    packet = self.get_packet_definition('packet1.pdl')
    parser = ViaProxy::PacketParser.new(packet)
    result = parser.parse(PACKET_BUFFER)
    assert LENGTH == result['length']
    assert HOST_SERIAL == result['host_serial']
    assert TRADE_CODE == result['trade_code']

    details = result['details']
    assert 3 == details.size
    assert "A111" == details[0]['credit_account']
    assert "A100" == details[0]['debit_account']
    assert BigDecimal.new('111.11') == details[0]['amount']
    assert "A222" == details[1]['credit_account']
    assert "A200" == details[1]['debit_account']
    assert BigDecimal.new('2.22') == details[1]['amount']
    assert "A333" == details[2]['credit_account']
    assert "A300" == details[2]['debit_account']
    assert BigDecimal.new('333.33') == details[2]['amount']
  end

  def test_nested_loop()
    packet = self.get_packet_definition('packet2.pdl')
    parser = ViaProxy::PacketParser.new(packet)
    result = parser.parse(PACKET_BUFFER2)
    assert LENGTH == result['length']
    container = result['container']
    assert 1 == container.size
    details = container[0]["details"]
    assert 3 == details.size

    assert "A111" == details[0]['account']
    assert BigDecimal.new('111.11') == details[0]['amount']
    assert "A222" == details[1]['account']
    assert BigDecimal.new('222.22') == details[1]['amount']
    assert "A333" == details[2]['account']
    assert BigDecimal.new('333.33') == details[2]['amount']
  end

  def test_simple_generation()
    packet = self.get_packet_definition('packet1.pdl')
    parser = ViaProxy::PacketParser.new(packet)
    result = parser.parse(PACKET_BUFFER)
    gen = ViaProxy::PacketGenerator.new(packet)
    buf1 = gen.generate(result)
    assert PACKET_BUFFER == buf1
  end

end

