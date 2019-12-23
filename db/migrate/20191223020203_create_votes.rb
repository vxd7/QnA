class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :value
      t.references :voteable, polymorphic: true

      t.timestamps
    end
  end
end
