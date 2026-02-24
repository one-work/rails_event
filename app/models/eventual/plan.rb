module Eventual
  class Plan < ApplicationRecord
    include Model::Plan
    include Inner::Planning

    attribute :synced_at, :datetime
    attribute :seats, :json

    def sync_seats
      api = (PintotoApp.default.take || PintotoApp.first).api

      r = api.seats(ref_ident)
      if r && r.key?('seats')
        _seats = r['seats']
      else
        puts r
        return r
      end

      self.seats = _seats.group_by { |i| i['rowNo'] }
      self.save

      hall.update(
        cols: _seats.maximum(->(i){ i['columnNo'].to_i }),
        rows: _seats.maximum(->(i){ i['rowNo'].to_i })
      )
      _seats.each do |s|
        seat = hall.seats.load.find { |i| i.name == s['seatNo'] } || hall.seats.build(name: s['seatNo'])
        seat.place_id = place_id
        seat.row = s['rowNo']
        seat.col = s['columnNo']
        seat.area = s['area']
        seat.ref_ident = s['seatId']
        seat.save
      end

      {}
    end

    def sorted_seats
      (seats || {}).transform_values do |arr|
        arr.each_with_object({}) { |i, h| h.merge! i['columnNo'] => i }
      end
    end

  end
end
