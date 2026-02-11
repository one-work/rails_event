module Eventual
  class PlansController < BaseController
    before_action :set_event
    before_action :set_plan, only: [:show]
    before_action :set_areas, only: [:index]
    before_action :set_area, only: [:index]

    def index
      q_params = {
        plan_on: Date.today
      }
      q_params.merge! params.permit(:plan_on)
      if params[:area_id]
        q_params.merge! place_id: Place.where(area_id: params[:area_id]).pluck(:id)
      end

      #q_params.merge! default_params

      @plans = @event.plans.where(plan_on: Date.today.., plan_at: Time.current..).page(params[:page])

      @plan_ons = @plans.distinct(:plan_on).select(:plan_on)
      @plans = @plans.includes(:place, :hall).where(q_params)
    end

    def place
      @place = Place.find params[:place_id]
      @plans = @event.plans.where(place_id: params[:place_id], plan_on: Date.today, plan_at: Time.current..).page(params[:page])
      @plan_ons = @plans.distinct(:plan_on).select(:plan_on)

      @plans = @plans.includes(:hall).order(plan_at: :asc)
    end

    def show
      if @plan.seats.blank?
        r = @plan.sync_seats
        if r['code'] == 500
          render 'err', locals: { message: r['message'] }
        end
      end
    end

    private
    def set_event
      @event = Event.find params[:event_id]
    end

    def set_plan
      @plan = @event.plans.find(params[:id])
    end

    def set_areas
      area = Area.published.first
      @areas = area.children
    end

    def set_area
      if params[:area_id]
        @area = Area.find params[:area_id]
      else
        @area = Area.published.first
      end
    end

  end
end
