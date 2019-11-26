class CreateAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :answers do |t|
      t.string :body
      t.references :question, null: false, foreign_key: true
    end
  end
end
