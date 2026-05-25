class Product < ApplicationRecord
  has_many :orders

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  # Số lượng tồn kho không được là số âm
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
end