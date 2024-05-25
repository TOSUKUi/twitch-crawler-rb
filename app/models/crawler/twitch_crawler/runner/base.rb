module Crawler
  module TwitchCrawler
    module Runner
      class Base < RunnerBase
        def api_client(token_type: :application, scopes: '', access_token: nil, refresh_token: nil)

          token_params = if access_token.present? && refresh_token.present?
                           { 'access_token' => access_token, 'refresh_token' => refresh_token }
                         else
                           res = redis.get("tokens_#{token_type}_#{scopes.delete(' ')}")
                           res.nil? ? {} : JSON.parse(res)
                         end
          tokens = TwitchOAuth2::Tokens.new(
            client:        {
              client_id:     ENV.fetch('TWITCH_CLIENT_ID', nil),
              client_secret: ENV.fetch('TWITCH_CLIENT_SECRET', nil)

              ## `localhost` by default, can be your application end-point
              # redirect_uri: redirect_uri
            },

            token_type:,
            ## this can be required by some Twitch end-points
            scopes:,
            ## if you already have these
            access_token:  token_params['access_token'],
            refresh_token: token_params['refresh_token']
          )
          if res.nil?
            redis.set("tokens_#{token_type}_#{scopes.delete(' ')}",
                      { access_token: tokens.access_token, refresh_token: tokens.refresh_token }.to_json)
          end
          Twitch::Client.new(tokens:)
        end

        def save_folder_root
          if Rails.env.production?
            '/dev/shm/crawler/twitch/stream'
          else
            'spec/crawled_data/crawler/twitch/stream'
          end
        end

        def redis
          @redis ||= Redis.new(Rails.application.config.redis_host)
        end
      end
    end
  end
end
