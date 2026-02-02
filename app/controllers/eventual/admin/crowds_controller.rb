module Eventual
  class Admin::CrowdsController < Admin::BaseController
    before_action :set_crowd, only: [:show, :edit, :update, :destroy]

    def index
      q_params = default_params
      q_params.merge! params.permit(:name)

      @crowds = Crowd.default_where(q_params).page(params[:page])
    end

    def show
      @crowd_members = @crowd.crowd_members.includes(:member)
    end

    private
    def set_crowd
      @crowd = Crowd.find(params[:id])
    end

    def crowd_params
      p = params.fetch(:crowd, {}).permit(
        :name,
        :logo,
        :member_type
      )
      p.merge! default_form_params
    end

  end
end
