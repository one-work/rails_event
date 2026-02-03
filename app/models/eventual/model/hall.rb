module Eventual
  module Model::Hall
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :rows, :integer
      attribute :cols, :integer
      attribute :min_members, :integer, default: 1
      attribute :max_members, :integer
      attribute :seats_count, :integer, default: 0

      belongs_to :place, counter_cache: true
      has_many :seats

      validates :name, presence: true
    end

  end
end
