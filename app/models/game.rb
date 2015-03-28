class Game < ActiveRecord::Base
  # touch: true - cache-busting in home#index, round#show, etc
  belongs_to :round, touch: true

  # touch: true - more cache-busting
  belongs_to :participant1, class_name: 'Participant', touch: true
  belongs_to :participant2, class_name: 'Participant', touch: true

  has_one :player1, through: :participant1, source: :player
  has_one :player2, through: :participant2, source: :player

  validates :round, presence: true

  validates :score1, presence: { if: -> { score2.present? } }
  validates :participant1, presence: true
  validates :participant2, presence: true

  validate :must_have_both_scores_or_no_score
  validate :must_have_distinct_players
  validate :must_have_valid_scores, if: -> { score1.present? }

  scope :for_participant, ->(p) { where('participant1_id = ? or participant2_id = ?', p.id, p.id) }
  scope :unfinished, -> { where(finished_at: nil) }
  scope :finished, -> { where('finished_at is not null') }
  scope :all_1v1_games, -> { where('elo_rating1_in is not null') }

  before_save :update_finished_at

  after_save :ping_round_for_closure

  # Adjust our associated players' ratings based on the results of this game
  def apply_elo_ratings
    raise "Cannot apply an unfinished game" unless finished?

    p1 = {
      rating: player1.elo_rating,
      games: player1.all_finished_1v1_games.select { |g| g.finished_at <= finished_at }.count,
      score: score1
    }

    p2 = {
      rating: player2.elo_rating,
      games: player2.all_finished_1v1_games.select { |g| g.finished_at <= finished_at }.count,
      score: score2
    }


    # Record the state of player's Elo ratings for reporting, before and after this game
    self.elo_rating1_in = p1[:rating]
    self.elo_rating2_in = p2[:rating]

    game = EloGame.new(p1, p2)

    self.elo_rating1_out = player1.elo_rating = game.rating1_out
    self.elo_rating2_out = player2.elo_rating = game.rating2_out

    player1.save!
    player2.save!
    save!
    nil
  end


  def elo_rating_in(participant)
    return elo_rating1_in if participant.id == participant1_id
    return elo_rating2_in if participant.id == participant2_id
    raise 'rating_in called for game a player was not involved in'
  end

  def elo_rating_out(participant)
    return elo_rating1_out if participant.id == participant1_id
    return elo_rating2_out if participant.id == participant2_id
    raise 'rating_out called for game a player was not involved in'
  end

  def finished?
    finished_at.present?
  end

  def forfeit!(participant)
    if participant == participant1
      self.score1 = 0
      self.score2 = 11
    elsif participant == participant2
      self.score2 = 0
      self.score1 = 11
    else
      raise "Invalid participant in forfeit"
    end
    self.finished_at = Time.now
    save!
  end

  def winner
    return nil unless finished?

    if score1 > score2
      participant1
    else
      participant2
    end
  end

  def score_for(participant)
    if participant == participant1
      score1
    elsif participant == participant2
      score2
    else
      raise "newp, invalid participant"
    end
  end

  def points_for(participant)
    if participant == participant1
      11 + (score1 - score2)
    elsif participant == participant2
      11 + (score2 - score1)
    else
      raise "newp, invalid participant"
    end
  end

  def other_participant(p)
    if p == participant1
      participant2
    elsif p == participant2
      participant1
    else
      raise "newp, invalid participant"
    end
  end

  def participant_for(player)
    player_id = player.is_a?(Player) ? player.id : player

    return participant1 if participant1.player_id == player_id
    return participant2 if participant2.player_id == player_id

    raise "participant_for called for game a player is not in"
  end

  protected

  def update_finished_at
    if self.score1.present? && self.score2.present? && self.finished_at.nil?
      self.finished_at ||= Time.now
      apply_elo_ratings
    end
  end

  def must_have_both_scores_or_no_score
    self.errors.add(:base, :invalid) unless (score1.nil? && score2.nil?) || (score1.present? && score2.present?)
  end

  def must_have_distinct_players
    self.errors.add(:base, :invalid) if participant1.player_id == participant2.player_id
  end

  def must_have_valid_scores
    self.errors.add(:base, :invalid) if score1 < 11 && score2 < 11
    self.errors.add(:base, :invalid) if score1 > score2 && score1 >= 11 && score1 - score2 < 2
    self.errors.add(:base, :invalid) if score2 > score1 && score2 >= 11 && score2 - score1 < 2
    self.errors.add(:base, :invalid) if score1 > ([11, score2 + 2].max)
    self.errors.add(:base, :invalid) if score2 > ([11, score1 + 2].max)
  end

  def ping_round_for_closure
    # Notify the round that a game is finished
    round.check_for_completion
  end
end
