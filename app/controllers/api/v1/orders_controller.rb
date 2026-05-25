module Api
  module V1
    class OrdersController < ApplicationController

  def place_order
  email = params[:customer_email]
  sku = params[:sku]
  quantity = params[:quantity]

  if email.blank? || sku.blank? || quantity.blank?
    return render json: { error: "Vui lòng điền đầy đủ email, sku và số lượng mua." }, status: :bad_request
  end

  # 1. Tìm sản phẩm dựa trên SKU trước để lấy product_id
  product = Product.find_by(sku: sku)
  if product.nil?
    return render json: { error: "Sản phẩm với mã SKU này không tồn tại trong hệ thống." }, status: :not_found
  end

  # 2. Tạo đơn hàng với các trường chuẩn của bảng Order (Dùng product_id thay vì sku)
  order = Order.create!(
    order_number: "STORE-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}",
    customer_email: email,
    product_id: product.id, # 👈 Lưu ID sản phẩm vào đây thay vì sku
    quantity: quantity.to_i,
    status: "pending"
  )

  # 3. Đẩy ID của đơn hàng vào Sidekiq xử lý tiếp
  OrderWorker.perform_async(order.id)

  render json: {
    message: "Đơn hàng của bạn đang được hệ thống xử lý.",
    order_id: order.id,
    status: "pending"
  }, status: :accepted
end

    end
  end
end