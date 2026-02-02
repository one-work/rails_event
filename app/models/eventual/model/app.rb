module Eventual
  module Model::App
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :appid, :string, index: true
      attribute :secret, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
    end

  end
end
