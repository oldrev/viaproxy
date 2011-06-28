#encoding: utf-8
#
#
#

module ViaProxy

  module Utils

    def self.get_submodules(mod)
      mod.constants.collect {|const_name| mod.const_get(const_name)}
      .select {|const| const.class == Module}
    end

  end

  def self.assert
    raise "Assertion failed !" unless yield if $DEBUG
  end

end
