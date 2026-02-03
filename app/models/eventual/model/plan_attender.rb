module Eventual
  module Model::PlanAttender
    extend ActiveSupport::Concern

    included do
      attribute :attended, :boolean, default: false
      attribute :state, :string
      attribute :extra, :json

      belongs_to :plan_participant, optional: true
      belongs_to :attender, polymorphic: true
      belongs_to :plan_item
      belongs_to :plan
      belongs_to :place

      enum :state, {
        absent: 'absent'  # 请假
      }

      after_initialize if: :new_record? do

      end
    end

    def xx
      if plan_item
        self.assign_attributes plan_item.as_json(only: [:place_id])
      end
      if plan_participant
        self.attender = plan_participant.participant
      end
    end

  end
end
