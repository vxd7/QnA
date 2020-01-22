class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false
      t.references :question, null: false

      t.timestamps
    end
  end
end
