class AddIndexToChats < ActiveRecord::Migration[7.1]
  def change
    change_table :chats, bulk: true do |t|
      t.remove :user_client_nonce
      t.remove :user_color
      t.index :ts
      t.index :user_id
    end
  end
end
