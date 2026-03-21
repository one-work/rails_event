module Eventual
  module Model::PlacePlan
    extend ActiveSupport::Concern

    included do
      attribute :plan_on, :date, index: true
      attribute :plans_count, :integer, default: 0

      belongs_to :place
      belongs_to :event

      has_many :plans, primary_key: [:event_id, :place_id, :plan_on], foreign_key: [:event_id, :place_id, :plan_on]
    end

  end
end
