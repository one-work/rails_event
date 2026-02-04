module Eventual
  class My::PlanJoinsController < My::BaseController
    before_action :set_plan

    def create
      @order = current_user.orders.build
      Array(params[:plan_join]).each do |pj|
        plan_join = @plan.plan_joins.find_or_initialize_by(seat_no: pj[:seat_no])
        plan_join.user = current_user
        plan_join.save

        @order.items.build(
          good_type: plan_join.base_class_name,
          good_id: plan_join.id,
          aim: 'use'
        )
      end
    end

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
