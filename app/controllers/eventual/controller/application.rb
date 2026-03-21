module Eventual
  class Application

    private
    def set_area
      if params[:area_id]
        @area = Area.find params[:area_id]
      else
        ip = Ship::Ip.find_or_create_by(ip_address: request.remote_ip)
        area = ip.area || ip.named_area
        @area = area || Area.first
      end
    end

  end
end
