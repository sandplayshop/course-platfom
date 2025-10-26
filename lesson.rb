class Lesson < ApplicationRecord
  belongs_to :course
  has_rich_text :content
end
