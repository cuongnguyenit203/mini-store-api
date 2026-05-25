module Api
  module V1
    class OrdersController < ApplicationController

      def place_order
        email = params[:customer_email]
        sku = params[:sku]
        quantity = params[:quantity].to_i

        if email.blank? || sku.blank? || quantity.blank?
          return render json: { error: "Vui lòng điền đầy đủ email, sku và số lượng mua." }, status: :bad_request
        end

        # Tạo nhanh một bản ghi ở trạng thái chờ xử lý (Mất chưa tới 2ms)
        order = Order.create!(
          order_number: "STORE-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}",
          customer_email: email,
          sku: sku, # Giả sử anh có lưu sku ở bảng order để tracking
          quantity: quantity,
          status: "pending" # 👈 Chờ xử lý
        )

        # Đẩy ID của đơn hàng vào Sidekiq để nó lôi ra xử lý
        OrderWorker.perform_async(order.id)

        # Trả về ID đơn hàng cho Next.js/Postman
        render json: {
          message: "Đơn hàng của bạn đang được hệ thống xử lý.",
          order_id: order.id,
          status: "pending"
        }, status: :accepted
      end

    end
  end
end