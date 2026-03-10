module Eventual
  class My::BaseController < MyController

    def set_cart
      @cart = Trade::Cart.get_cart(
        params,
        good_type: 'Eventual::PlanJoin',
        user_id: current_user.id,
        **default_form_params
      )
    end

  end
end
