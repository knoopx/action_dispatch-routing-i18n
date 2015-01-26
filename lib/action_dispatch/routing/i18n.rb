require "action_dispatch/routing"
require "action_dispatch/routing/i18n/version"

module ActionDispatch
  module Routing
    module I18n
      class << self
        def resource_path(resource)
          ::I18n.t!(:path, scope: [:routes, resource_kind(resource), resource.name])
        end

        def resource_kind(resource)
          resource.is_a?(ActionDispatch::Routing::Mapper::Resources::SingletonResource) ? :resource : :resources
        end

        def path_names(*scope)
          ::I18n.t(:path_names, scope: [:routes, *scope].compact, default: {})
        end

        def suffix
          ::I18n.locale.to_s.downcase.gsub(/\-/, "_")
        end

        def url_helper_method_name_with_locale_suffix(name)
          method_name = name.to_s.gsub(/_(path|url)\Z/, "")
          $1 && :"#{method_name}_#{suffix}_#{$1}"
        end
      end
    end
  end
end

::ActionDispatch::Routing::Mapper::Scope::OPTIONS << :locale

class ActionDispatch::Routing::RouteSet::NamedRouteCollection
  def initialize_with_locale
    initialize_without_locale

    [@url_helpers_module, @path_helpers_module].each do |mod|
      mod.class_eval do
        protected

        def method_missing(method_name, *args, &block)
          method_name_with_locale_suffix = ActionDispatch::Routing::I18n.url_helper_method_name_with_locale_suffix(method_name)
          method_name_with_locale_suffix && respond_to_without_locale?(method_name_with_locale_suffix) ?
            send(method_name_with_locale_suffix, *args, &block) : super
        end

        def respond_to_with_locale?(method_name, include_private = false)
          method_name_with_locale_suffix = ActionDispatch::Routing::I18n.url_helper_method_name_with_locale_suffix(method_name)
          method_name_with_locale_suffix && respond_to_without_locale?(method_name_with_locale_suffix) ?
            true : respond_to_without_locale?(method_name, include_private)
        end

        alias_method_chain :respond_to?, :locale
        protected :respond_to_without_locale?
      end
    end
  end

  alias_method_chain :initialize, :locale
end

class ActionDispatch::Routing::Mapper::Resources::Resource
  def initialize_with_locale(entities, options = {})
    initialize_without_locale(entities, options)
    if options.key?(:locale) && !options.key?(:path)
      @path = I18n.with_locale(options[:locale]) { ActionDispatch::Routing::I18n.resource_path(self) }
    end
  end

  alias_method_chain :initialize, :locale
end

class ActionDispatch::Routing::Mapper
  def scope_with_locale(*args, &block)
    scope_without_locale(*args) do
      if locale?
        with_locale do
          @scope[:path_names].merge!(ActionDispatch::Routing::I18n.path_names)
          if parent_resource
            @scope[:path_names].merge!(ActionDispatch::Routing::I18n.path_names(ActionDispatch::Routing::I18n.resource_kind(parent_resource), parent_resource.name))
          end
        end
      end

      instance_eval(&block)
    end
  end

  alias_method_chain :scope, :locale

  def locale?
    @scope[:locale].present?
  end

  private

  def with_locale(&block)
    I18n.with_locale(@scope[:locale], &block)
  end

  def action_options_with_locale?(options)
    options.merge!(locale: @scope[:locale]) if locale?
    action_options_without_locale?(options)
  end

  alias_method_chain :action_options?, :locale

  def merge_locale_scope(parent, child)
    if parent
      raise "Nesting locale scopes is not allowed!" if child
      parent
    else
      child
    end
  end

  def name_for_action_with_locale_suffix(as, action)
    name = name_for_action_without_locale_suffix(as, action)
    candidate = (locale? && !name.blank?) ? with_locale { [name, ActionDispatch::Routing::I18n.suffix].join("_") } : name
    candidate unless @set.routes.find { |r| r.name == candidate } || candidate !~ /\A[_a-z]/i
  end

  alias_method_chain :name_for_action, :locale_suffix
end
