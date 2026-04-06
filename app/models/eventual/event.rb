module Eventual
  class Event < ApplicationRecord
    include Model::Event
    include Inner::Plan
    include Inner::Recurrence

    attribute :extra, :json, default: {}
    attribute :synced_at, :datetime

    def assign_detail(m, now = Time.current)
      self.name = m['name']
      self.description = m['intro']
      self.duration_mins = m['duration']
      self.extra = m.slice('grade', 'likeNum', 'director', 'cast', 'filmTypes', 'pic')
      self.begin_on = m['publishDate']
      self.synced_at = now
      self.save

      sync_logo_later unless logo.attached?
    end

    def sync_logo_later(url = extra['pic'])
      Com::AttachedUrlSyncJob.perform_later(self, 'logo', url)
    end

    def sync_logo_now(url = extra['pic'])
      logo.url_sync(url)
    end

  end
end
