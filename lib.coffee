checkPath = (path) ->
  if _.isString path
    check path, Match.NonEmptyString

    throw new Match.Error "Cannot modify '#{path}'." if path in ['_id', '_connectionId']

  else
    update = path

    check update, Object

    for field, value of update
      throw new Match.Error "Cannot modify '#{field}'." if field in ['_id', '_connectionId']

      # We do not allow MongoDB operators.
      throw new Match.Error "Invalid field name '#{field}'." if field[0] is '$'

  true

share.handleMethods = (connection, collection, subscriptionId) ->
  data: (path, equalsFunc) ->
    if path?
      fields = {}
      # A small optimization for the common case.
      fields[path] = 1 if _.isString path

      DataLookup.get ->
        collection.findOne subscriptionId, fields: fields
      ,
        path, equalsFunc
    else
      data = collection.findOne subscriptionId,
        fields:
          _connectionId: 0

      return data unless data

      # We have to query with "_id" included for reactivity
      # to work, but we do not want to expose it.
      _.omit data, '_id'

  setData: (path, value) ->
    if value is undefined
      args = [subscriptionId, path]
    else
      args = [subscriptionId, path, value]

    connection.apply '_subscriptionDataSet', args, (error) =>
      console.error "_subscriptionDataSet error", error if error

share.subscriptionDataMethods = (collection) ->
  _subscriptionDataSet: (subscriptionId, path, value) ->
    check subscriptionId, Match.DocumentId
    check path, Match.Where checkPath
    check value, Match.Any

    if Meteor.isClient
      # @connection is available only on the server side, but this is OK,
      # because on the client side "_connectionId" field does not exist
      # anyway (it is not published), so {_connectionId: null} in fact does
      # exactly the right thing: finds documents without "_connectionId".
      connectionId = null
    else
      # On the server side @connection does not exist when method is called
      # from the server side (for example, from the publish function) so we
      # have to get "connectionId" ourselves. We can do that because server
      # side is trusted.
      connectionId = @connection?.id or collection.findOne(subscriptionId)?._connectionId

    if _.isString path
      update = {}
      if value is undefined
        update.$unset = {}
        update.$unset[path] = ''
      else
        update.$set = {}
        update.$set[path] = value

    # We checked that the "path" is an object.
    else
      # We have to add "_connectionId", otherwise it will be removed.
      update = _.extend path,
        _connectionId: connectionId

    # We make sure (on the server side) that "_connectionId" matches current
    # connection to prevent malicious requests who guess the "subscriptionId"
    # to modify the state of other subscriptions.
    collection.update
      _id: subscriptionId
      _connectionId: connectionId
    ,
      update
