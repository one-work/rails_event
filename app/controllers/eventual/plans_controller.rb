module Eventual
  class PlansController < BaseController
    before_action :set_event
    before_action :set_plan, only: [:show]

    def index
      q_params = {
        plan_on: Date.today
      }
      q_params.merge! params.permit(:plan_on)
      #q_params.merge! default_params

      @plans = @event.plans.where(plan_on: Date.today..).page(params[:page])

      @plan_ons = @plans.distinct(:plan_on).select(:plan_on)
      @plans = @plans.includes(:place, :hall).where(q_params)
    end

    def place
      @place = Place.find params[:place_id]
      @plans = @event.plans.where(place_id: params[:place_id], plan_on: Date.today).page(params[:page])
      @plan_ons = @plans.distinct(:plan_on).select(:plan_on)

      @plans = @plans.includes(:hall).order(plan_at: :asc)
    end

    def show
      if @plan.seats.blank?
        @plan.sync_seats
      end
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
