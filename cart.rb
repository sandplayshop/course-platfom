class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :courses, through: :cart_items

  def add_course(course, quantity = 1)
    current_item = cart_items.find_by(course_id: course.id)
    if current_item
      current_item.increment(:quantity, quantity)
    else
      current_item = cart_items.build(course_id: course.id, quantity: quantity)
    end
    current_item
  end

  def total_price
    cart_items.to_a.sum { |item| item.total_price }
  end

  def total_points
    cart_items.to_a.sum { |item| item.total_points }
  end
end
