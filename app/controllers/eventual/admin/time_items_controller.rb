module Eventual
  class Admin::TimeItemsController < Admin::BaseController
    before_action :set_time_list, except: [:default]
    before_action :set_time_item, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_time_item, only: [:new, :create]

    def index
      @time_items = @time_list.time_items.page(params[:page])
    end

    def default
      q_params = {}
      q_params.merge! default_params
      time_list = TimeList.default_where(q_params).default
      if time_list
        @time_items = time_list.time_items
      else
        @time_items = TimeItem.none
      end
    end

    def select
      @time_items = @time_list.time_items

      if @time_items
        @results = @time_items.map { |x| { value: x.id, text: x.name, name: x.name } }
      end

      respond_to do |format|
        format.js
        format.json { render json: { values: @results } }
      end
    end

    private
    def set_time_list
      @time_list = TimeList.find params[:time_list_id]
    end

    def set_time_item
      @time_item = TimeItem.find(params[:id])
    end

    def set_new_time_item
      @time_item = @time_list.time_items.build(time_item_params)
    end

    def time_item_params
      params.fetch(:time_item, {}).permit(
        :start_at,
        :finish_at,
        :position
      )
    end

  end
end
