module InstagramUtil
  def get_tag_photos(tag_name, start_date, end_date, next_id=nil)
    params = {}
    params = {max_tag_id: next_id} if next_id
    response = get_tag_data(tag_name, params)
    match_list = []
    finished_matching = false;
    max_reqs = 60;
    current_reqs = 0;

    # Find the first page that contains valid matches
    while (current_reqs < max_reqs)
      current_reqs += 1;

      data = response['data']
      next_page_id = response['pagination']['next_max_id']
      break if less_than_date(data.last['caption']['created_time'], end_date)

      # Need to check comments as well
      if less_than_date(data.first['caption']['created_time'], start_date)
        if !valid_comment_date(data.first['id'], tag, start_date, end_date)
          return {matches: [], next_id: nil}
        end
      end
      response = get_tag_data(tag_name, {max_tag_id: next_page_id})
    end

    # Iterate through all pages until we run out of matches
    while (current_reqs < max_reqs)
      current_reqs += 1;

      data = response['data']
      next_page_id = response['pagination']['next_max_id']
      return {matches: match_list, next_id: next_page_id} if match_list.size > 20

      accumulator = []
      data.each do |item|
        if (between_dates(item['created_time'], start_date, end_date) || valid_comment_date(item['id'], tag, start_date, end_date))
            accumulator.push(item)
        else
          finished_matching = true
          break
        end
      end
      match_list += accumulator

      return {matches: match_list, next_id: nil} if finished_matching
      response = get_tag_data(tag_name, {max_tag_id: next_page_id})
    end
    return {matches: match_list, next_id: nil}
  end

  def valid_comment_date(media_id, tag_name, start_date, end_date)
    uri = URI("https://api.instagram.com/v1/media/#{media_id}/comments")
    comments = send_json_request(uri)['data']
    comments.any? do |comment|
      between_dates(comment['created_time'], start_date, end_date) && comment['text'].include?(tag_name)
    end
  end

  def get_tag_data(tag_name, params={})
    uri = URI("https://api.instagram.com/v1/tags/#{tag_name}/media/recent")
    send_json_request(uri, params)
  end

  def send_json_request(uri, params={})
    params[:access_token] = ENV['INSTAGRAM_API_KEY']
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(Net::HTTP::Get.new(uri))
    end

    JSON.parse(res.body)
  end

  def less_than_date(d1, d2)
    d1.to_i < d2.to_time.to_i
  end

  def greater_than_date(d1, d2)
    d1.to_i > d2.to_time.to_i
  end

  def between_dates(d1, d2, d3)
    greater_than_date(d1, d2) and less_than_date(d1, d3)
  end
end
