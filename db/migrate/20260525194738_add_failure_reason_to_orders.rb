class AddFailureReasonToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :failure_reason, :text
  end
end
