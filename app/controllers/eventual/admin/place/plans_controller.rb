module Eventual
  class Admin::Place::PlansController < Admin::PlansController
    before_action :set_place

    def index
      @plans = @place.plans.page(params[:page])
    end

    def sync
      @place.sync_movies
    end

    private
    def set_place
      @place = Place.find params[:place_id]
    end

  end
end
