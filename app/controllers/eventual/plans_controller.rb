module Eventual
  class PlansController < BaseController
    before_action :set_event
    before_action :set_plan, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:place_taxon_id)

      @plans = @event.plans.includes(:place, :hall).page(params[:page])

      @plan_ons = @plans.distinct(:plan_on).select(:plan_on)
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
