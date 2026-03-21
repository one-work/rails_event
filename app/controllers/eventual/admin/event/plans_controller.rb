module Eventual
  class Admin::Event::PlansController < Admin::PlansController
    before_action :set_event

    def index
      @plans = @event.plans.includes(:place).order(id: :desc).page(params[:page])
    end

    def sync
      @place.sync_plans
    end

    private
    def set_event
      @event = Event.find params[:event_id]
    end

  end
end
