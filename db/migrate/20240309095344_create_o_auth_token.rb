class CreateOAuthToken < ActiveRecord::Migration[7.1]
  def change
    create_table :o_auth_tokens do |t|
      t.string :access_token
      t.string :oauth_token

      t.timestamps
    end
  end
end
