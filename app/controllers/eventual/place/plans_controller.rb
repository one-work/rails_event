module Eventual
  class Place::PlansController < PlansController
    before_action :set_place
    before_action :set_plan, only: [:show]
    before_action :set_area, only: [:index]
    before_action :set_events, only: [:event]
    before_action :prepare_plans, only: [:index]

    skip_before_action :set_event

    def index
      q_params = {
        plan_on: Date.today
      }
      q_params.merge! params.permit(:plan_on)
      if @area
        area_ids = @area.self_and_descendant_ids
        q_params.merge! place_id: Place.where(area_id: area_ids).pluck(:id)
      end
      #q_params.merge! default_params

      @plans = @place.plans.where(plan_on: Date.today.., plan_at: 1.hour.since..).page(params[:page])
      @plan_ons = @plans.distinct(:plan_on).order(:plan_on).select(:plan_on).limit(4)
      @plans = @plans.includes(:event, :hall).where(q_params).order(plan_on: :asc)
    end

    def event
      @event = Event.find params[:event_id]
      @plans = @place.plans.where(event_id: params[:event_id], plan_on: Date.today, plan_at: 1.hour.since..).page(params[:page])
      @plan_ons = @plans.distinct(:plan_on).order(:plan_on).select(:plan_on).limit(4)
      @plans = @plans.includes(:hall).order(plan_at: :asc)
    end

    private
    def set_place
      @place = Place.find params[:place_id]
    end

    def set_plan
      @plan = @place.plans.find(params[:id])
    end

    def set_events
      Date.today || params[:plan_on]
      @events = @place.plans.includes(:event).where(plan_on: Date.today).select(:event_id, :plan_on).distinct
    end

    def prepare_plans
      if @place.plans.blank?
        @place.sync_plans
      end
    end

  end
end
