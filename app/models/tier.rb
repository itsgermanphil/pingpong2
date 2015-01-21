class Tier < ActiveRecord::Base
  belongs_to :round

  def participants(round)
    Participant.where(tier_id: self.id, round_id: round.id)
  end

  validates :level, uniqueness: true

  %w(admin ambassadors awesome plus free).each do |fn|
    define_method "#{fn}?" do
      self.name.downcase == fn
    end
  end
end
