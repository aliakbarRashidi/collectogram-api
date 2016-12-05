class Collection < ApplicationRecord
  attr_accessor :result_set
  has_many :cards
  before_validation :generate_unique_url, :get_photos
  validate :no_photo_errors
  after_create :save_photos
  @@INFO_CODES = {
    SUCCESS: 1000,
    NO_MATCHES: 1001,
    INVALID: 1002
  }

  def no_photo_errors
    if (result_set[:info_code] != @@INFO_CODES[:SUCCESS])
      errors.add(:info_code, result_set[:info_code])
    end
  end

  def save_photos
    result_set[:items].each { |item| Card.create(json_to_params(item)) }
  end

  def get_photos
    self.result_set = InstagramUtil.retrieve_tag_photos(tag, start_date, end_date, next_max_id)
    self.next_max_id = result_set[:next_max_id]
  end

  def get_cards(limit, offset)
    cards = Card.where(collection: self)
                .order(:created_at)
                .limit(limit)
                .offset(offset)
                .to_a

    # If there are more images on Instagram, but not in the database
    if (cards.size < limit && next_max_id)
      get_photos
      save_photos
      cards += get_cards(limit - cards.size, offset + cards.size)
    end
    cards
  end

  private
    def generate_unique_url
      self.unique_url = SecureRandom.urlsafe_base64(24)
    end

    def json_to_params(item)
      image_val = item['images']['standard_resolution']['url']
      image_val = item['videos']['standard_resolution']['url'] if item['videos']
      {
        collection_id: self.id,
        caption:       item['caption']['text'],
        image:         image_val,
        link:          item['link'],
        user_handle:   item['user']['username'],
        user_icon:     item['user']['profile_picture'],
        is_video:      (item['type'] == 'video'),
        tag_time:      Time.at(item['created_time'].to_i).to_datetime
      }
    end
end
