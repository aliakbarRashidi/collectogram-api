FactoryGirl.define do
  image_link = 'https://www.instagram.com/p/BM1ipfAhzF4/'
  image_url = 'https://scontent-yyz1-1.cdninstagram.com/t51.2885-15/e35/15056667_1608410472798193_876833834224582656_n.jpg'
  video_link = 'https://www.instagram.com/p/BM2irdihypF/'
  video_url = 'http://scontent-yyz1-1.cdninstagram.com/t50.2886-16/15118529_820547968088136_2011028173319307264_n.mp4'
  icon = 'https://scontent-yyz1-1.cdninstagram.com/t51.2885-19/s150x150/12904983_1599264090399930_1526936616_a.jpg'

  factory :card do
    caption { Faker::Hipster.sentence }
    user_handle { Faker::Internet.user_name }
    user_icon { icon }
    is_video { Faker::Boolean.boolean(0.05) }
    image { is_video ? video_url : image_url }
    link { is_video ? video_link : image_link }
    tag_time { Faker::Date.between(5.days.ago, Date.today) }
  end
end
