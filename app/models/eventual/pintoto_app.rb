module Eventual
  class PintotoApp < App

    attribute :extra, :json

    def api
      return @api if defined? @api
      @api = PintotoApi.new(self)
    end

    def sync_movies(now = Time.current)
      api.movies.each do |m|
        event = Event.find_or_initialize_by(ref_ident: m['filmId'])
        event.assign_detail(m, now)
      end

      Event.where(synced_at: ...now).destroy_all
    end

    def sync_movies_later
      MovieSyncJob.perform_later(self)
    end

    def sync_cities
      lost = []

      api.cities.each do |city|
        area = Ship::Area.find_by(name: city['regionName'])
        if area
          area.update(pintoto_ident: city['cityId'])
        else
          lost << city
        end
      end

      lost
    end

    def sync_cinemas
      Ship::Area.where.not(pintoto_ident: nil).each do |area|
        api.cinemas(area.pintoto_ident).each do |c|
          place = Place.find_or_initialize_by(ref_ident: c['cinemaId'])
          place.area_id = area.id
          place.name = c['cinemaName']
          place.address = c['address']
          place.tel = c['phone']
          place.save
        end
      end
    end

    def sync_plans

    end

    def sync_info!
      self.extra = api.info
      self.save
    end

    def balance(base = -166770000)
      (extra['balance'] - base) / 100.0
    end

  end
end
