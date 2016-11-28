require "#{Rails.root}/lib/modules/instagram_util"
require 'securerandom'

class Collection < ApplicationRecord
  include InstagramUtil
  has_many :cards

  def get_photos
    self.unique_url = SecureRandom.urlsafe_base64(24) if !self.unique_url

    match_object = get_tag_photos(self.tag, self.start_date, self.end_date, self.next_id)
    match_list = match_object[:matches]
    self.next_id = match_object[:next_id] || nil
    self.is_empty = (match_list.size == 0)
    self.save
    # Create cards for each of the matches
    match_list.each do |item|
      card_data = {
        collection_id: self.id,
        content_caption: item['caption']['text'],
        content_url: item['images']['standard_resolution']['url'],
        content_link: item['link'],
        user_handle: item['user']['username'],
        user_icon: item['user']['profile_picture'],
        is_video: (item['type'] == 'video'),
        tag_time: Time.at(item['created_time'].to_i).to_datetime
      }
      Card.create(card_data)
    end

    self.id
  end
end
