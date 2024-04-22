class Micropost < ApplicationRecord
  validates :content, length: { maximum: 5 },
                      presence: true

  belongs_to :user
end
