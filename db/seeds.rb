# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

unless Rails.env.test?
  seed_round = {
    'Admin' => [
      'me@sharlek.com',
      'luc.luxton@gmail.com',
      'xuepaul.xp@gmail.com',
      'mckayjamesa@gmail.com',
      'brandonyeh2934@gmail.com'
    ], 'Ambassador' => [
      'jun@dragonflystudios.ca',
      'hailey@500px.com',
      'mikelerner.me@gmail.com',
      '1@alexf.ca',
      'mralefina@gmail.com'
    ], 'Awesome' => [
      'natta@500px.com',
      'maryna.bilousova@gmail.com',
      'shutsa@gmail.com',
      'kaitlyn2004@gmail.com',
      'andyyangstar@gmail.com'
    ], 'Plus' => [
      'zimu.liu@gmail.com',
      'iamjeffshin@gmail.com',
      'tim.gaweco@gmail.com',
      'dustin@dustinplett.ca',
      'tighe.michael@gmail.com'
    ], 'Free' => [
      'catalin.bordianu@gmail.com',
      'me@meagar.net',
      'renat.g@gmail.com',
      'ryan.ming@gmail.com',
      'bpfott@gmail.com',
      'eric.akaoka@gmail.com'
    ]
  }


  seed_round.keys.each.with_index do |tier_name, index|
    puts "Creating tier #{tier_name}"
    Tier.first_or_create!(name: tier_name, level: index)
  end

  round = Round.first_or_create!(id: 1)

  seed_round.each do |tier_name, players|
    puts "finding #{tier_name}"
    tier = Tier.find_by!(name: tier_name)
    players.each do |email|
      puts "Seeding player #{email} in tier #{tier_name}"
      player = Player.first_or_initialize(name: email, email: email, uid: -1)
      player.save!

      p = round.participants.first_or_create!(player_id: player.id, tier_id: tier.id)
    end
  end

  round.create_games
end
