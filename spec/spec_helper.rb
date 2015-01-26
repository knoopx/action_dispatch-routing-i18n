require 'rspec'
require 'active_support/concern'
require 'action_dispatch/routing/i18n'

module Helpers
  extend ActiveSupport::Concern

  module ClassMethods
    def draw(&block)
      let(:routes) { route_set(&block) }
    end

    def route_set(&block)
      ActionDispatch::Routing::RouteSet.new.tap { |route_set| route_set.draw(&block) }
    end

    def locale(locale, data)
      before { I18n.backend.send(:translations).clear }
      before { I18n.backend.store_translations(locale, YAML.load(data)) }
    end
  end

  def route_set(&block)
    self.class.route_set(&block)
  end

  def url_for(opts)
    routes.generate_extras(opts).first
  end

  def path(named_route, *args)
    routes.url_helpers.send("#{named_route}_path", *args)
  end

  def print_routes(route_set = routes)
    width = route_set.routes.to_a.map(&:name).reject(&:blank?).map(&:length).max
    route_set.routes.to_a.each do |route|
      puts [route.name.to_s.rjust(width), route.path.spec.to_s].join("  ")
    end
  end
end

I18n.available_locales = [:en, :es, :ca]
RSpec.configure { |c| c.include Helpers }
