module ApplicationHelper
  def with_sign(n, round = 1)
    if n > 0
      "+#{n.round(round)}"
    else
      "#{n.round(round)}"
    end
  end

  def elo(n)
    return '' unless n.present?
    n.round(1)
  end
end
