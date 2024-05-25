module Crawler
  module TwitchCrawler
    module Runner
      class TokenRefresh < RunnerBase
        def run
          tokens = TwitchOAuth2::Tokens.new(
            client:     {
              client_id:,
              client_secret:

              ## `localhost` by default, can be your application end-point
              # redirect_uri: redirect_uri
            },

            token_type: :user
            ## this can be required by some Twitch end-points
            # scopes: scopes,

            ## if you already have these
            # access_token: access_token,
            # refresh_token: refresh_token
          )
        end
      end
    end
  end
end
