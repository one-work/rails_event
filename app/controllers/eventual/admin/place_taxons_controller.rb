module Eventual
  class Admin::PlaceTaxonsController < Admin::BaseController
    before_action :set_place_taxon, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params

      @place_taxons = PlaceTaxon.default_where(q_params).page(params[:page])
    end

    private
    def set_place_taxon
      @place_taxon = PlaceTaxon.find(params[:id])
    end

    def place_taxon_params
      p = params.fetch(:place_taxon, {}).permit(
        :name,
        :position,
        :places_count
      )
      p.merge! default_form_params
    end

  end
end
