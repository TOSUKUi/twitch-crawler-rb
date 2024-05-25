module Crawler
  module Twitch
    module Api
      class Base
        class << self
          def get(url)
            RestClient.get(url, params)
            url = 'https://api.twitch.tv/helix/streams'

            access_token =
              client_id = ''

            RestClient.get(url, { params:,
                                  'Authorization' => "Bearer #{access_token}",
                                  'Client-Id' => client_id })
          end
        end
      end
    end
  end
end
