module Crawler
  module TwitchCrawler
    module Runner
      class Base < RunnerBase
        def api_client(token_type: :application, scopes: '', access_token: nil, refresh_token: nil)

          o_auth_token = OAuthToken.find_or_create_by(token_type:, scope: scopes.delete(' '))
          token_params = if access_token.present? && refresh_token.present?
                           { 'access_token' => access_token, 'refresh_token' => refresh_token }
                         else
                           { 'access_token' => o_auth_token.access_token,
                             'refresh_token' => o_auth_token.refresh_token }
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
          if tokens.access_token != o_auth_token.access_token
            o_auth_token.update(access_token: tokens.access_token, refresh_token: tokens.refresh_token)
          end
          ActiveRecord::Base.connection.close
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
