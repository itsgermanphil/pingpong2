class Tier < ActiveRecord::Base
  belongs_to :round
  has_and_belongs_to_many :players
  has_many :games
end
