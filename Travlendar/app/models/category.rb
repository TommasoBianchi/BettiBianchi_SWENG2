class Category < ApplicationRecord
    has_many :subclasses, class_name: "Category", foreign_key: "superclass_id"
    belongs_to :superclass, class_name: "Category", optional: true
end
