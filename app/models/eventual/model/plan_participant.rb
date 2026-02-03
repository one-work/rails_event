module Eventual
  module Model::PlanParticipant
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :status, :string, comment: '默认 event_participant 有效'

      belongs_to :planning, polymorphic: true
      belongs_to :participant, polymorphic: true

      belongs_to :event_participant, optional: true

      after_initialize :xx, if: :new_record?
    end

    def xx
      if self.event_participant
        self.participant = event_participant.participant
      end
      if self.participant_type == 'Crowd'
        self.type = 'CrowdParticipant'
      else
        self.type = 'NormalParticipant'
      end
    end

    def sync
      self.planning.plan_attenders.find_or_create_by(plan_participant_id: self.id)
    end

  end
end
