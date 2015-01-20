class Round < ActiveRecord::Base
  has_many :participants
  has_many :tiers, through: :participants
  has_many :players, through: :participants
  has_many :games

  scope :active, -> { where(end_date: nil) }

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

  def build_game(p1, p2)
    Game.where(round_id: id, participant1_id: p1.id, participant2_id: p2.id).first_or_create!
  end

  def in_progress?
    games.unfinished.any?
  end

  def self.build_next_round(prev_round = nil)
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

    tier = tiers.order(:level).reverse.min_by { |tier| tier.participants.count }

    p1 = Participant.create!(round_id: id,
                             tier_id: tier.id,
                             player_id: player.id)

    tier.participants.where('player_id != ?', player.id).each do |p2|
      build_game(p1, p2)
    end

    p1
  end

  def start
    # generate games
    tiers.each do |tier|
      tier.players.each_index do |index1|
        tier.players.slice(index1 + 1..tier.players.count).each_index do |index2|
          create_game(tier.players.at(index1), tier.players.at(index1 + index2 + 1), tier)
        end
      end
    end

    # set start date
    self.start_date = DateTime.current
    save
  end

  def complete?
    games.all? { |game| game.complete? }
  end

  def complete
    self.end_date = DateTime.current
    save
  end

  def active?
    self.end_date != nil
  end

  private

  def seed_tiers
    # hard-coded tiers?
    #tiers.push Tier.create(name: "Free", level: 0)
    #tiers.push Tier.create(name: "Plus", level: 1)
    #tiers.push Tier.create(name: "Awesome", level: 2)
    #tiers.push Tier.create(name: "Ambassador", level: 3)
    #tiers.push Tier.create(name: "Admin", level: 4)
  end

  def create_game(player1, player2, tier)
    game = Game.create(tier: tier)
    Participant.create(player: player1, game: game)
    Participant.create(player: player2, game: game)
  end

end
