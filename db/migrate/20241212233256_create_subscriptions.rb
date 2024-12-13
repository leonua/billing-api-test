# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      # t.references :user, foreign_key: { on_delete: :cascade }

      t.date :start_at, null: false, index: true
      t.date :end_at,   null: false
      # TODO: can be cents here too
      t.float :price,   null: false, default: 10.0

      t.timestamps null: false
    end
  end
end
