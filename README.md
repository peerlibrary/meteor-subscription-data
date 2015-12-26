subscription data context
=========================

This Meteor smart package provides a reactive and shared (between client and server side)
subscription data context. When you [subscribe](http://docs.meteor.com/#/full/meteor_subscribe)
to a publish endpoint, a reactive data context is established which can be read and changed both
on the client or server side to provide alternative (reactive) way of passing arguments
to the publish endpoint, without subscription restarting. To be useful, use
[peerlibrary:reactive-publish](https://github.com/peerlibrary/meteor-reactive-publish) and
[server-side autorun](https://github.com/peerlibrary/meteor-server-autorun) in your publish
endpoint function to react to data context changes.

Adding this package to your [Meteor](http://www.meteor.com/) application extends
publish endpoint function's `this` and subscription's handle with `data` and `setData` methods.

Both client and server side.

Installation
------------

```
meteor add peerlibrary:subscription-data
```

API
---

The subscription handle returned from [`Meteor.subscribe`](http://docs.meteor.com/#/full/meteor_subscribe)
contains two new methods:

* `data(path)` – returns current data context object; if `path` is specified, returns value under `path` in the data
  context; it uses [data-lookup](https://github.com/peerlibrary/meteor-data-lookup) package to resolve the path
* `setData(path, value)` - sets the value under `path` in the data context object to `value`; if `value` is `undefined`,
  path is unset; alternatively, you can pass the whole new data context object which will be used as the new data context

Same methods are available also inside the [publish endpoint](http://docs.meteor.com/#/full/meteor_publish) function
through `this`.

Example
-------

If on the server side you have such publish endpoint:

```javascript
Meteor.publish('infinite-scroll', function () {
  var self = this;

  self.autorun(function (computation) {
    self.setData('countAll', MyCollection.find().count());
  });

  self.autorun(function (computation) {
    return MyCollection.find({}, {limit: self.data('limit') || 10});
  });
});
```

Then you can on the client side subscribe to it and control it without restarting the subscription:

```javascript
var subscription = Meteor.subscribe('infinite-scroll');

// Returns the count of all documents in the
// collection, even if only a subset is published.
subscription.data('countAll');

// Sets a new limit for published documents. Only the extra documents
// are send to the client and subscription does not restart.
subscription.setData('limit', 20);
```
