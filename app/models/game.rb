class Game < ActiveRecord::Base
  belongs_to :tier
  has_many :participants

  def complete?
    participants.all? { |p| p.score != nil }
  end
end
