class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:course)
  end

  def add
    course = Course.find(params[:course_id])
    @cart.add_course(course)
    if @cart.save
      redirect_to cart_path, notice: "#{course.title} 已加入購物車。"
    else
      redirect_to course_path(course), alert: "無法將 #{course.title} 加入購物車。"
    end
  end

  def remove
    course = Course.find(params[:course_id])
    cart_item = @cart.cart_items.find_by(course_id: course.id)
    if cart_item
      cart_item.destroy
      redirect_to cart_path, notice: "#{course.title} 已從購物車移除。"
    else
      redirect_to cart_path, alert: "購物車中沒有 #{course.title}。"
    end
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
end
