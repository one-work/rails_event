module Eventual
  class Plan < ApplicationRecord
    include Model::Plan
    include Inner::Planning
  end
end
