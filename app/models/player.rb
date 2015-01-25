class Player < ActiveRecord::Base
  belongs_to :last_round, class_name: 'Round', foreign_key: 'last_round_id'
  has_many :participants, dependent: :destroy

  validates :uid, presence: true
  validates :name, :email, presence: true

  validates :email, uniqueness: true

  before_validation :normalize_email

  class AuthorizationError < StandardError; end

  def normalize_email
    self.email = self.email.try(:downcase).try(:strip)
  end

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
    name
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
    raise AuthorizationError, 'You cannot do that!' unless auth_hash['extra']['raw_info']['user']['admin'] == 1

    # Find the players based on email (first-time login) or auth UID, which never changes
    p = Player.where('email = ? or uid = ?', auth_hash['info']['email'].downcase, auth_hash['uid'].to_s).first

    p ||= Player.new
    p.uid ||= auth_hash['uid']
    p.nickname = auth_hash['info']['nickname']
    p.image = auth_hash['info']['image']
    p.name = auth_hash['info']['name']
    p.email = auth_hash['info']['email'].downcase

    p.save!
    p
  end

end
