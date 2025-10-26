class Course < ApplicationRecord
  has_rich_text :description
  has_many :lessons, dependent: :destroy
end
