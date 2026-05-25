# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :product

  validates :order_number, :quantity, :status, presence: true
end
