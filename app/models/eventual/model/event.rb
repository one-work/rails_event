module Eventual
  module Model::Event
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string, limit: 4096
      attribute :position, :integer
      attribute :event_participants_count, :integer, default: 0
      attribute :event_items_count, :integer, default: 0
      attribute :members_count, :integer, default: 0
      attribute :duration_mins, :integer
      attribute :ref_ident, :string, comment: '外部资源关联 ID'

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :event_taxon, optional: true
      has_many :event_items, dependent: :nullify
      accepts_nested_attributes_for :event_items, allow_destroy: true

      has_many :event_participants, dependent: :destroy
      has_many :crowds, through: :event_participants
      has_many :event_grants, dependent: :destroy
      has_many :plans, dependent: :delete_all
      has_many :planned_places, class_name: 'Place', through: :plans, source: :place

      has_one_attached :logo
    end

    def member_type_ids
      event_participants.pluck(:member_type, :member_id)
    end

    def save_with_remind
      self.class.transaction do
        self.save!
      end

      return unless self.persisted?

      self.class.transaction do
        EventParticipantMailer.assign(self.id).deliver_later
        job = EventParticipantMailer.remind(self.id).deliver_later(wait_until: self.event.next_start_at - 1.day)
        self.update(job_id: job.job_id)
      end
    end

    def timestamp
      self.event_participants.order(created_at: :desc).first&.created_at.to_i
    end

  end
end
