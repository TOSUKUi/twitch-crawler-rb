class ChangeChatsIdsToInteger < ActiveRecord::Migration[7.1]
  def up
    change_table :chats, bulk: true do |t|
      t.change :user_id, :bigint, null: false
      t.change :user_room_id, :bigint, null: false
      t.change :emote_only, :boolean
    end
  end

  def down
    change_table :chats, bulk: true do |t|
      t.change :user_id, :string, null: false, limit: 36
      t.change :user_room_id, :string, null: false, limit: 36
      t.change :emote_only, :varchar
    end
  end
end
