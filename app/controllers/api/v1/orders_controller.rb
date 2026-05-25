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

        # Đẩy tác vụ xử lý ngầm vào hàng đợi Sidekiq
        OrderWorker.perform_async(email, sku, quantity)

        # Trả về kết quả ngay lập tức cho Postman
        render json: {
          message: "Đơn hàng của bạn đang được hệ thống xử lý.",
          status: "queued"
        }, status: :accepted
      end

    end
  end
end