class Value < ApplicationRecord
  belongs_to :subject
  has_many :constraints
end
