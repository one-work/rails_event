module Eventual
  class Admin::Event::PlansController < Admin::PlansController
    before_action :set_event

    def index
      q_params = {}
      q_params.merge! params.permit('place.name-like', :plan_on)

      @plans = @event.plans.includes(:place).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def sync
      @place.sync_plans
    end

    private
    def set_event
      @event = Event.find params[:event_id]
    end

    def set_filter_columns
      @filter_columns = set_filter_i18n(
        'place.name-like' => { type: 'search', default: true },
        'plan_on' => { type: 'date', default: true }
      )
    end

  end
end
