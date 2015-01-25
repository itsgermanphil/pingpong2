class Participant < ActiveRecord::Base
  belongs_to :round
  belongs_to :player
  belongs_to :tier

  validates :round, presence: true
  validates :player, presence: true
  validates :tier, presence: true

  after_destroy :destroy_games

  def games
    Game.for_participant(self)
  end

  def points
    games.finished.map { |g| g.points_for(self) }.inject(&:+) || 0
  end

  def destroy_games
    games.each(&:destroy)
  end
end
