# Description:
#   Let hubot track your co-workers' honor points
#
# Configuration:
#   HUBOT_SCOREKEEPER_MENTION_PREFIX
#
# Commands:
#   <name>++ - Increment <name>'s point
#   <name>-- - Decrement <name>'s point
#   scorekeeper - Show scoreboard
#   show scoreboard - Show scoreboard
#   scorekeeper <name> - Show current point of <name>
#   what's the score of <name> - Show current point of <name>
#
# Author:
#   yoshiori

class Scorekeeper
  _prefix = "scorekeeper"

  constructor: (@robot) ->
    @_loaded = false
    @_scores = {}
    @robot.brain.on 'loaded', =>
      @_load()
      @_loaded = true

  increment: (user, func) ->
    unless @_loaded
      setTimeout((=> @increment(user,func)), 200)
      return
    @_scores[user] = @_scores[user] or 0
    @_scores[user]++
    @_save()
    @score user, func

  decrement: (user, func) ->
    unless @_loaded
      setTimeout((=> @decrement(user,func)), 200)
      return
    @_scores[user] = @_scores[user] or 0
    @_scores[user]--
    @_save()
    @score user, func

  score: (user, func) ->
    func false, @_scores[user] or 0

  remove: (user, func) ->
    score = @_scores[user]
    delete @_scores[user]
    @_save()
    func false, score

  rank: (func)->
    ranking = (for name, score of @_scores
      [name, score]
    ).sort (a, b) -> b[1] - a[1]
    func false, (for i in ranking
      i[0]
    )

  _load: ->
    scores_json = @robot.brain.get _prefix
    scores_json = scores_json or '{}'
    @_scores = JSON.parse scores_json

  _save: ->
    scores_json = JSON.stringify @_scores
    @robot.brain.set _prefix, scores_json


module.exports = (robot) ->
  scorekeeper = new Scorekeeper robot
  mention_prefix = process.env.HUBOT_SCOREKEEPER_MENTION_PREFIX
  if mention_prefix
    mention_matcher = new RegExp("^#{mention_prefix}")

  userName = (user) ->
    user = user.trim().split(/\s/).slice(-1)[0]
    if mention_matcher
      user = user.replace(mention_matcher, "")
    user

  robot.hear /\w+(?:(?:\+\+)|(?:\-\-))/g, (msg) ->
    for str in msg.match
      user = userName(str.slice(0, -2))
      direction = str.slice(-2)
      if direction == "++"
        scorekeeper.increment user, (error, result) ->
          msg.send "incremented #{user} (#{result} pt)"
      else if direction == "--"
        scorekeeper.decrement user, (error, result) ->
          msg.send "decremented #{user} (#{result} pt)"

  robot.respond /scorekeeper$|show(?: me)?(?: the)? (?:scorekeeper|scoreboard)$/i, (msg) ->
    scorekeeper.rank (error, result) ->
      msg.send (for rank, name of result
        "#{parseInt(rank) + 1} : #{name}"
      ).join("\n")

  robot.respond /scorekeeper remove (.+)$/i, (msg) ->
    user = userName(msg.match[1])
    scorekeeper.remove user, (error, result) ->
      msg.send "#{user} has been removed. (#{result} pt)"

  robot.respond /scorekeeper (.+)$|what(?:'s| is)(?: the)? score of (.+)\??$/i, (msg) ->
    user = userName(msg.match[1] || msg.match[2])
    scorekeeper.score user, (error, result) ->
      msg.send "#{user} has #{result} points"
