class CreateScores < ActiveRecord::Migration[5.1]
  def change
    create_table :scores do |t|
      t.datetime :datetime
      t.string :subject
      t.string :idol
      t.integer :rank
      t.integer :score

      t.timestamps
    end
  end
end
