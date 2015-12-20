SubscriptionData = new Mongo.Collection null

originalPublish = Meteor.publish
Meteor.publish = (name, publishFunction) ->
  originalPublish name, (args...) ->
    publish = @

    # If it is an unnamed publish endpoint, we do not do anything special.
    return publishFunction.apply publish, args unless publish._subscriptionId

    SubscriptionData.insert
      _id: publish._subscriptionId
      _connectionId: publish.connection.id

    _.extend publish, share.handleMethods Meteor, SubscriptionData, publish._subscriptionId

    result = publishFunction.apply publish, args

    # We want this to be cleaned-up at the very end, after any other
    # onStop callbacks registered inside the publishFunction.
    publish.onStop ->
      SubscriptionData.remove publish._subscriptionId

    result

Meteor.publish null, ->
  handle = SubscriptionData.find(
    _connectionId: @connection.id
  ,
    fields:
      _connectionId: 0
  ).observeChanges
    added: (id, fields) =>
      @added '_subscriptionData', id, fields
    changed: (id, fields) =>
      @changed '_subscriptionData', id, fields
    removed: (id, fields) =>
      @removed '_subscriptionData', id

  @onStop =>
    handle.stop()

  @ready()

Meteor.methods share.subscriptionDataMethods SubscriptionData
