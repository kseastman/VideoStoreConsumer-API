class ExternalIdNotNil < ActiveRecord::Migration[5.0]
  def change
    change_column :movies, :external_id, :integer, null: false
  end
end
