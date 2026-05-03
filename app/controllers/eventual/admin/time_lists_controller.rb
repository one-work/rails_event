module Eventual
  class Admin::TimeListsController < Admin::BaseController
    before_action :set_time_list, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! default_params
      unless TimeList.default_where(q_params).exists?
        p_params = {
          default: true
        }
        p_params.merge! default_form_params
        TimeList.create(p_params)
      end

      @time_lists = TimeList.default_where(q_params).order(id: :asc).page(params[:page])
    end

    private
    def set_time_list
      @time_list = TimeList.find(params[:id])
    end

    def time_list_params
      p = params.fetch(:time_list, {}).permit(
        :name,
        :code,
        :interval_minutes,
        :item_minutes,
        :default,
        time_items_attributes: [
          :id,
          :start_at,
          :finish_at,
          :_destroy
        ]
      )
      p.merge! default_form_params
    end

  end
end
