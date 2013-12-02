irc = require('./irc')

{debug,info} = require ('./helpers')

class Room
  constructor: (@spark) ->

  join: (@nick, @channel) ->
    @channel = "##{channel}" unless channel[0] is "#"
    @irc = irc.join(@nick, @channel)
    @spark.join(@channel, -> debug "Joined #{@channel}")
    @spark.join("#{@channel}/#{@nick}", ->
      debug "Spark joined room #{@channel}/#{@nick}")

    @irc.on 'join', =>
      @spark.write(type: 'joined', payload: {})

    @irc.on 'data', (msg) =>
      # This needs better handling with messages from the server.
      if msg.command in ['PRIVMSG']
        @spark.write(
          type: 'message'
          payload: "#{msg.prefix.split('!')[0]}: #{msg.trailing}")
    @

  leave: (msg) ->
    @irc.quit()
    # leave webrtc

    @

  say: (msg) ->
    @irc.send(@channel, msg)
    @

  away: (msg) ->
    if msg then @irc.away(msg) else @irc.away("I'll be back!")
    @

  busy: (msg) ->
    @away(msg)
    @

  ircMembers: () ->
    @irc.names(@channel, (err, names) =>
      # Need to handle error
      @spark.write(
        type: 'ircMembers',
        payload: (name for name in names when name isnt @nick)))
    @

module.exports = Room
