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
  end

  ::ActionDispatch::Routing::Mapper.send(:include, Mapper)
  ::ActionDispatch::Routing::RouteSet::NamedRouteCollection.send(:include, NamedRouteCollection)
  ::ActionDispatch::Routing::Mapper::Resources::Resource.send(:include, Resource)
end