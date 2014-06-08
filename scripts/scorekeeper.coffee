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

  list: (func)->
    client.zrangebyscore prefix, "-INF", "+INF", func

module.exports = (robot) ->
  scorekeeper = new Scorekeeper

  robot.hear /(.+)\+\+$/, (msg) ->
    user = msg.match[1].trim()
    scorekeeper.increment user, (error, result) ->
      msg.send "#{user} increment!! (total : #{result})"

  robot.hear /(.+)\-\-$/, (msg) ->
    user = msg.match[1].trim()
    scorekeeper.decrement user, (error, result) ->
      msg.send "#{user} decrement!! (total : #{result})"

  robot.respond /scorekeeper list/i, (msg) ->
    scorekeeper.list (error, result) ->
      msg.send result

  robot.respond /scorekeeper (.*)/i, (msg) ->
