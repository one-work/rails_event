module Eventual
  module Model::Seat
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :row, :integer
      attribute :col, :integer
      attribute :min_members, :integer, default: 1
      attribute :max_members, :integer
      attribute :ref_ident, :string

      belongs_to :place, counter_cache: true
      belongs_to :hall, counter_cache: true, optional: true

      has_many :plans

      validates :name, presence: true
    end

  end
end
