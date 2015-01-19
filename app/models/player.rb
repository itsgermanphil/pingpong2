class Player < ActiveRecord::Base
  has_and_belongs_to_many :tiers

  validates :uid, presence: true
  validates :name, :email, presence: true

  def games(round)
    Participant.where(player: self).map {|p| p.game}.select { |game| game.tier.round == round }
  end

  def all_games
    Participant.where(player: self).map {|p| p.game}
  end

  def round_score(round = Round.active)
    calc_score games(round)
  end

  def total_score
    calc_score all_games
  end

  private

  def calc_score(games)
    games.inject(0) do |total, game|
      if game.complete?
        score = game.participants.where(player: self).first.score
        opponent_score = game.participants.where.not(player: self).first.score
        total += score - opponent_score
      end
      total
    end
  end

  def self.find_or_create_from_auth_hash(auth_hash)
    p = Player.where(uid: auth_hash['uid']).first_or_initialize

    raise 'You cannot do that!' unless auth_hash['extra']['raw_info']['user']['admin'] == 1

    p.name = auth_hash['info']['name']
    p.email = auth_hash['info']['email']

    p.save!
    p
  end
end
