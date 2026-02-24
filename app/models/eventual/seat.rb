module Eventual
  class Seat < ApplicationRecord
    include Model::Seat

    attribute :area, :string

  end
end
