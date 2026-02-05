module Eventual
  class EventsController < BaseController

    def index
      @events = Event.includes(logo_attachment: :blob).page(params[:page])
    end

    def summary
      @events = Event.default_where(default_params)
      x = []
      @events.each do |event|
        event.next_days(start: params[:start], finish: params[:end]).each do |date|
          x << {
            start: date.to_fs(:date),
            classNames: ['bg_kapi'],
            display: 'background',
            extendedProps: { img: event.logo.url }
          }
        end
      end

      render json: x
    end

  end
end
