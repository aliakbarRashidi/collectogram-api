class CollectionsController < ApplicationController

  def create
    collection = Collection.create(collection_params)
    collection.get_photos()
    render json: {unique_url: collection.unique_url}
  end

  def index
    offset_amount = ((params[:page_number].to_i - 1) * 10)
    collections = Collection.where(is_public: true).and(is_empty: false).order(:created_at).offset(offset_amount).limit(10).to_a
    render json: {collections: collections}
  end

  def show
    offset_amount = ((params[:page_number].to_i - 1) * 20)
    collection = Collection.where(unique_url: params[:unique_url]).first
    cards = Card.where(collection_id: collection.id).order(:created_at).offset(offset_amount).limit(20).to_a

    while (cards.size < 20 && collection.next_id)
      collection.get_photos()
      cards = Card.where(collection_id: collection.id).order(:created_at).offset(offset_amount).limit(20).to_a
    end

    render json: {collection: collection, cards: cards.to_a}
  end

  private

    def collection_params
      params.require(:collection).permit(:name, :tag, :start_date, :end_date, :is_public)
    end
end
