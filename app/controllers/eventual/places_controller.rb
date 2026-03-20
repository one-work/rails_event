module Eventual
  class PlacesController < BaseController
    before_action :set_place, only: [:show]
    before_action :set_area, only: [:index]

    def index
      q_params = {}
      if @area
        q_params.merge! area_id: @area.self_and_descendant_ids
      end
      q_params.merge! default_params
      q_params.merge! params.permit(:place_taxon_id, 'name-like')

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

  end
end
