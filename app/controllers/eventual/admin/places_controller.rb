module Eventual
  class Admin::PlacesController < Admin::BaseController
    before_action :set_place, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like', 'max_members-gte')
      @places = Place.default_where(q_params).page(params[:page])
    end

    def new
      @place = Place.new
      @place.place_taxon = PlaceTaxon.new(default_params)
    end

    def edit
      @place.place_taxon ||= PlaceTaxon.new(default_params)
    end

    private
    def set_place
      @place = Place.find(params[:id])
    end

    def place_params
      p = params.fetch(:place, {}).permit(
        :name,
        :color,
        :place_taxon_ancestors
      )
      p.merge! default_form_params
    end

  end
end
