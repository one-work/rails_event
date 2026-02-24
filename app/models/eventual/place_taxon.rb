module Eventual
  class PlaceTaxon < ApplicationRecord
    include Model::PlaceTaxon
    include Com::Ext::Taxon
    include Detail::Ext::TaxonModel if defined? RailsDetail
  end
end
