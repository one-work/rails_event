module Eventual
  module Model::Place
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string
      attribute :address, :string
      attribute :tel, :string
      attribute :color, :string
      attribute :seats_count, :integer, default: 0
      attribute :halls_count, :integer, default: 0
      attribute :plans_count, :integer, default: 0
      attribute :ref_ident, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :area, class_name: 'Ship::Area', optional: true

      belongs_to :place_taxon, counter_cache: true, optional: true
      belongs_to :taxon, class_name: 'PlaceTaxon', optional: true, foreign_key: :place_taxon_id

      has_many :plans
      has_many :halls
      has_many :seats, dependent: :delete_all

      validates :name, presence: true

      has_taxons :place_taxon
    end

  end
end
