module Eventual
  class PlacesController < BaseController
    before_action :set_place, only: [:show]
    before_action :set_areas, only: [:index]
    before_action :set_area, only: [:index]

    def index
      q_params = {}
      if @area.parent.name == '河北'
        q_params.merge! area_id: @area.id
      end
      q_params.merge! default_params
      q_params.merge! params.permit(:area_id, :place_taxon_id, 'name-like')

      @place_taxons = PlaceTaxon.default_where(default_params)
      @places = Place.includes(:area).default_where(q_params).page(params[:page])
    end

    private
    def set_place
      @place = Place.find(params[:id])
    end

    def place_params
      params.fetch(:place, {})
    end

    def set_areas
      area = Area.find_by(full: '河北省') || Area.first
      @areas = area.children
    end

    def set_area
      if params[:area_id]
        @area = Area.find params[:area_id]
      else
        ip = Ship::Ip.find_or_create_by(ip_address: request.remote_ip)
        area = ip.area
        @area = area || Area.find_by(full: '石家庄市') || Area.first
      end
    end

  end
end
