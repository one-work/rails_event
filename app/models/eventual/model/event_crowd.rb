module Eventual
  module Model::EventCrowd
    extend ActiveSupport::Concern

    included do
      attribute :present_number, :integer, default: 0

      belongs_to :event
      belongs_to :crowd

      has_many :crowd_members, foreign_key: :crowd_id, primary_key: :crowd_id
      has_many :plans, dependent: :destroy
      has_many :event_joins
      has_many :events, foreign_key: :event_id, primary_key: :event_id

      after_create_commit :sync_to_event_participants
      after_destroy_commit :destroy_from_event_participants
      after_update_commit :sync_to_event_plans

      delegate :title, to: :event
      delegate :max_members, to: :place, allow_nil: true
    end

    def sync_to_event_participants
      self.crowd_members.each do |i|
        cs = self.event_participants.build(crowd_member_id: i.id)
        cs.save
      end
    end

    def sync_to_event_plans
      if saved_change_to_teacher_id?
        self.plan_items.where(teacher_id: nil).update_all(teacher_id: self.teacher_id)
      end
      if saved_change_to_room_id?
        self.plan_items.where(room_id: nil).update_all(room_id: self.room_id)
      end
    end

    def sync_to_plan_items
      self.event_id ||= event_crowd.event_id
      self.teacher_id ||= event_crowd.teacher_id
      self.room_id ||= event_crowd.room_id
    end

    def destroy_from_event_participants
      self.crowd.members.each do |i|
        cs = i.event_participants.find_by(member_id: i.id)
        cs&.destroy
      end
    end

  end
end
