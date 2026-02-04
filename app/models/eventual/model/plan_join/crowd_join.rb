module Eventual
  module Model::PlanJoin::CrowdJoin
    extend ActiveSupport::Concern

    included do
      belongs_to :crowd, foreign_key: :participant_id
      has_many :members, through: :crowd
    end

    def sync
      self.members.each do |member|
        self.planning.plan_attenders.find_or_create_by(attender_type: member.class_name, attender_id: member.id)
      end
    end

  end
end
