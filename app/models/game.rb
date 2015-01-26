class Game < ActiveRecord::Base
  belongs_to :round, touch: true

  belongs_to :participant1, class_name: 'Participant', touch: true
  belongs_to :participant2, class_name: 'Participant', touch: true

  validates :round, presence: true

  validates :score1, presence: { if: -> { score2.present? } }
  validates :participant1, presence: true
  validates :participant2, presence: true

  validate :must_have_both_scores_or_no_score
  validate :must_have_distinct_players
  validate :must_have_valid_scores, if: -> { score1.present? }

  scope :for_participant, ->(p) { where('participant1_id = ? or participant2_id = ?', p.id, p.id) }
  scope :unfinished, -> { where(score1: nil, score2: nil) }
  scope :finished, -> { where('score1 is not null and score2 is not null') }

  after_save :ping_round_for_closure

  def finished?
    score1.present? && score2.present?
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

  protected

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
