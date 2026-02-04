# frozen_string_literal: true

require 'rails_com'
module RailsEvent
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir[
      "#{config.root}/app/models/plan_join"
    ]

    config.eager_load_paths += Dir[
      "#{config.root}/app/models/plan_join"
    ]

    config.generators do |g|
      g.rails = {
        assets: false,
        stylesheets: false,
        helper: false,
        jbuilder: true
      }
      g.test_unit = {
        fixture: true
      }
      g.templates.unshift File.expand_path('lib/templates', RailsCom::Engine.root)
    end

  end
end
