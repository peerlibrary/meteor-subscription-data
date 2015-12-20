checkArgs: (args) ->
  if args.length >= 2
    [key, value] = args

    check key, Match.NonEmptyString

    throw new Match.Error "Cannot modify '_connectionId'." if key is '_connectionId'

  else
    update = args[0]

    check update, Object

    for field, value of update
      throw new Match.Error "Cannot modify '_connectionId'." if field is '_connectionId'

      # We do not allow MongoDB operators.
      throw new Match.Error "Invalid field name '#{field}'." if field[0] is '$'

  true

share.handleMethods = (collection, subscriptionId) ->
  data: (key) ->
    if key
      fields = {}
      fields[key] = 1

      collection.findOne(subscriptionId, fields: fields)?[key]
    else
      collection.findOne subscriptionId
        fields:
          _id: 0
          _connectionId: 0

  setData: (args...) ->
    @apply '_subscriptionDataSet', [subscriptionId].concat(args), (error) =>
      console.error "_subscriptionDataSet error", error if error

share.subscriptionDataMethods = (collection) ->
  _subscriptionDataSet: (subscriptionId, args...) ->
    check subscriptionId, Match.DocumentId
    check args, Match.Where checkArgs

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
        _connectionId: @connection.id
      ,
        update

    else if _.isObject args[0]
      collection.update
        _id: subscriptionId
        _connectionId: @connection.id
      ,
        args[0]
