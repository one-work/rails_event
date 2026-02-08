module Eventual
  class Place::PlansController < PlansController
    before_action :set_place
    before_action :set_plan, only: [:show]
    before_action :set_areas, only: [:index]
    before_action :set_area, only: [:index]

    skip_before_action :set_event

    def index
      q_params = {
        plan_on: Date.today
      }
      q_params.merge! params.permit(:plan_on)
      if params[:area_id]
        q_params.merge! place_id: Place.where(area_id: params[:area_id]).pluck(:id)
      end

      #q_params.merge! default_params

      @plans = @place.plans.where(plan_on: Date.today..).page(params[:page])

      @plan_ons = @plans.distinct(:plan_on).select(:plan_on)
      @plans = @plans.includes(:event, :hall).where(q_params)
    end

    def place
      @place = Place.find params[:place_id]
      @plans = @event.plans.where(place_id: params[:place_id], plan_on: Date.today).page(params[:page])
      @plan_ons = @plans.distinct(:plan_on).select(:plan_on)

      @plans = @plans.includes(:hall).order(plan_at: :asc)
    end

    private
    def set_place
      @place = Place.find params[:place_id]
    end

    def set_plan
      @plan = @place.plans.find(params[:id])
    end

    def set_areas
      area = Area.find_by(full: '河北省') || Area.first
      @areas = area.children
    end

    def set_area
      if params[:area_id]
        @area = Area.find params[:area_id]
      else
        @area = Area.find_by(full: '河北省') || Area.first
      end
    end

  end
end
