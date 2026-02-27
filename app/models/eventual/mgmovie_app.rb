module Eventual
  class MgmovieApp < App
    attribute :agentid, :string

    def api
      return @api if defined? @api
      @api = MgmovieApi.new(self)
    end

  end
end
