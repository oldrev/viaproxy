#encoding: utf-8

import pyparsing

class Parser:
    DECIMAL_NUMBERS = pyparsing.Word(pyparsing.nums)
    POINT = pyparsing.Literal('.')
    FIELD_PARSERS = {
        "string": pyparsing.Empty(),
        "nums": DECIMAL_NUMBERS,
        "alphanums": pyparsing.Word(pyparsing.alphanums),
        "decimal": pyparsing.Combine(DECIMAL_NUMBERS + POINT + pyparsing.Optional(DECIMAL_NUMBERS)),
    }

    def __init__(self, packet):
        self.node_parser = {
            "field" : self.parse_field_node,
            "container" : self.parse_container_node,
            "constants" : self.parse_constants_node,
        }
        self.stack = []
        self.packet = packet
        self.parser = pyparsing.StringStart() + self.__build_parser() + pyparsing.StringEnd()

    def parse_packet(self, bstring):
        self.stack = []
        return self.parser.parseString(bstring, True)

    #Build the PyParsing Parser
    def __build_parser(self):
        parser = self.parse_container_node(self.packet["content"])
        print parser
        return parser

    def parse_field_node(self, node):
        assert node["node_type"] == "field"
        char_type = node["char_type"]
        parser = Parser.FIELD_PARSERS[char_type]
        if char_type == 'string':
            parser = pyparsing.CharsNotIn("|")#self.packet["delimiter"])
        assert parser != pyparsing.Empty
        required = node["required"]
        if not required:
            assert self.packet["variable_length"]
            parser = pyparsing.Optional(parser)
        parser.setParseAction(
                lambda str,loc,toks: self.stack.append(("field", node["name"], toks[0])))
        return parser

    def parse_container_node(self, node):
        assert node["node_type"] == "container"
        seq = pyparsing.Empty()
        for c in node["children"]:
            subparser = self.node_parser[c["node_type"]]
            seq = seq + subparser(c)
        parser = node["required"] and pyparsing.OneOrMore(seq) or pyparsing.ZeroOrMore(seq)
        parser.setParseAction(
                lambda str,loc,toks: self.stack.append(("container", node["name"], toks[0])))
        return parser

    def parse_constants_node(self, node):
        assert node["node_type"] == "constants"
        parser = pyparsing.Literal(node["value"])
        return parser

import json

string1 = b"123|TRADE9700|S20110613002|操作成功！|A123|A321|124.00|A111|A222|3.22|A333|A444|322.23||";
with open("packet.js", "r") as f:
    packet1 = json.load(f)
    p = Parser(packet1)
    parsed = p.parse_packet(string1)
    print parsed
    print "Stack: =====================>"
    print p.stack
