module Eventual
  class EventJoin < ApplicationRecord
    include Model::EventJoin
    include Com::Ext::StateMachine
  end
end
