require "rubygems"
require "rsec"
require "json"
require "win32/process"

include Rsec::Helpers

field = prim(:double) { |v| ["field", "field_name", v] }
constant = seq("|") { |v| ["constant"] }
object_parser = seq(field, constant, field, constant) do |arr| 
  hash = {}
  for e in arr
    p e
    if e[0] != 'constant' then
      hash[e[1]] = e[2]
    end
  end
  p "==="
  p arr
  p "==="
  p hash
  hash
end
objs = (object_parser * 2)
parser = seq_(field, constant, objs, constant)

p ">>>>>>>>>>>>>>"
p parser.parse! "111.1|222.2|333.3|444.4|555.5||"

