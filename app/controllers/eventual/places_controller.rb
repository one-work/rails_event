module Eventual
  class PlacesController < BaseController
    before_action :set_place, only: [:show]
    before_action :set_areas, only: [:index]
    before_action :set_area, only: [:index]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:place_taxon_id)
      if params[:area_id]
        q_params.merge! place_id: Place.where(area_id: params[:area_id]).pluck(:id)
      end

      @place_taxons = PlaceTaxon.default_where(default_params)
      @places = Place.default_where(q_params).page(params[:page])
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
        @area = Area.find_by(full: '河北省') || Area.first
      end
    end

  end
end
