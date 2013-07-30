require 'active_support/concern'
require 'active_support/core_ext/module/aliasing'

module RoutingI18n
  module NamedRouteCollection
    extend ActiveSupport::Concern

    included { alias_method_chain :initialize, :i18n }

    def initialize_with_i18n
      initialize_without_i18n

      @module.class_eval do
        def method_missing(name, *args, &block)
          method_name = :"#{name.to_s.gsub(/_(path|url)\Z/, "")}_#{RoutingI18n.suffix}_#{$1}"
          respond_to?(method_name) ? send(method_name, *args, &block) : super
        end
      end
    end
  end
end