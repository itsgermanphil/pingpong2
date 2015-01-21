class Player < ActiveRecord::Base
  has_and_belongs_to_many :tiers

  validates :uid, presence: true
  validates :name, :email, presence: true

  validates :email, uniqueness: true

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

  def display_name
    if name[/ /]
      parts = name.split(' ')
      [parts.first, parts.second[0]].join(' ')
    elsif name[/@/]
      name.split('@').first
    end
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
    # Find the players based on email (first-time login) or auth UID, which never changes
    p = Player.where('email = ? or uid = ?', auth_hash['info']['email'], auth_hash['uid'].to_s).first_or_initialize

    raise 'You cannot do that!' unless auth_hash['extra']['raw_info']['user']['admin'] == 1

    p.uid ||= auth_hash['uid']
    p.name = auth_hash['info']['name']
    p.email = auth_hash['info']['email']

    p.save!
    p
  end
end
