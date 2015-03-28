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

  def up_arrow
    '<span class="glyphicon glyphicon-arrow-up"></span>'.html_safe
  end
  def down_arrow
    '<span class="glyphicon glyphicon-arrow-down"></span>'.html_safe
  end
  def arrow(n)
    if n > 0
      arrow_up
    else
      arrow_down
    end
  end

end
