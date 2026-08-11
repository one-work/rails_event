module Eventual
  class TimeController < BaseController
    skip_forgery_protection only: [:repeat_form]

    def repeat_form
      @booking = params[:booking_type].classify.constantize.new
      @booking.repeat_type = params[:repeat_type]
      if @booking.repeat_type_changed?
        @booking.repeat_days = []
      end
    end

  end
end
