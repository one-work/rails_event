module Eventual
  module Model::App
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :appid, :string, index: true
      attribute :secret, :string
      attribute :base_url, :string
      attribute :default, :boolean

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      scope :default, -> { where(default: true) }

      after_save :set_default, if: -> { default? && saved_change_to_default? }
    end

    def set_default
      self.class.where.not(id: self.id).where(organ_id: organ_id).update_all(default: false)
    end

  end
end
