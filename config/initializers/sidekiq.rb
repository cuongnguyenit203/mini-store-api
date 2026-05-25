# Giả sử trong dự án anh muốn Sidekiq chạy tối đa 10 Threads song song
sidekiq_concurrency = 10

Sidekiq.configure_server do |config|
  # Khai báo chuẩn size kết nối cho server xử lý Job 👇
  config.redis = { url: "redis://redis:6379/1", size: sidekiq_concurrency + 5 }
end

Sidekiq.configure_client do |config|
  # Phía client (Web Puma đẩy job lên) cần size nhỏ hơn tùy thuộc vào số thread của Puma
  config.redis = { url: "redis://redis:6379/1", size: 5 }
end