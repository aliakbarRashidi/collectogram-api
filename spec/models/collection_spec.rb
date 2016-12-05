require 'rails_helper'

RSpec.describe Collection, type: :model do
  it 'should collect matching photos when created' do
    collection = create(:collection, {
      tag: 'austonmatthews',
      start_date: Date.parse('November 29th 2016'),
      end_date: Date.parse('November 30th 2016')
    })
    expect(Card.where(collection: collection).size).to eq(20)
  end
end
