class Round < ActiveRecord::Base
  has_many :participants
  has_many :players, through: :participants
  has_many :games

  scope :active, -> { where(end_date: nil) }

  def tiers
    Tier.where(id: participants.pluck(:tier_id).uniq)
  end

  def self.find_or_build_current_round
    # TODO
    return Round.first
    Round.active.order(:id).last || build_next_round(Round.order(:id).last)
  end

  def create_games
    participants.group_by(&:tier_id).each do |tier_id, participants|
      participants.combination(2) do |p1, p2|
        build_game(p1, p2)
      end
    end
  end

  def finished?
    end_date.present?
  end

  def in_progress?
    end_date.nil?
  end

  def self.build_next_round(prev_round)
    # TODO
    return
    # if nil, we need to seed the tiers randomly
    if !prev_round
      #seed_tiers

      Player.find_each do |player|
        add_player(player)
      end

      Tier.find_each do |tier|

      end
    else
      # otherwise we build tiers based on the previous round standings

      # duplicate each tier
      prev_round.tiers.each do |prev_tier|
        tier = Tier.new(name: prev_tier.name, level: prev_tier.level)
        prev_tier.players.each { |player| tier.players.push(player) }
      end

      # move top/bottom 2 at tier boundaries


    end
    save
  end

  # This method can be called repeatedly, it does nothing on sebsequent calls
  def add_player(player)
    # See if this player is already in this round
    return if participants.where(player_id: player.id).exists?

    tier = tiers.order(:level).reverse.min_by { |tier| tier.participants(self).count }

    Round.transaction do
      p1 = Participant.create!(round_id: id,
                               tier_id: tier.id,
                               player_id: player.id)

      tier.participants(self).where('player_id != ?', player.id).each do |p2|
        build_game(p1, p2)
      end
      return p1
    end
  end

  def check_for_completion
    return unless games.all?(&:finished?)

    self.end_date ||= Time.now
    save!
  end


  private

  def build_game(p1, p2)
    Game.where(round_id: id, participant1_id: p1.id, participant2_id: p2.id).first_or_create!
  end

end
