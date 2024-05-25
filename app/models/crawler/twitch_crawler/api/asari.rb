module Crawler
  module TwitchCrawler
    module Api
      class Asari
        class << self
          def ping_array(chats)
            res = RestClient.post("#{asari_url}/ping_array", { docs: chats.pluck('text') }.to_json, content_type: :json)
            JSON.parse(res.body)
          end

          private
          def asari_url
            'localhost:8000'
          end
        end
      end
    end
  end
end
