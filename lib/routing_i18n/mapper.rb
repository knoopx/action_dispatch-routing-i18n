require 'active_support/concern'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/object/blank'

module RoutingI18n
  module Mapper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :scope, :i18n
      alias_method_chain :action_options?, :i18n
      alias_method_chain :name_for_action, :i18n_suffix
    end

    def scope_with_i18n(*args, &block)
      scope_without_i18n(*args) do
        if i18n?
          with_i18n do
            @scope[:path_names].merge!(RoutingI18n.path_names)
            if parent_resource
              @scope[:path_names].merge!(RoutingI18n.path_names(RoutingI18n.resource_kind(parent_resource), parent_resource.name))
            end
          end
        end

        instance_eval(&block)
      end
    end

    def i18n(locale, &block)
      scope(i18n: locale, &block)
    end

    def i18n?
      @scope[:i18n].present?
    end

    private

    def with_i18n(&block)
      I18n.with_locale(@scope[:i18n], &block)
    end

    def action_options_with_i18n?(options)
      options.merge!(i18n: @scope[:i18n]) if i18n?
      action_options_without_i18n?(options)
    end

    def merge_i18n_scope(parent, child)
      if parent
        raise "Nesting i18n scopes is not allowed!" if child
        parent
      else
        child
      end
    end

    def name_for_action_with_i18n_suffix(as, action)
      name = name_for_action_without_i18n_suffix(as, action)

      if !name.blank? && i18n?
        with_i18n { [name, RoutingI18n.suffix].join("_") }
      else
        name
      end
    end
  end
end