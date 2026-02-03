module Eventual
  class PlansController < BaseController
    before_action :set_event
    before_action :set_place, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:place_taxon_id)

      @place_taxons = PlaceTaxon.default_where(default_params)
      @places = Place.default_where(q_params).page(params[:page])
    end

    private
    def set_event
      @event = Event.find params[:event_id]
    end

    def set_plan
      @plan = @event.plans.find(params[:id])
    end

  end
end
