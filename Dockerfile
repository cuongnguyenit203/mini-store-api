FROM ruby:3.3.0-alpine

# Cài đặt các thư viện hệ thống cần thiết cho PostgreSQL, Sidekiq và dịch vụ mạng
RUN apk add --no-cache build-base postgresql-dev tzdata nodejs git

WORKDIR /app

# Khai báo cấu hình Bundler an toàn cho môi trường Local Development
ENV BUNDLE_PATH="/usr/local/bundle"

COPY Gemfile Gemfile.lock ./

# Chạy bundle install (Tự động cập nhật Gemfile.lock nếu có thay đổi)
RUN bundle install --jobs 4

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]