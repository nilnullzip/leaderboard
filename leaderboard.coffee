# Set up a collection to contain player information. On the server,
# it is backed by a MongoDB collection named "players".
Players = new (Mongo.Collection)('players')

if Meteor.isClient

  Template.leaderboard.helpers
    players: ->
      Players.find {}, sort:
        score: -1
        name: 1
    selectedName: ->
      player = Players.findOne(Session.get('selectedPlayer'))
      player?.name

  Template.leaderboard.events
    'click .inc': ->
      Meteor.call 'inc', Session.get('selectedPlayer'), 5

  Template.leaderboard.onCreated ->
    Meteor.subscribe 'players'

  Template.player.helpers
    selected: ->
      if Session.equals('selectedPlayer', @_id) then 'selected' else ''

  Template.player.events
    'click': ->
      Session.set 'selectedPlayer', @_id

if Meteor.isServer

  Meteor.methods
    inc: (player, count)->
      Players.update player, $inc: score: count

  Meteor.publish 'players', ->
    Players.find()

  # On server startup, create some players if the database is empty.
  Meteor.startup ->
    if !Players.find().count()
      for name in ['Ada Lovelace', 'Grace Hopper', 'Marie Curie','Carl Friedrich Gauss','Nikola Tesla','Claude Shannon']
        Players.insert
          name: name
          score: Math.floor(Random.fraction() * 10) * 5
