class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.date :encoded_at
      t.integer :times

      t.timestamps
    end
  end

  def self.down
    drop_table :statistics
  end
end
