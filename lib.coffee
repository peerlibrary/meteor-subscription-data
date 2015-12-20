checkArgs = (args) ->
  if args.length >= 2
    [key, value] = args

    check key, Match.NonEmptyString

    throw new Match.Error "Cannot modify '_connectionId'." if key is '_connectionId'

  else
    update = args[0]

    check update, Object

    for field, value of update
      throw new Match.Error "Cannot modify '#{field}'." if field in ['_id', '_connectionId']

      # We do not allow MongoDB operators.
      throw new Match.Error "Invalid field name '#{field}'." if field[0] is '$'

  true

share.handleMethods = (connection, collection, subscriptionId) ->
  data: (key) ->
    if key
      fields = {}
      fields[key] = 1

      collection.findOne(subscriptionId, fields: fields)?[key]
    else
      data = collection.findOne subscriptionId,
        fields:
          _connectionId: 0

      return data unless data

      # We have to query with "_id" included for reactivity
      # to work, but we do not want to expose it.
      _.omit data, '_id'

  setData: (args...) ->
    connection.apply '_subscriptionDataSet', [subscriptionId].concat(args), (error) =>
      console.error "_subscriptionDataSet error", error if error

share.subscriptionDataMethods = (collection) ->
  _subscriptionDataSet: (subscriptionId, args...) ->
    check subscriptionId, Match.DocumentId
    check args, Match.Where checkArgs

    # @connection is available only on the server side, but this is OK,
    # because on the client side "_connectionId" field does not exist
    # anyway (it is not published), so {_connectionId: null} in fact does
    # exactly the right thing, finds documents without "_connectionId".
    connectionId = @connection?.id or null

    if args.length >= 2
      [key, value] = args

      update = {}
      if value is undefined
        update.$unset = {}
        update.$unset[key] = ''
      else
        update.$set = {}
        update.$set[key] = value

      collection.update
        _id: subscriptionId
        _connectionId: connectionId
      ,
        update

    else if _.isObject args[0]
      collection.update
        _id: subscriptionId
        _connectionId: connectionId
      ,
        _.extend args[0],
          _connectionId: connectionId
