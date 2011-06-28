#encoding: utf-8
#
#
#

require 'viaproxy/utils'

module ViaProxy

  if RUBY_PLATFORM.downcase.include?("mswin") or RUBY_PLATFORM.downcase.include?("mingw") then
    STDOUT.set_encoding Encoding.locale_charmap
  end

end
