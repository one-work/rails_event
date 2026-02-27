module Eventual
  class MgmovieApp < App

    def api
      return @api if defined? @api
      @api = MgmovieApi.new(self)
    end

  end
end
