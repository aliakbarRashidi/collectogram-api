module InstagramUtil
  def self.retrieve_tag_photos(tag, start_date, end_date, next_max_id=nil)
    return empty_data_struct if invalid_id(next_max_id)

    tag_iterator = TagIterator.new(tag, start_date, end_date, next_max_id)
    tag_iterator.process_tags
    tag_iterator.data_struct
 end

 def self.invalid_id(id)
   id && id.length == 0
 end

 def self.empty_data_struct
   { next_max_id: '', items: [], info_code: 1000 }
 end

  class TagIterator
    @@MAX_REQUESTS = 25
    @@MIN_ITEMS = 20
    @@INFO_CODES = {
      SUCCESS: 1000,
      NO_MATCHES: 1001,
      INVALID: 1002
    }

    def initialize(tag, start_date, end_date, next_max_id=nil)
      @start_date, @end_date = start_date.to_time.to_i, end_date.to_time.to_i
      @tag, @next_max_id = tag, next_max_id
      @request_count = 0
      @index = -1
      @item_set = []
      @valid_items = []
      @info_code = @@INFO_CODES[:NO_MATCHES]

      # Only happens the very first time
      if !(next_max_id)
        update_tag_set(require_next_id=false)
        find_first_tag
        @index -= 1
      end
    end

    def data_struct
      {
        next_max_id: @next_max_id,
        items: @valid_items,
        info_code: @info_code
      }
    end

    def process_tags
      while(item = next_item)
        break if past_start_date(item)
        @valid_items.push(item)
        break if collected_min_items
      end

      @info_code = @@INFO_CODES[:SUCCESS] if @valid_items.length > 0
      return true
    end

    private
      def find_first_tag
        while(item = next_item)
          return true if past_end_date(item)
          break if past_start_date(item)
        end
        return false
      end

      def next_item
        @index += 1
        @item_set[@index] || update_tag_set
      end

      def past_end_date(item)
        compare_date_and_time(@end_date, item, check_comments=false)
      end

      def past_start_date(item)
        compare_date_and_time(@start_date, item, check_comments=true)
      end

      def compare_date_and_time(date, item, check_comments)
        if item['caption']
          item_time = item['caption']['created_time'].to_i
          val = (item_time < date)
        end

        val = !valid_comment_time(item['id']) if check_comments && val
        val
      end

      def valid_comment_time(media_id)
        comments = retrieve_comment_data(media_id)['data']
        comments.any? do |comment|
          time = comment['created_time'].to_i
          time > @start_time && time < @end_time && comment['text'].include?(@tag)
        end
      end

      def update_tag_set(require_next_id=true)
        return false if (@next_max_id == '') && require_next_id
        res = retrieve_tag_data

        if hit_max_requests
          @info_code = @@INFO_CODES[:INVALID]
          return false
        end

        @next_max_id = res['pagination']['next_max_id'] || ''
        @item_set += res['data']
        @item_set[@index]
      end

      def hit_max_requests
        @request_count += 1
        @request_count >= @@MAX_REQUESTS
      end

      def collected_min_items
        @valid_items.size >= @@MIN_ITEMS
      end

      def retrieve_tag_data
        uri = URI("https://api.instagram.com/v1/tags/#{@tag}/media/recent")
        send_json_request(uri, current_params)
      end

      def retrieve_comment_data(media_id)
        uri = URI("https://api.instagram.com/v1/media/#{media_id}/comments")
        send_json_request(uri, current_params)
      end

      def current_params
        params = { access_token: ENV['INSTAGRAM_API_KEY'] }
        params[:max_tag_id] =  @next_max_id
        params
      end

      def send_json_request(uri, params={})
        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(Net::HTTP::Get.new(uri))
        end
        JSON.parse(res.body)
      end
  end
end
