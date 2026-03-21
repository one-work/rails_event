module Eventual
  module Model::Plan
    extend ActiveSupport::Concern

    included do
      attribute :plan_on, :date
      attribute :plan_at, :datetime
      attribute :bookings_count, :integer, default: 0
      attribute :plan_participants_count, :integer, default: 0
      attribute :repeat_index, :string
      attribute :extra, :json
      attribute :ref_ident, :string, index: true

      belongs_to :planned, polymorphic: true, optional: true

      belongs_to :time_item, optional: true
      belongs_to :time_list, optional: true
      belongs_to :place, optional: true
      belongs_to :hall, optional: true
      belongs_to :event, optional: true
      belongs_to :event_item, optional: true
      belongs_to :place_plan, foreign_key: [:event_id, :place_id, :plan_on], primary_key: [:event_id, :place_id, :plan_on], counter_cache: true, optional: true

      has_many :bookings, dependent: :destroy
      has_many :plan_attenders, dependent: :nullify
      has_many :plan_joins, dependent: :delete_all

      accepts_nested_attributes_for :plan_joins

      validates :plan_on, presence: true

      scope :valid, -> { default_where('plan_on-gte': Date.today) }

      #before_validation :sync_from_planned
      before_save :init_place_plan
    end

    def init_place_plan
      place_plan || create_place_plan
    end

    def attenders
      plan_attenders.where(attended: true).pluck(:attender_type, :attender_id).map { |i| i.join('_') }
    end

    def start_at
      time_item.start_at.change(plan_on.parts)
    end

    def finish_at
      time_item.finish_at.change(plan_on.parts)
    end

    def sync_from_planned
      if planned
        self.place_id = plan.place_id
        self.planned = plan.planned
        self.repeat_index = self.plan.repeat_index(plan_on)
        self.plan.plan_participants.each do |plan_participant|
          self.plan_participants.build plan_participant.as_json(only: [:participant_type, :participant_id, :event_participant_id, :status])
        end
      end
      if time_item
        self.time_list_id = time_item.time_list_id
      end
    end

    class_methods do

      def to_events(start_on: Date.today.beginning_of_week, finish_on: Date.today.end_of_week, **options)
        options.merge! 'plan_on-gte': start_on, 'plan_on-lte': finish_on
        cols = (start_on.to_date .. finish_on.to_date).map { |i| [i, []] }.to_h
        if options[:time_list_id]
          time_list = TimeList.find options[:time_list_id]
        elsif options.key?(:organ_id)
          time_list = TimeList.where(organ_id: options[:organ_id]).default
          options.merge! time_list_id: time_list&.id
        else
          time_list = TimeList.where(organ_id: nil).default
          options.merge! time_list_id: time_list&.id
        end
        rows = time_list.time_items.map { |i| [i, []] }.to_h

        cols.merge! PlanItem.includes(:time_item).default_where(options).group_by(&->(i){i.plan_on})
        cols.each do |date, items|
          cols[date] = rows.merge items.group_by(&->(i){i.time_item})
        end
        cols
      end

    end

  end
end
