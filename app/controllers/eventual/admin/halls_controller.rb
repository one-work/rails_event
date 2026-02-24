module Eventual
  class Admin::HallsController < Admin::BaseController
    before_action :set_place
    before_action :set_hall, only: [:show, :edit, :update, :destroy, :actions]

    def index
      @halls = @place.halls.page(params[:page])
    end

    private
    def set_place
      @place = Place.find params[:place_id]
    end

    def set_new_hall
      @hall = @place.halls.build(hall_params)
    end

    def set_hall
      @hall = Hall.find(params[:id])
    end

    def hall_params
      params.fetch(:hall, {}).permit(
        :name
      )
    end

  end
end
