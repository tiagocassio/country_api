class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.string :user_agent
      t.string :ip_address
      t.string :slug

      t.timestamps
    end

    add_index :sessions, :slug, unique: true
  end
end
