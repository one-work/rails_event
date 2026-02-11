module Eventual
  class Admin::SeatsController < Admin::BaseController
    before_action :set_place
    before_action :set_seat, only: [:show, :edit, :update, :destroy, :actions]

    def index
      @seats = @place.seats.page(params[:page])
    end

    private
    def set_place
      @place = Place.find params[:place_id]
    end

    def set_new_seat
      @seat = @place.seats.build(seat_params)
    end

    def set_seat
      @seat = Seat.find(params[:id])
    end

    def seat_params
      params.fetch(:seat, {}).permit(
        :name,
        :max_members,
        :min_members
      )
    end

  end
end
