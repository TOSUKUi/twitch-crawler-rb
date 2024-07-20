class CreateOAuthToken < ActiveRecord::Migration[7.1]
  def change
    create_table :o_auth_tokens do |t|
      t.string :token_type
      t.string :scope
      t.string :access_token
      t.string :refresh_token

      t.index [:token_type, :scope]

      t.timestamps
    end
  end
end
