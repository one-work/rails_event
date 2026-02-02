module Eventual
  class Admin::AppsController < Admin::BaseController

    def index
      @apps = App.page(params[:page])
    end

  end
end
