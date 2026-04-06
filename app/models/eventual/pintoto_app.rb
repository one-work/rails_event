module Eventual
  class PintotoApp < App

    def api
      return @api if defined? @api
      @api = PintotoApi.new(self)
    end

  end
end
