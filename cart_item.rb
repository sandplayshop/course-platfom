class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :course

  def total_price
    course.price * quantity
  end

  def total_points
    course.point_cost * quantity
  end
end
