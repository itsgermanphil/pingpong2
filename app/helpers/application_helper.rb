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
      up_arrow
    else
      down_arrow
    end
  end

  def player_name(player)
    content_tag(:div, class: 'hidden-xs visible-sm-inline visible-md-inline visible-lg-inline') do
      player.name
    end + content_tag(:div, class: 'visible-xs-inline hidden-sm hidden-md hidden-lg') do
      player.short_name
    end
  end

  def round_name(round)
    if !round.public
      '1-vs-1'
    else
      "Round #{round.round_number}"
    end
  end

end
