#encoding: utf-8
#

require 'viaproxy/utils'
require 'viaproxy/parsing/internal_filters'

module ViaProxy

  class Pipeline

    def initialize()
      self.load_internal_filters()
    end

    def load_internal_filters()
      #加载内部过滤器
      mods = ViaProxy::Utils::get_submodules(InternalFilters)
      @filters = {}
      for filter in mods
        @filters[filter::NAME] = filter
      end
    end

    def decode(node, raw_data)
      pipeline = node.has_key?('pipeline') ? node['pipeline'] : []
      data = raw_data
      for filter in pipeline
        data = @filters[filter].send(:decode, data)
      end
      return data
    end

    def encode(node, raw_data)
      pipeline = node.has_key?('pipeline') ? node['pipeline'] : []
      pileline = pipeline.reverse
      data = raw_data
      for filter in pipeline
        data = @filters[filter].send(:encode, data)
      end
      return data
    end

  end

end
