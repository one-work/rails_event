module Eventual
  class MgmovieApi
    include CommonApi

    def cities
      r = post '6214598156852'
    end

    def movies(type: 0)
      post '621458c86a46f', type: type
    end

    def order_get(uuid)
      post '623829f7a2be4', order_number: uuid
    end

    protected
    def with_access_token(tries: 2, params: {}, headers: {}, payload:, **)
      payload.merge!(
        agent_id: @app.agentid,
        app_id: @app.appid
      )
      payload.merge! signid: sign_params(payload)
      yield
    end

    def sign_params(payload)
      full = payload.sort.each_with_object('') do |(k, v), str|
        str << "#{k}#{v}"
      end
      Digest::MD5.hexdigest("#{full}#{@app.secret}")
    end

    def extra(body)
      if body['success']
        body['data']
      else
        body
      end
    end

  end
end
