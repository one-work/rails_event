module Eventual
  class Event::PlacesController < PlacesController

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:place_taxon_id)

      @place_taxons = PlaceTaxon.default_where(default_params)
      @places = Place.default_where(q_params).page(params[:page])
    end

  end
end
