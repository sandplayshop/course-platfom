# 使用官方 Ruby 映像作為基礎映像
FROM ruby:3.0.2-slim

# 安裝 PostgreSQL 客戶端和必要的依賴
# libvips 是給 image_processing gem 用的
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs npm yarn libvips

# 設定工作目錄
WORKDIR /app

# 複製 Gemfile 和 Gemfile.lock
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# 安裝 Ruby Gems
RUN bundle install --without development test

# 複製應用程式程式碼
COPY . /app

# 預編譯靜態資源
# 注意：在 Zeabur 上，通常會在部署時執行此步驟，但為了確保 Docker 映像的完整性，我們保留它。
RUN RAILS_ENV=production bundle exec rails assets:precompile

# 設定啟動命令 (使用 Procfile)
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

