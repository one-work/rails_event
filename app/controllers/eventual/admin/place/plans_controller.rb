module Eventual
  class Admin::Place::PlansController < Admin::PlansController
    before_action :set_place

    def index
      @plans = @place.plans.includes(:event).order(id: :desc).page(params[:page])
    end

    def sync
      @place.sync_plans
    end

    private
    def set_place
      @place = Place.find params[:place_id]
    end

  end
end
