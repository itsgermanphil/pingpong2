# Rounds are the top-level unit of game time
# Each round is a mini-tournament, sub-divided into "tiers"
# A round is over when each player has played every other player in their tier
# When one round starts, the next one automatically beings the next time a
# player makes a request for the "current "round.
class Round < ActiveRecord::Base
  has_many :participants
  has_many :players, through: :participants
  has_many :games

  scope :tournament, -> { where(public: true) }

  before_validation :assign_round_number

  validates :start_date, presence: true

  validates :round_number, presence: true

  scope :active, -> { where(end_date: nil) }

  def self.free_play_round
    self.unscoped.where(public: false).first
  end

  def tiers
    Tier.where(id: participants.pluck(:tier_id).uniq)
  end

  def self.find_or_build_current_round
    # TODO
    Round.tournament.active.order(:id).last || build_next_round(Round.order(:id).last)
  end

  def create_games
    participants.group_by(&:tier_id).each do |_, participants|
      participants.combination(2) do |p1, p2|
        build_game(p1, p2)
      end
    end
  end

  def assign_round_number
    self.round_number ||= Round.count + 1
  end

  def finished?
    end_date.present?
  end

  def in_progress?
    end_date.nil?
  end

  def self.build_next_round(prev_round)
    if Round.active.any? || prev_round.in_progress?
      fail 'Cannot build round while a round is in progress'
    end

    Round.transaction do
      new_groups = Hash[Tier.pluck(:level).sort.map { |level| [level, []] }]
      last_level = new_groups.keys.max

      prev_round.participants.group_by(&:tier_id).each do |id, participants|
        tier = Tier.find(id)
        participants = participants.sort_by(&:points).reverse
        if tier.level == 0
          # No upwards movement
          new_groups[tier.level].concat(participants[0..-3])
          new_groups[tier.level + 1].concat(participants.last(2))
        elsif  tier.level < last_level
          # Move two players up...
          new_groups[tier.level - 1].concat(participants.first(2))
          new_groups[tier.level].concat(participants[2..-3])
          new_groups[tier.level + 1].concat(participants.last(2))
        else
          new_groups[tier.level - 1].concat(participants.first(2))
          new_groups[tier.level].concat(participants[2..-1])
        end
      end

      new_round = Round.create!(start_date: Time.now, public: true)

      new_groups.each do |level, players|
        tier = Tier.find_by!(level: level)
        players.each do |player|
          new_round.add_player(player.player, tier)
        end
      end

      return new_round
    end
  end

  # This method can be called repeatedly, it does nothing on sebsequent calls
  def add_player(player, tier = nil)
    # See if this player is already in this round
    return if participants.where(player_id: player.id).exists?

    Round.transaction do
      p1 = Participant.create!(round_id: id,
                               tier_id: (tier || smallest_tier).id,
                               player_id: player.id)

      create_games_for(p1)
      return p1
    end
  end

  def smallest_tier
    tiers.order(:level).reverse.min_by { |tier| tier.participants(self).count }
  end

  def create_games_for(p1)
    others = p1.tier.participants(self).where('player_id != ?', p1.player.id)
    Round.transaction do
      others.each { |p2| build_game(p1, p2) }
    end
  end

  def check_for_completion
    return unless self.public == true
    return unless games.all?(&:finished?)

    self.end_date ||= Time.now
    save!
  end

  private

  def build_game(p1, p2)
    Game.where(round_id: id, participant1_id: p1.id, participant2_id: p2.id).first_or_create!
  end

end
