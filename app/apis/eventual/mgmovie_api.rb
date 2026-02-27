# frozen_string_literal: true
module Eventual
  class MgmovieApi
    include CommonApi


    
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

  end
end
