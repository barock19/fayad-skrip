class AddTimeTrackToAbsens < ActiveRecord::Migration
  def change
    add_column :absens, :onduty, :datetime
    add_column :absens, :offduty, :datetime
  end
end
