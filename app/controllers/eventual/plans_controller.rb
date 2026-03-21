module Eventual
  class PlansController < BaseController
    before_action :set_event
    before_action :set_plan, only: [:show]
    before_action :set_area, only: [:index]

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

      @plans = @event.plans.where(plan_on: Date.today.., plan_at: Time.current..)
      @plan_ons = @plans.distinct(:plan_on).order(:plan_on).select(:plan_on).limit(4)
      @plans = @plans.includes(:hall, place: :area).where(q_params).page(params[:page])
    end

    def place
      @place = Place.find params[:place_id]
      @plans = @event.plans.where(place_id: params[:place_id], plan_on: Date.today, plan_at: Time.current..).page(params[:page])
      @plan_ons = @plans.distinct(:plan_on).order(:plan_on).select(:plan_on).limit(4)
      @plans = @plans.includes(:hall).order(plan_at: :asc)
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
