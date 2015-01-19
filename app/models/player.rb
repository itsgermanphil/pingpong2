class Player < ActiveRecord::Base
  has_and_belongs_to_many :tiers

  def games(round)
    Participant.where(player: self).map {|p| p.game}.select { |game| game.tier.round == round }
  end

  def current_score
    round_score(Round.active)
  end

  def round_score(round)
    games(round).inject(0) do |total, game|
      score = game.participants.where(player: self).first.score
      total += score unless score == nil
      total
    end
  end

  def total_score
    0
  end
end
