module Eventual
  class Place < ApplicationRecord
    include Model::Place
    include Detail::Ext::Listing

    def sync_plans(now = Time.current)
      app = (PintotoApp.default.take || PintotoApp.first)

      app.api.plans(ref_ident).each do |show|
        event = Event.find_by(ref_ident: show['filmId'])
        unless event
          app.update missed_event: true
        end

        hall = halls.find_or_create_by(name: show['hallName'])

        plan = event.plans.find_or_initialize_by(ref_ident: show['showId'])
        plan.place = self
        plan.hall = hall
        plan.plan_on = show['showDate']
        plan.plan_at = show['showTime']
        plan.extra = show['scheduleArea'].split(';').each_with_object({}) do |area, h|
          r = area.split(',').map(&->(i){ i.split(':') }).to_h
          h.merge! r['area'] => r
        end

        if plan.extra.blank?
          plan.extra = { '' => { 'price' => show['netPrice'] } }
        end

        plan.synced_at = now
        plan.save
      end

      plans.where(synced_at: ...now).delete_all
    end

  end
end
