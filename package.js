Package.describe({
  name: 'peerlibrary:subscription-data',
  summary: "Extended Meteor.userId() and Meteor.user()",
  version: '0.1.0',
  git: 'https://github.com/peerlibrary/meteor-subscription-data.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.0.3.1');

  // Core dependencies.
  api.use([
    'coffeescript',
    'mongo',
    'underscore'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:check-extension@0.2.0'
  ]);

  api.addFiles([
    'lib.coffee'
  ]);

  api.addFiles([
    'server.coffee'
  ], 'server');

  api.addFiles([
    'client.coffee'
  ], 'client');
});

Package.onTest(function (api) {
  // Core dependencies.
  api.use([
    'coffeescript',
    'accounts-password',
    'random',
    'mongo',
    'underscore'
  ]);

  // Internal dependencies.
  api.use([
    'peerlibrary:subscription-data'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:reactive-publish@0.1.1',
    'peerlibrary:classy-test@0.2.15'
  ]);

  api.addFiles([
    'tests.coffee'
  ]);
});
