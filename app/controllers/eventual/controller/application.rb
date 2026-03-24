module Eventual
  module Controller::Application

    private
    def set_area
      if params[:area_id]
        @area = Area.find params[:area_id]
      else
        ip = Ship::Ip.find_or_create_by(ip_address: request.remote_ip)
        area = ip.area || ip.named_area
        @area = area
      end

      unless area.published
        @area = Area.published.first
      end
    end

  end
end
