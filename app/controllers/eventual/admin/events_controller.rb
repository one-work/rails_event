module Eventual
  class Admin::EventsController < Admin::BaseController
    before_action :set_event, only: [
      :show, :edit, :meet, :update, :destroy, :actions,
      :edit_plan, :update_plan
    ]
    before_action :set_event_taxons, only: [:new, :create, :edit, :update]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:type, :title, :event_taxon_id, 'id-desc', 'id-asc', 'title-asc')

      @events = Event.with_attached_logo.default_where(q_params).order(id: :desc).page(params[:page])
      @event_taxons = EventTaxon.default_where(default_params)
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

    def plan
      q_params = {}
      q_params.merge! teacher_id: current_member.id if current_member
      q_params.merge! params.permit(:type, :event_taxon_id, 'id-desc', 'id-asc', 'title-asc')
      @events = Event.default_where(q_params).page(params[:page])

      render 'index'
    end

    def update_plan
      @event.assign_attributes params.fetch(:event, {}).permit(:repeat_type)
      @event.repeat_days = nil
    end

    def meet
    end

    private
    def set_event
      @event = Event.find(params[:id])
    end

    def set_new_event
      @event = Event.new(event_params)
    end

    def set_event_taxons
      @event_taxons = EventTaxon.default_where(default_params)
    end

    def event_params
      p = params.fetch(:event, {}).permit(
        :event_taxon_id,
        :name,
        :description,
        :position,
        :author_id,
        :teacher_id,
        :price,
        :compulsory,
        :repeat_type,
        :logo,
        repeat_days: [],
        event_items_attributes: [
          :id,
          :name,
          :_destroy,
          {
            videos: [],
            documents: [],
            videos_attachments_attributes: [:id, :_destroy],
            documents_attachments_attributes: [:id, :_destroy]
          }
        ]
      )
      p.merge! default_form_params
      p
    end

  end
end
