# Author:
#   yoshiori
Url   = require "url"
Redis = require "redis"

class Scorekeeper
  info   = Url.parse process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL or process.env.BOXEN_REDIS_URL or process.env.REDIS_URL or 'redis://localhost:6379', true
  client = Redis.createClient(info.port, info.hostname)
  prefix = "scorekeeper"

  increment: (user, func) ->
    client.zincrby prefix, 1, user, func

  decrement: (user, func) ->
    client.zincrby prefix, -1, user, func

  score: (user, func) ->
    client.zscore prefix, user, func

  rank: (func)->
    client.zrevrangebyscore prefix, "+INF", "-INF", func

module.exports = (robot) ->
  scorekeeper = new Scorekeeper
  mention_prefix = process.env.HUBOT_SCOREKEEPER_MENTION_PREFIX
  if mention_prefix
    mention_matcher = new RegExp("^#{mention_prefix}")

  robot.hear /(.+)\+\+$/, (msg) ->
    user = msg.match[1].trim()
    if mention_matcher
      user = user.replace(mention_matcher, "")
    scorekeeper.increment user, (error, result) ->
      msg.send "#{user} increment!! (total : #{result})"

  robot.hear /(.+)\-\-$/, (msg) ->
    user = msg.match[1].trim()
    scorekeeper.decrement user, (error, result) ->
      msg.send "#{user} decrement!! (total : #{result})"

  robot.respond /scorekeeper$/i, (msg) ->
    scorekeeper.rank (error, result) ->
      msg.send (for name, standing of result
        "#{standing}: #{name}"
      ).join("\n")

  robot.respond /scorekeeper (.*)/i, (msg) ->
    user = msg.match[1].trim()
    if user
      scorekeeper.score user, (error, result) ->
        msg.send "#{user} (total : #{result})"
