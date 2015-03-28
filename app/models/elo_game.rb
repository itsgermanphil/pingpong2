
class EloGame

  def initialize(player1, player2)
    @player1 = player1.clone
    @player2 = player2.clone
  end

  def rating1_in
    @player1.fetch(:rating)
  end

  def rating2_in
    @player2.fetch(:rating)
  end

  def rating1_out
    @player1.fetch(:rating) + elo_movement(@player1, @player2)
  end

  def rating2_out
    @player2.fetch(:rating) + elo_movement(@player2, @player1)
  end

  # This function accepts two hashes representing the state of two players.
  # Each hash should provide a rating, a score and a number of games played.
  #
  # It will return the number of points to add to p1's rating, based on the game described by the hashes
  #
  # This is NOT necessarily the number of points to deduct from p2! Each must be calculated independently,
  # as there could be a different number of points gained and lost depending on the k-factor of each player
  #
  def elo_movement(p1, p2)
    # Elo ratings are basically:
    k_factor(p1, p2) * (actual(p1, p2) - expected(p1, p2))
  end

  def k_factor(p1, p2)

    # If the user is very new, move a large number of points
    return 32 if p1[:games] <= 30


    # If the user is "professional", move the smallest number of points
    return 16 if p1[:games] >= 30 && p1[:rating] >= 2400

    # otherwise, 24 is a good default
    24
  end

  def actual(p1, p2)
    # First, figure out the "actual" score. This is either:
    # - 1.0 for a win
    # - 0.0 for a loss
    # - 0.5 for a draw (not applicable for ping pong)
    score1 = p1.fetch(:score)
    score2 = p2.fetch(:score)

    return 0.5 if score1 == score2

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
  def expected(p1, p2)
    r1 = p1.fetch(:rating)
    r2 = p2.fetch(:rating)
    e = 1.0 / (1.0 + 10**((r2 - r1) / 400.0))
  end

end
