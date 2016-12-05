require 'rails_helper'

RSpec.describe Collection, type: :model do
  it 'should collect matching photos when created' do
    collection = create(:collection, {
      tag: 'austonmatthews',
      start_date: Date.parse('November 28th 2016'),
      end_date: Date.parse('November 30th 2016')
    })
    expect(Card.where(collection: collection).size).to eq(6)
  end

  it 'should collect more cards for the corresponding collection if required' do
    collection = build(:collection)
    expect(collection).to receive(:get_photos) { collection.next_max_id = '1234' }
    collection.save()

    num_cards = 5
    page_limit = 10
    cards = create_list(:card, num_cards, collection: collection)

    expect(collection).to receive(:get_photos) { collection.update(next_max_id: nil) }
    result = collection.get_cards(page_limit, 0)
    expect(result.length).to eq(num_cards)
  end
end
