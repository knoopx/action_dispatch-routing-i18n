require 'active_support/concern'
require 'active_support/core_ext/module/aliasing'

module RoutingI18n
  module NamedRouteCollection
    extend ActiveSupport::Concern

    included { alias_method_chain :initialize, :i18n }

    def initialize_with_i18n
      initialize_without_i18n

      @module.class_eval do
        def method_missing(method_name, *args, &block)
          method_name_with_i18n_suffix = RoutingI18n.url_helper_method_name_with_i18n_suffix(method_name)
          method_name_with_i18n_suffix && respond_to_without_i18n?(method_name_with_i18n_suffix) ?
              send(method_name_with_i18n_suffix, *args, &block) : super
        end

        def respond_to_with_i18n?(method_name, include_private = false)
          method_name_with_i18n_suffix = RoutingI18n.url_helper_method_name_with_i18n_suffix(method_name)
          method_name_with_i18n_suffix && respond_to_without_i18n?(method_name_with_i18n_suffix) ?
              true : respond_to_without_i18n?(method_name, include_private)
        end

        alias_method_chain :respond_to?, :i18n
      end
    end
  end
end