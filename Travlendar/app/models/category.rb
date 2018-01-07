# This class manages the model(relations, validations and base methods) of the Category object
class Category < ApplicationRecord
    has_many :subclasses, class_name: "Category", foreign_key: "superclass_id"
    belongs_to :superclass, class_name: "Category", optional: true	

    validates :name, presence: true
end
