module Eventual
  class PlanJoin < ApplicationRecord
    include Model::PlanJoin
    include Trade::Ext::Good

    attribute :seat_no, :string
    attribute :res, :json
    belongs_to :seat, foreign_key: [:hall_id, :seat_no], primary_key: [:hall_id, :name]

    before_create :set_price

    def good_name
      "#{plan.event.name}-#{seat_no}-#{plan.plan_at.to_fs(:short_cn)}"
    end

    def set_price
      _price = plan.extra.dig(seat.area.to_s, 'price').to_i / 100.0
      if _price > 0
        self.price = _price
      else
        self.price = 100
      end

      self.wallet_price = WalletGood.where(good_type: 'Eventual::PlanJoin').each_with_object({}) do |wg, h|
        h.merge! wg.code => price * wg.ratio
      end
    end

    def order_deliverable(item)
      api = (PintotoApp.default.take || PintotoApp.first).api

      r = api.order_cheap(
        plan.ref_ident,
        seat_no,
        phone: '18571856813',
        uid: item.id,
        notify_url: Rails.app.routes.url_for(controller: 'home', action: 'pintoto'),
        area: seat.area,
        netPrice: (price * 100).to_i
      )
      self.update res: r
    end

    def order_create(item)
      api = (PintotoApp.default.take || PintotoApp.first).api

      r = api.order_create(
        plan.ref_ident,
        seat_no,
        seat_id: seat.ref_ident,
        phone: '18571856813',
        uid: item.id,
        notify_url: Rails.app.routes.url_for(controller: 'home', action: 'pintoto'),
        area: seat.area,
        price: (price * 100).to_i
      )
      self.update res: r
    end

  end
end
