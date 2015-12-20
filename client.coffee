Connection = Meteor.connection.constructor

Connection::_initializeSubscriptionData = ->
  return if @_subscriptionData

  @_subscriptionData = new Mongo.Collection '_subscriptionData', connection: @

  @methods share.subscriptionDataMethods @_subscriptionData

originalLivedataConnected = Connection::_livedata_connected
Connection::_livedata_connected = (args...) ->
  @_initializeSubscriptionData()

  originalLivedataConnected.apply @, args

originalSubscribe = Connection::subscribe
Connection::subscribe = (args...) ->
  @_initializeSubscriptionData()

  handle = originalSubscribe.apply @, args

  _.extend handle, share.handleMethods @, @_subscriptionData, handle.subscriptionId

# Recreate the convenience method.
Meteor.subscribe = _.bind Meteor.connection.subscribe, Meteor.connection
