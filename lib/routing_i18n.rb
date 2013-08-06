require 'action_controller'
require 'routing_i18n/version'
require 'routing_i18n/mapper'
require 'routing_i18n/named_route_collection'
require 'routing_i18n/resource'

module RoutingI18n
  class << self
    def resource_path(resource)
      ::I18n.t(:path, scope: [:routes, resource_kind(resource), resource.name], default: resource.name)
    end

    def resource_kind(resource)
      resource.is_a?(ActionDispatch::Routing::Mapper::Resources::SingletonResource) ? :resource : :resources
    end

    def path_names(*scope)
      ::I18n.t(:path_names, scope: [:routes, *scope].compact, throw: true) rescue {}
    end

    def suffix
      ::I18n.locale.to_s.downcase.gsub(/\-/, "_")
    end

    def url_helper_method_name_with_i18n_suffix(name)
      method_name = name.to_s.gsub(/_(path|url)\Z/, "")
      $1 && :"#{method_name}_#{RoutingI18n.suffix}_#{$1}"
    end
  end

  ::ActionDispatch::Routing::Mapper.send(:include, Mapper)
  ::ActionDispatch::Routing::Mapper::Mapping::IGNORE_OPTIONS << :i18n
  ::ActionDispatch::Routing::RouteSet::NamedRouteCollection.send(:include, NamedRouteCollection)
  ::ActionDispatch::Routing::Mapper::Resources::Resource.send(:include, Resource)
end