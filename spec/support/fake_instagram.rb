require 'sinatra/base'

class FakeInstagram < Sinatra::Base
  get '/v1/tags/:tag_name/media/recent' do
    json_response 200, 'recent_tags.json'
  end

  get '/v1/media/:media_id/comments' do
    json_response 200, 'comments.json'
  end

  private
    def json_response(response_code, file_name)
      content_type :json
      status response_code
      File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
    end
end
