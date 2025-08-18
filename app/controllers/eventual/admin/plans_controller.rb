module Eventual
  class Admin::PlansController < Admin::BaseController
    before_action :set_time_lists
    before_action :set_plan, only: [:show, :show_calendar, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit('end_on-gte', 'begin_on-lte', :planned_type, :planned_id, :place_id, 'plan_participants.event_participant_id')
      q_params.merge! default_params

      @plans = Plan.default_where(q_params)
      @plan_items = PlanItem.default_where(q_params)
    end

    def calendar
      @time_list = TimeList.find params[:time_list_id]
      set_settings
      @events = @time_list.events(@settings[:defaultDate], @settings[:dayCount])
    end

    def new
      @plan = Plan.new
    end

    def create
      @plan = Plan.new
      @plan.time_list ||= @time_lists.default
      @plan.assign_attributes plan_params

      unless @plan.save
        render :new, locals: { model: @plan }, status: :unprocessable_entity
      end
    end

    def show
    end

    def show_calendar
      @time_list = TimeList.find params[:time_list_id]
      set_settings
      @events = @time_list.events(@settings[:defaultDate], @settings[:dayCount])

      render :calendar
    end

    def edit
    end

    def update
      @plan.assign_attributes plan_params

      unless @plan.save
        render :edit, locals: { model: @plan }, status: :unprocessable_entity
      end
    end

    def xx
      dt = params[:index].to_s
      if dt
        @plan.toggle(dt, params[:time_item_id])
      end
    end

    def destroy
      @plan.destroy
    end

    private
    def set_plan
      @plan = Plan.find(params[:id])
    end

    def set_time_lists
      q_params = {}
      q_params.merge! default_params
      @places = Place.default_where(q_params)
      @time_lists = TimeList.default_where(q_params)
      @time_list = @time_lists.default
    end

    def set_settings
      @time_list ||= @plan.time_list
      if @time_list
        @settings = {
          minTime: @time_list.min_time,
          maxTime: @time_list.max_time,
          slotDuration: @time_list.slot_duration,
          slotLabelInterval: @time_list.slot_label_interval
        }
      else
        @settings = {
          defaultDate: '2000-01-01',
          dayCount: 7,
          minTime: '07:30:00',
          maxTime: '18:30:00',
          slotDuration: '00:10',
          slotLabelInterval: '1:00'
        }
      end
      if @plan
        @settings.merge!(
          defaultDate: @plan.default_date.to_fs(:date)
        )
        @settings.merge! repeat_settings
      end
    end

    def plan_params
      p = params.fetch(:plan, {}).permit(
        :planned_type,
        :planned_id,
        :time_list_id,
        :place_id,
        :begin_on,
        :end_on,
        :repeat_type,
        repeat_days: {},
        plan_participants_attributes: [:participant_type, :participant_id, :event_participant_id]
      )
      unless p[:planned_type] || p[:planned_id]
        p.merge! params.permit(:planned_type, :planned_id)
      end
      p
    end

  end
end
