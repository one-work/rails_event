# frozen_string_literal: true

module Eventual
  class PintotoApi
    include CommonApi

    def cities
      r = post_form 'movieapi/movie-info/get-city-list'
      r['list']
    end

    def cinemas(cityId)
      r = post_form 'movieapi/movie-info/get-cinema-list', cityId: cityId
      r['list']
    end

    def movies
      r = post_form 'movieapi/movie-info/get-hot-list'
      r['list']
    end

    def plans(cinemaId)
      r = post_form 'movieapi/movie-info/get-schedule-list', cinemaId: cinemaId
      r['list'] || []
    end

    def seats(showId)
      r = post_form 'movieapi/movie-info/get-seat', showId: showId
      if r.key?('seatData')
        r.fetch('seatData', {})
      else
        r
      end
    end

    def order_cheap(showId, seat, phone:, uid:, notify_url:, area:, changeable: 0, **options)
      r = post_form(
        'api/order/create',
        showId: showId,
        seat: seat,
        reservedPhone: phone,
        thirdOrderId: uid,
        notifyUrl: notify_url,
        acceptChangeSeat: changeable,
        area: area,
        **options
      )
    end

    def order_create(showId, seat, seat_id:, phone:, uid:, notify_url:, area:, price:, changeable: 0)
      post_form(
        'api/order/create-soon-order',
        showId: showId,
        seat: seat,
        seatNo: seat,
        seatId: seat_id,
        reservedPhone: phone,
        thirdOrderId: uid,
        notifyUrl: notify_url,
        acceptChangeSeat: changeable,
        netPrice: price,
        area: area
      )
    end

    def order(id)
      post_form 'api/order/query', thirdOrderId: id
    end

    def info
      post_form 'api/user/info'
    end

    def trigger(item_id, eventName = 'TICKET_SUCCESS')
      r = post_form(
        'api/automation/orderHandle',
        thirdOrderId: item_id,
        eventName: eventName
      )
      JSON.parse(r)
    end

    protected
    def with_access_token(tries: 2, params: {}, headers: {}, payload:, **)
      payload.merge!(
        appKey: @app.appid,
        time: Time.current.to_i
      )
      payload.merge! sign: sign_params(payload)
      yield
    end

    def sign_params(payload)
      str = "#{payload.to_query}&appSecret=#{@app.secret}"
      Digest::MD5.hexdigest(str)
    end

    def extra(body)
      if body['code'] == 200
        body['data']
      else
        body
      end
    end

  end
end