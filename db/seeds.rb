# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

names = %w(Michael Matt Eric David Jeff Felix Vova Zimu Jun Kaitlyn Andy
        Alessandro Brian George Chris Paul Adam Barb Maryna Samson Kevin
        Alex Brandon Devon Ryan)

names.each do |name|
  Player.create(name: name)
end
