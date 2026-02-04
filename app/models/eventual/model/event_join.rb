module Eventual
  module Model::EventJoin
    extend ActiveSupport::Concern

    included do
      attribute :score, :integer
      attribute :comment, :string
      attribute :quit_note, :string
      attribute :assigned_status, :string
      attribute :job_id, :string

      belongs_to :event_crowd, optional: true
      belongs_to :event, counter_cache: true
      belongs_to :crowd_member, optional: true
      belongs_to :participant, polymorphic: true

      validates :member_id, uniqueness: { scope: [:member_type, :event_id] }

      enum :state, {
        in_studying: 'in_studying',
        request_quit: 'request_quit',
        quit: 'quit',
        in_evaluating: 'in_evaluating',
        passed: 'passed',
        failed: 'failed'
      }, default: 'in_studying'

      before_validation :sync_from_crowd_member
      after_destroy :delete_reminder_job
    end

    def sync_from_crowd_member
      if self.crowd_member
        self.member_type = crowd_member.member_type
        self.member_id = crowd_member.member_id
      end
      if self.event_crowd
        self.event_id = event_crowd.event_id
      end
    end

    def save_with_remind
      self.class.transaction do
        self.save!
      end

      return unless self.persisted?

      self.class.transaction do
        EventParticipantMailer.assign(self.id).deliver_later
        if self.event.next_start_time
          job = EventParticipantMailer.remind(self.id).deliver_later(wait_until: self.event.next_start_time - 1.day)
          self.update(job_id: job.job_id)
        end
      end
    end

    def delete_reminder_job
      ActionMailer::DeliveryJob.cancel(self.job_id) if ActionMailer::DeliveryJob.respond_to?(:cancel)
    end

  end
end
