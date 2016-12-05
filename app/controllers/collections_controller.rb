class CollectionsController < ApplicationController
  def create
    collection = Collection.create(collection_params)
    errors = collection.errors[:info_code]
    response = (errors.length == 0) ? collection : {error: errors[0]}
    render json: response.to_json
  end

  def show
    limit = params[:limit] || 12
    offset = params[:offset] || 0
    collection = Collection.where(unique_url: params[:unique_url]).first
    cards = collection.get_cards(limit.to_i, offset.to_i)
    render json: {collection: collection, cards: cards}.to_json
  end

  def index
    limit = params[:limit] || 10
    offset = params[:offset] || 0
    collections = Collection.where(is_public: true)
                            .order(:created_at)
                            .limit(limit.to_i)
                            .offset(offset.to_i)
                            .to_a

    render json: collections.to_json
  end

  private
    def collection_params
      params.require(:collection).permit(:name, :tag, :start_date, :end_date, :is_public)
    end
end
