module Eventual
  class My::PlanJoinsController < My::BaseController
    before_action :set_plan
    before_action :set_new_plan_join, only: [:new, :create]

    private
    def set_plan
      @plan = Plan.find params[:plan_id]
    end

    def set_new_plan_join
      @plan_join = @plan.plan_joins.build(plan_join_params)
    end

    def plan_join_params
      _p = params.permit(
        plan_join: [:seat_no]
      )
      _p.merge! user_id: current_user.id
    end

    def batch_plan_join_params
      params.fetch(:plan, {}).permit()
    end

  end
end
