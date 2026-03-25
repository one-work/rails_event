module Eventual
  class PlansController < BaseController
    before_action :set_event
    before_action :set_plan, only: [:show]
    before_action :set_area, only: [:index]

    def index
      q_params = {
        'plan_on' => Date.today
      }
      q_params.merge! params.permit(:plan_on, 'place.name-like')
      if @area
        area_ids = @area.self_and_descendant_ids
        q_params.merge! place_id: Place.where(area_id: area_ids).pluck(:id)
      end
      #q_params.merge! default_params

      @plan_ons = @event.plans.where(plan_on: Date.today..).distinct(:plan_on).order(:plan_on).select(:plan_on).limit(4)
      place_ids = @event.plans.where(plan_at: 1.hour.since..).where(q_params).select(:place_id, :plan_on).distinct.map(&:place_id)
      @place_plans = PlacePlan.includes(:place, :plans).where(place_id: place_ids, event_id: @event.id).default_where(q_params.slice('plan_on', 'place.name-like')).page(params[:page])
    end

    def place
      @place = Place.find params[:place_id]
      @plan_ons = @event.plans.where(place_id: params[:place_id], plan_on: Date.today, plan_at: 1.hour.since..).distinct(:plan_on).order(:plan_on).select(:plan_on).limit(4)
      @plans = @event.plans.where(place_id: params[:place_id], plan_on: Date.today, plan_at: 1.hour.since..).includes(:hall).order(plan_at: :asc).page(params[:page])
    end

    def show
      r = @plan.sync_seats
      if r['code'] == 500
        render 'err', locals: { message: r['message'] }
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
