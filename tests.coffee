if Meteor.isServer
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
  TestCollection = new Mongo.Collection 'testCollection'

class BasicTestCase extends ClassyTestCase
  @testName: 'subscription-data - basic'

  testClientBasic: [
    ->
      @subscription = @assertSubscribeSuccessful 'testPublish', @expect()
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{}]
      @assertEqual @subscription.data(), {}

      @subscription.setData {foo: 'test', bar: 123}

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{foo: 'test', bar: 123}]
      @assertEqual @subscription.data(), {foo: 'test', bar: 123}

      @subscription.setData 'foo', 'test2'

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{foo: 'test2', bar: 123}]
      @assertEqual @subscription.data(), {foo: 'test2', bar: 123}

      @subscription.setData 'foo', undefined

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{bar: 123}]
      @assertEqual @subscription.data(), {bar: 123}

      @subscription.setData 'foo', 'test3'

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{foo: 'test3', bar: 123}]
      @assertEqual @subscription.data(), {foo: 'test3', bar: 123}

      @subscription.setData {}

      # To wait a bit for change to propagate.
      Meteor.setTimeout @expect(), 10 # ms
  ,
    ->
      @assertEqual TestCollection.find({}, {fields: _id: 0}).fetch(), [{}]
      @assertEqual @subscription.data(), {}
  ]

ClassyTestCase.addTest new BasicTestCase()
