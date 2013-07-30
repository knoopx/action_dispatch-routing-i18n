require 'active_support/concern'
require 'active_support/core_ext/module/aliasing'

module RoutingI18n
  module Resource
    extend ActiveSupport::Concern

    included { alias_method_chain :initialize, :i18n }

    def initialize_with_i18n(entities, options = {})
      initialize_without_i18n(entities, options)
      if options.key?(:i18n) && !options.key?(:path)
        @path = I18n.with_locale(options[:i18n]) { RoutingI18n.resource_path(self) }
      end
    end
  end
end