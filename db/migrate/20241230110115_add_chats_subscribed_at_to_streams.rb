class AddChatsSubscribedAtToStreams < ActiveRecord::Migration[7.1]
  def change
    add_column :streams, :chats_subscribed_at, :datetime, after: :language
    add_column :streams, :chats_subscribed, :boolean, after: :language, null: false, default: false
  end
end
