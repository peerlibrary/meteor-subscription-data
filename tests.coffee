if Meteor.isServer
  TestDataCollection = new Mongo.Collection null

  Meteor.methods
    insertTest: (obj) ->
      TestDataCollection.insert obj

    updateTest: (selector, query) ->
      TestDataCollection.update selector, query

    removeTest: (selector) ->
      TestDataCollection.remove selector

  Meteor.publish 'testDataPublish', ->
    @autorun (computation) =>
      @setData 'countAll', TestDataCollection.find().count()

      return

    @autorun (computation) =>
      TestDataCollection.find({}, {sort: {i: 1}, limit: @data('limit')}).observeChanges
        addedBefore: (id, fields, before) =>
          @added 'testDataCollection', id, fields
        changed: (id, fields) =>
          @changed 'testDataCollection', id, fields
        removed: (id) =>
          @removed 'testDataCollection', id

      @ready()

    return

  Meteor.publish 'testPublish', ->
    id = Random.id()

    previousData = {}

    @autorun (computation) =>
      newData = @data()

      data = _.clone newData

      for field of previousData when field not of data
        data[field] = undefined

      if computation.firstRun
        @added 'testCollection', id, data
      else
        @changed 'testCollection', id, data

      previousData = newData

      return

    @ready()

else
  TestDataCollection = new Mongo.Collection 'testDataCollection'
  TestCollection = new Mongo.Collection 'testCollection'

class BasicTestCase extends ClassyTestCase
  @testName: 'subscription-data - basic'

  setUpServer: ->
    TestDataCollection.remove {}

  testClientBasic: [
    ->
      @subscription1 = @assertSubscribeSuccessful 'testPublish', @expect()
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{}]
      @assertEqual @subscription1.data(), {}

      @subscription1.setData {foo: 'test', bar: 123}

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{foo: 'test', bar: 123}]
      @assertEqual @subscription1.data(), {foo: 'test', bar: 123}

      @subscription1.setData 'foo', 'test2'

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{foo: 'test2', bar: 123}]
      @assertEqual @subscription1.data(), {foo: 'test2', bar: 123}

      @subscription1.setData 'foo', undefined

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{bar: 123}]
      @assertEqual @subscription1.data(), {bar: 123}

      @subscription1.setData 'foo', 'test3'

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{foo: 'test3', bar: 123}]
      @assertEqual @subscription1.data(), {foo: 'test3', bar: 123}

      @subscription1.setData {}

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{}]
      @assertEqual @subscription1.data(), {}
  ]

  testClientTwoWay: [
    ->
      @subscription2 = @assertSubscribeSuccessful 'testDataPublish', @expect()
  ,
    ->
      @assertEqual TestDataCollection.find({}).fetch(), []
      @assertEqual @subscription2.data(), {countAll: 0}

      for i in [0...10]
        Meteor.call 'insertTest', {i: i}, @expect (error, documentId) =>
          @assertFalse error, error
          @assertTrue documentId
  ,
    ->
      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 100 # ms
  ,
    ->
      @assertEqual TestDataCollection.find({}).count(), 10
      @assertEqual @subscription2.data(), {countAll: 10}

      @subscription2.setData 'limit', 5

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 100 # ms
  ,
    ->
      @assertEqual TestDataCollection.find({}).count(), 5
      @assertEqual @subscription2.data(), {countAll: 10, limit: 5}

      for i in [0...10]
        Meteor.call 'insertTest', {i: i}, @expect (error, documentId) =>
          @assertFalse error, error
          @assertTrue documentId
  ,
    ->
      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 100 # ms
  ,
    ->
      @assertEqual TestDataCollection.find({}).count(), 5
      @assertEqual @subscription2.data(), {countAll: 20, limit: 5}
  ]

ClassyTestCase.addTest new BasicTestCase()
