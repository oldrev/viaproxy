#encoding: utf-8

import pyparsing

class Parser:
    DECIMAL_NUMBERS = pyparsing.Word(pyparsing.nums)
    POINT = pyparsing.Literal('.')

    def __init__(self, packet):
        self.node_parser = {
            "field" : self.parse_field_node,
            "container" : self.parse_container_node,
            "constant" : self.parse_constant_node,
        }
        self.stack = []
        self.packet = packet
        self.aaa = ""
        self.delimiters = b""
        for c in packet["delimiter"]:
            self.delimiters += chr(c)

        self.field_parsers = {
            "string": pyparsing.CharsNotIn(self.delimiters),
            "nums": Parser.DECIMAL_NUMBERS,
            "alphanums": pyparsing.Word(pyparsing.alphanums),
            "decimal": pyparsing.Combine(Parser.DECIMAL_NUMBERS + Parser.POINT + pyparsing.Optional(Parser.DECIMAL_NUMBERS)),
        }

        self.parser = self.__build_parser()

    def parse_packet(self, bstring):
        self.stack = []
        return self.parser.parseString(bstring, True)

    #Build the PyParsing Parser
    def __build_parser(self):
        parser = self.parse_container_node(self.packet["content"])
        pyparsing.StringStart() + parser +  pyparsing.StringEnd()
        return parser

    def parse_field_node(self, node):
        assert node["node_type"] == "field"
        char_type = node["char_type"]
        parser = self.field_parsers[char_type]
        required = node["required"]
        if not required:
            assert self.packet["variable_length"]
            parser = pyparsing.Optional(parser)

        def field_action(str, loc, toks):
            self.stack.append(("field", node["name"], toks[0]))
        parser.setParseAction(field_action)
        parser.setResultsName(node["name"])
        return parser

    def parse_container_node(self, node):
        assert node["node_type"] == "container"
        seq = pyparsing.Empty()
        for c in node["children"]:
            subparser = self.node_parser[c["node_type"]]
            seq = seq + subparser(c)
        parser = node["required"] and pyparsing.OneOrMore(seq) or pyparsing.ZeroOrMore(seq)

        def container_action(str, loc, toks):
            self.stack.append(("container", node["name"], toks[0]))

        parser.setParseAction(container_action)
        parser.setResultsName(node["name"])
        return parser

    def parse_constant_node(self, node):
        assert node["node_type"] == "constant"
        parser = pyparsing.Literal(node["value"])
        return parser


import json

string1 = b"123|TRADE9700|S20110613002|操作成功！|A123|A321|124.00|A111|A222|3.22|A333|A444|322.23||"

msg = {}
new_stack = []
with open("packet.js", "r") as f:
    packet1 = json.load(f)
    p = Parser(packet1)
    print "Parser: ===========================>"
    print p.parser
    parsed = p.parse_packet(string1)
    print "Result: ===========================>"
    print parsed.asDict()
    print "Stack: ============================>"
    print p.stack
    msg = p.stack
    new_stack = p.stack[:]

