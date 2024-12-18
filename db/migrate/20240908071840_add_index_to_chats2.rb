class AddIndexToChats2 < ActiveRecord::Migration[7.1]
  def change
    add_index :chats, [:stream_id, :ts]
  end
end
