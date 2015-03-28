class Player < ActiveRecord::Base
  belongs_to :last_round, class_name: 'Round', foreign_key: 'last_round_id'

  has_many :participants, dependent: :destroy

  validates :uid, presence: true
  validates :name, :email, presence: true

  validates :email, uniqueness: true

  before_validation :normalize_email

  scope :active, -> { where(active: true) }

  class AuthorizationError < StandardError; end

  def rating_bonus
    all_finished_1v1_games.select { |g| g.finished_at > 1.month.ago }.count.to_f * 1.5
  end

  def elo_rating_with_bonus
    elo_rating + rating_bonus
  end

  def self.recalculate_ratings!(method = :apply_elo_ratings)
    transaction do
      Game.update_all(
        elo_rating1_in: nil,
        elo_rating2_in: nil,
        elo_rating1_out: nil,
        elo_rating2_out: nil
      )

      Player.update_all(elo_rating: 1000)

      games = Round.free_play_round.games.finished.order(:finished_at)

      games.each do |g|
        g.send(method)
      end
    end
  end

  def normalize_email
    self.email = self.email.try(:downcase).try(:strip)
  end

  def games(round)
    Participant.where(player: self).map(&:game).select { |game| game.tier.round == round }
  end

  def all_finished_games
    Participant.where(player: self).flat_map(&:games).uniq.select(&:finished?).sort_by(&:finished_at)
  end

  def all_finished_1v1_games
    all_finished_games.select { |g| g.elo_rating1_in.present? }
  end

  def round_score(round = Round.active)
    calc_score games(round)
  end

  def total_score
    calc_score all_finished_games
  end

  def display_name
    name
  end

  def current_tier
    # Find the last round in which the player participated in
    public_rounds = Round.where(public: true)
    p = Participant.order('id desc').where(player_id: id, round_id: public_rounds).first
    p.try(:tier)
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
