class Participant < ActiveRecord::Base
  belongs_to :round
  belongs_to :player
  belongs_to :tier

  validates :round, presence: true
  validates :player, presence: true
  validates :tier, presence: true

  def games
    Game.for_participant(self)
  end

  def score
    games.finished.map { |g| g.points_for(self) }.inject(&:+) || 0
  end
end
