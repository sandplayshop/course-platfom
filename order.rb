class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :courses, through: :order_items

  enum payment_status: { pending: 'pending', paid: 'paid', failed: 'failed' }

  before_create :set_default_payment_status

  def self.create_from_cart(cart)
    order = new(user: cart.user, total_price: cart.total_price, total_points: cart.total_points)
    cart.cart_items.each do |item|
      order.order_items.build(
        course: item.course,
        price: item.course.price,
        point_cost: item.course.point_cost,
        quantity: item.quantity
      )
    end
    order
  end

  def process_payment_success(ecpay_trade_no)
    update!(payment_status: :paid, ecpay_trade_no: ecpay_trade_no)
    grant_course_enrollments
    deduct_user_points
    clear_cart
  end

  private

  def set_default_payment_status
    self.payment_status ||= :pending
  end

  def grant_course_enrollments
    order_items.each do |item|
      (1..item.quantity).each do # If quantity is more than 1, grant multiple enrollments
        expires_at = item.course.viewing_period_days.present? ? item.course.viewing_period_days.days.from_now : nil
        Enrollment.create!(user: user, course: item.course, expires_at: expires_at)
      end
    end
  end

  def deduct_user_points
    if total_points > 0
      user.decrement!(:points, total_points)
    end
  end

  def clear_cart
    user.cart.cart_items.destroy_all
  end
end

