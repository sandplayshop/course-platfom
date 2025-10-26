class CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def create
    @cart = current_user.cart

    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "購物車是空的，無法結帳。"
      return
    end

    @order = Order.create_from_cart(@cart)

    if @order.save
      # 準備綠界金流參數
      @form_info = generate_ecpay_params(@order)
      render :ecpay_form, layout: false # 渲染一個自動提交的表單到綠界
    else
      redirect_to cart_path, alert: "訂單建立失敗，請重試。"
    end
  end

  # 綠界付款完成後，使用者會被導回此處
  def ecpay_return
    response = ECPay::PaymentReturn.new(params)
    if response.success?
      order = Order.find(response.merchant_trade_no.split("-").first)
      if order.pending? # 避免重複處理
        order.process_payment_success(response.trade_no)
        redirect_to root_path, notice: "付款成功，課程已開通！"
      else
        redirect_to root_path, alert: "訂單已處理。"
      end
    else
      redirect_to cart_path, alert: "付款失敗或取消：#{response.message}"
    end
  end

  # 綠界會發送伺服器端通知到此處
  def ecpay_notify
    response = ECPay::PaymentReturn.new(params)
    if response.success?
      order = Order.find(response.merchant_trade_no.split("-").first)
      if order.pending?
        order.process_payment_success(response.trade_no)
        render plain: "OK"
      else
        render plain: "Order already processed"
      end
    else
      render plain: "Payment Failed: #{response.message}"
    end
  end

  private

  def generate_ecpay_params(order)
    # 請替換成您在綠界申請的 MerchantID, HashKey, HashIV
    merchant_id = ENV["ECPAY_MERCHANT_ID"]
    hash_key = ENV["ECPAY_HASH_KEY"]
    hash_iv = ENV["ECPAY_HASH_IV"]

    # 綠界測試環境 URL
    # ecpay_url = "https://payment-stage.ecpay.com.tw/Cashier/AioCheckOut/V5"
    # 綠界正式環境 URL
    ecpay_url = "https://payment.ecpay.com.tw/Cashier/AioCheckOut/V5"

    # 訂單編號，加上時間戳以確保唯一性
    merchant_trade_no = "#{order.id}-#{Time.now.to_i}"

    # 商品名稱，將購物車中的所有課程名稱串接起來
    item_names = order.courses.map(&:title).join("#")

    params = {
      "MerchantID" => merchant_id,
      "MerchantTradeNo" => merchant_trade_no,
      "MerchantTradeDate" => Time.now.strftime("%Y/%m/%d %H:%M:%S"),
      "PaymentType" => "aio",
      "TotalAmount" => order.total_price.to_i.to_s, # 綠界金額必須是整數
      "TradeDesc" => "課程購買",
      "ItemName" => item_names,
      "ReturnURL" => ecpay_notify_url, # 綠界後端通知 URL
      "ChoosePayment" => "ALL",
      "ClientBackURL" => ecpay_return_url, # 綠界付款完成後使用者導回的 URL
      "EncryptType" => "1", # SHA256
      "OrderResultURL" => ecpay_return_url # 綠界付款完成後使用者導回的 URL (同 ClientBackURL)
    }

    # 產生檢查碼
    check_mac_value = ECPay::PaymentHelper.generate_check_mac_value(params, hash_key: hash_key, hash_iv: hash_iv)
    params["CheckMacValue"] = check_mac_value
    
    { url: ecpay_url, params: params }
  end
end

