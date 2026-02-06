module Eventual
  module Inner::Planning
    extend ActiveSupport::Concern

    included do
      has_many :crowd_participants, as: :planning
      has_many :normal_participants, as: :planning
    end

    def xx
      crowd_participants.map do |crowd_participant|
        {
          id: crowd_participant.id,
          participant_type: 'Profile',
          participant_name: crowd_participant.crowd.name,
          members: crowd_participant.crowd.members.as_json(only: [:id, :name])
        }
      end
    end

    def participant_types
      normal_participants.includes(:participant).group_by(&:participant_type).map do |participant_type, normal_participants|
        {
          participant_type: participant_type,
          participant_name: PlanParticipant.enum_i18n(:participant_type, participant_type),
          members: normal_participants.map do |normal_participant|
            {
              id: normal_participant.participant_id,
              name: normal_participant.participant.name
            }
          end
        }
      end
    end

    def all_members
      xx + participant_types
    end

  end
end
