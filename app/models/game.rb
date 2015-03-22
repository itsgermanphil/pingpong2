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

  before_save :update_finished_at

  after_save :ping_round_for_closure

  # Adjust our associated players' ratings based on the results of this game
  def apply_elo_ratings
    raise "Cannot apply an unfinished game" unless finished?

    p1 = {
      rating: player1.elo_rating,
      games: player1.all_finished_games.select { |g| g.finished_at <= finished_at }.count,
      score: score1
    }

    p2 = {
      rating: player2.elo_rating,
      games: player2.all_finished_games.select { |g| g.finished_at <= finished_at }.count,
      score: score2
    }

    # Record the state of player's Elo ratings for reporting, before and after this game
    self.elo_rating1_in = p1[:rating]
    self.elo_rating2_in = p2[:rating]

    apply_elo_movement(p1, p2)

    self.elo_rating1_out = player1.elo_rating = p1[:rating]
    self.elo_rating2_out = player2.elo_rating = p2[:rating]

    player1.save!
    player2.save!
    save!
    nil
  end

  def apply_elo_movement(p1, p2)
    movement = calc_elo_movement(p1, p2)
    p1[:rating] += movement

    movement = calc_elo_movement(p2, p1)
    p2[:rating] += movement
  end
  # This function accepts two hashes representing the state of two players.
  # Each hash should provide a rating, a score and a number of games played.
  #
  # From this, the function will calculate the correct K factor and return the number
  # of points that should be added to player1's rating, and removed from player2's rating.
  # In the case of player1 winning, this will be a positive number, for example, '10':
  #   player1.rating += 10; player2.rating -= 10
  #
  # If player2 wins, this # will be a negative number ie, -10:
  #   player1.rating += (-10), player2.rating -= (-10)
  #
  def calc_elo_movement(p1, p2)
    # Elo ratings are basically:
    # rating += (k_factor * (actual_score - expected_score)

    actual = calc_actual(p1, p2)
    expected = calc_expected(p1, p2)
    k = calc_k_factor(p1, p2)

    k * (actual - expected)
  end

  def calc_k_factor(p1, p2)
    if p1[:games] <= 30
      return 25
    end
    return 15

    # The logic behind my k-factor is this:
    # If the player who won the game is "new", use a bigger k-factor
    # If the player who won the game is not new, use a smaller k-factor
    # The idea is that a player who just joined, who wins, should move up quicker
    # A player who just joined and lost, should move down slower

    (winner, loser) = (p1[:score] > p2[:score] ? [p1, p2] : [p2, p1])

    # If the winner is very new, just move the maximum number of points
    return 24 if winner[:games] < 30

    # Both players are established, compute a "k" based on the amount of upset
    #
    # If p1 is strongly expected to win, but loses, return 10
    # If p1 is storngly expected to lose, but wins, return 32
    #
    # This is scaled based on a 400 rating deficit, so that if p1 is 400 points lower
    # than p2, but wins, the maximum amount of points get moved. If p1 is 1000 points lower,
    # the same nmber of points move as if p1 is 400 points lower.
    #
    # My reasoning is that, outside of this range, an upset is likely a fluke
    diff = loser[:rating] - winner[:rating]

    k = 32 * (diff / 400.0)

    # Return 10 <= k <= 24
    [[32.0, k].min, 16.0].max
  end

  def calc_actual(p1, p2)
    # First, figure out the "actual" score. This is either:
    # - 1.0 for a win
    # - 0.0 for a loss
    # - 0.5 for a draw (not applicable for ping pong)
    score1 = p1.fetch(:score)
    score2 = p2.fetch(:score)

    actual = (score1 > score2 ? 1.0 : 0.0)
  end

  # Calculate the player's expected score (0..1), based on two ratings
  # 0 indicates that player1 is expected to lose,
  # 1 indicates that player1 is expected to win,
  # 0.5 indicates a draw is expected.
  #
  # Examples:
  #   1000 vs 1000, expected => 0.5 - draw is likely
  #   2000 vs 1000, expected => 0.997 - p1 very likely to win
  #   1000 vs 2000, epxected => 0.003 - p1 very likely to lose
  def calc_expected(p1, p2)
    r1 = p1.fetch(:rating)
    r2 = p2.fetch(:rating)
    e = 1.0 / (1.0 + 10**((r2 - r1) / 400.0))
  end

  # Calculate the number of points to move from r1 to r2
  # This may be a negative number
  # Inputs:
  def calc_moved_points(score1, score2, rating1, rating2, k)
    expected = calc_expected_score(rating1, rating2)

    actual = score1 > score2 ? 1 : 0

    points = k * (actual - expected)
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
