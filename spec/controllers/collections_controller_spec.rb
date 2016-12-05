require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do
  describe "POST #create" do
    it "should create a new collection when given all required fields" do
      collection = build(:collection)
      allow_any_instance_of(Collection).to receive(:get_photos).and_return(true)
      post 'create', params: { collection: collection.attributes }

      expect(response).to be_success
      expect(Collection.count).to eq(1)
      expect(json['unique_url']).not_to be_nil
    end

    it "should not create a new collection when not given all required fields" do
      collection = build(:collection)
      allow_any_instance_of(Collection).to receive(:get_photos).and_return(true)
      post 'create', params: { collection: collection.attributes }

      expect(response).to be_success
      expect(Collection.count).to eq(0)
    end
  end

  describe "GET #show" do
    it "should return the cards for the corresponding collection" do
      collection = create(:collection)
      num_cards = 20
      page_limit = 10
      cards = create_list(:card, num_cards, collection: collection)
      get 'show', params: {
        unique_url: collection.unique_url,
        limit: page_limit,
        offset: 0
      }

      expect(response).to be_success
      expect(json['collection']['id']).to eq(collection.id)
      expect(json['cards'].length).to eq(page_limit)
    end

    it "should not return any data if there is no corresponding collection" do
      collection = create(:collection)
      get 'show', params: { unique_url: collection.unique_url }

      expect(response).to be_success
      expect(json.length).to eq(0)
    end
  end

  describe "GET #index" do
    it "should return a list of all public collections" do
      num_collections = rand(5..10)
      create_list(:collection_public, num_collections)
      create(:collection_private)
      get 'index'

      expect(response).to be_success
      expect(json.length).to eq(num_collections)
    end

    it "should paginate through the list of collections" do
      num_collections = rand(12..18)
      create_list(:collection_public, num_collections)

      page_limit = 10
      get 'index', params: {
        limit: page_limit,
        offset: 0
      }
      response_1 = response
      json1 = json

      get 'index', params: {
        limit: page_limit,
        offset: page_limit
      }

      expect(response_1).to be_success
      expect(response).to be_success
      expect(json1.length).to eq(page_limit)
      expect(json.length).to eq(num_collections-page_limit)
    end
  end
end
