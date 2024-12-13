# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :subscription, foreign_key: { on_delete: :cascade }

      t.datetime :process_at, null: false, index: true
      # TODO: to use enum for status
      t.string :status, null: false, default: 'active'
      # TODO: amount is copied from subscription, can be better this way for microservice structure
      t.integer :amount, null: false
      t.integer :paid_amount, null: false, default: 0

      t.timestamps null: false
    end
  end
end
