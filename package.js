Package.describe({
  name: 'peerlibrary:subscription-data',
  summary: "Reactive and shared subscription data context",
  version: '0.6.0',
  git: 'https://github.com/peerlibrary/meteor-subscription-data.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.4.1');

  // Core dependencies.
  api.use([
    'coffeescript',
    'mongo',
    'underscore',
    'tracker',
    'ejson'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.2.5',
    'peerlibrary:check-extension@0.2.1',
    'peerlibrary:data-lookup@0.1.0',
    'peerlibrary:extend-publish@0.4.0'
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
  api.versionsFrom('METEOR@1.4.1');

  // Core dependencies.
  api.use([
    'coffeescript',
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
    'peerlibrary:reactive-publish@0.5.0',
    'peerlibrary:classy-test@0.2.26'
  ]);

  api.addFiles([
    'tests.coffee'
  ]);
});
