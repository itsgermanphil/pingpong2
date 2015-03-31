
$ ->

  $('.game-score-form button').on 'click', (e) ->
    $(e.currentTarget).closest('td').find('form').submit()

  $('form.edit_game, form.new_game').submit (e) ->
    score1 = $(e.currentTarget)
    $scores = $(e.currentTarget).find('input').filter (i, e) -> $(e).attr('type') == 'number'

    score1 = $scores.first().val() | 0
    score2 = $scores.last().val() | 0

    if score1 < 11 && score2 < 11
      alert("Play goes to 11 points. One player must have 11 points or more")
      return false

    if (score1 >= score2 && score1 - score2 < 2) || (score2 >= score1 && score2 - score1 < 2)
      alert("The winner must win by at least 2 points")
      return false

    if score1 > (Math.max(11, score2 + 2))
      alert("The winner can only win by 2 points")
      return false

    if score2 > (Math.max(11, score1 + 2))
      alert("The winner can only win by 2 points")
      return false

    true

