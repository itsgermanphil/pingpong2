class Player < ActiveRecord::Base
  has_and_belongs_to_many :tiers

  validates :uid, presence: true
  validates :name, :email, presence: true

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

  def self.find_or_create_from_auth_hash(auth_hash)
    p = Player.where(uid: auth_hash['uid']).first_or_initialize

    raise 'You cannot do that!' unless auth_hash['extra']['raw_info']['user']['admin'] == 1

    p.name = auth_hash['info']['name']
    p.email = auth_hash['info']['email']

    p.save!
    p
  end
end
