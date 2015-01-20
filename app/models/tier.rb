class Tier < ActiveRecord::Base
  belongs_to :round
  has_many :participants

  validates :level, uniqueness: true
end
