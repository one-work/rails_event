module Eventual
  class PlacesController < BaseController
    before_action :set_place, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:place_taxon_id)

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

  end
end
