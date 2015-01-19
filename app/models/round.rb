class Round < ActiveRecord::Base
  has_many :tiers
  has_many :players, through: :tiers
  has_many :games, through: :tiers

  scope :active, -> { order(start_date: :desc).first }

  def build(prev_round = nil)
    # if nil, we need to seed the tiers randomly
    if !prev_round
      seed_tiers

      Player.all.each { |player| add_player(player) }
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

  def add_player(player)
    tiers.min_by { |tier| tier.players.count }.players.push(player)
  end

  def start
    # generate games
    tiers.each do |tier|
      tier.players.each_index do |index1|
        tier.players.slice(index1 + 1..tier.players.count).each_index do |index2|
          puts "!! #{index1} VS #{index1 + index2}"
          create_game(tier.players.at(index1), tier.players.at(index1 + index2 + 1), tier)
        end
      end

      # tier.players.each do |player1|
      #   tier.players.each do |player2|
      #     create_game(player1, player2, tier) unless player1 == player2
      #   end
      # end

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
    tiers.push Tier.create(name: "Free", level: 0)
    tiers.push Tier.create(name: "Plus", level: 1)
    tiers.push Tier.create(name: "Awesome", level: 2)
    tiers.push Tier.create(name: "Ambassador", level: 3)
    tiers.push Tier.create(name: "Admin", level: 4)
  end

  def create_game(player1, player2, tier)
    game = Game.create(tier: tier)
    Participant.create(player: player1, game: game)
    Participant.create(player: player2, game: game)
  end

end
