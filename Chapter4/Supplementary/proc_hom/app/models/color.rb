class Color < ActiveRecord::Base
  belongs_to :color_scheme
  has_many :prok_group
end
