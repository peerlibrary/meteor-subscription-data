SubscriptionData = new Mongo.Collection null

CONNECTION_ID_REGEX = /^.+?_/

extendPublish (name, func, options) ->
  newFunc = (args...) ->
    publish = @

    # If it is an unnamed publish endpoint, we do not do anything special.
    return func.apply publish, args unless publish._subscriptionId

    assert _.isString(publish._subscriptionId), publish._subscriptionId

    # On the server we store _id prefixed with connection ID.
    id = "#{publish.connection.id}_#{publish._subscriptionId}"

    SubscriptionData.insert
      _id: id
      _connectionId: @connection.id

    _.extend publish, share.handleMethods Meteor, SubscriptionData, id

    result = func.apply publish, args

    # We want this to be cleaned-up at the very end, after any other
    # onStop callbacks registered inside the func.
    publish.onStop ->
      SubscriptionData.remove
        _id: id

    result

  [name, newFunc, options]

Meteor.publish null, ->
  handle = SubscriptionData.find(
    _connectionId: @connection.id
  ,
    fields:
      _connectionId: 0
  ).observeChanges
    added: (id, fields) =>
      id = id.replace CONNECTION_ID_REGEX, ''
      @added '_subscriptionData', id, fields
    changed: (id, fields) =>
      id = id.replace CONNECTION_ID_REGEX, ''
      @changed '_subscriptionData', id, fields
    removed: (id) =>
      id = id.replace CONNECTION_ID_REGEX, ''
      @removed '_subscriptionData', id

  @onStop =>
    handle.stop()

  @ready()

Meteor.methods share.subscriptionDataMethods SubscriptionData
