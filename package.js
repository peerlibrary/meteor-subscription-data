Package.describe({
  name: 'peerlibrary:subscription-data',
  summary: "Reactive and shared subscription data context",
  version: '0.8.0',
  git: 'https://github.com/peerlibrary/meteor-subscription-data.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.8.1');

  // Core dependencies.
  api.use([
    'coffeescript@2.4.1',
    'ecmascript',
    'mongo',
    'underscore',
    'tracker',
    'ejson'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.3.0',
    'peerlibrary:check-extension@0.7.0',
    'peerlibrary:data-lookup@0.3.0',
    'peerlibrary:extend-publish@0.6.0'
  ]);

  api.addFiles([
    'server.coffee'
  ], 'server');

  api.addFiles([
    'client.coffee'
  ], 'client');
});

Package.onTest(function (api) {
  api.versionsFrom('METEOR@1.8.1');

  // Core dependencies.
  api.use([
    'coffeescript@2.4.1',
    'ecmascript',
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
    'peerlibrary:reactive-publish@0.9.0',
    'peerlibrary:classy-test@0.4.0'
  ]);

  api.addFiles([
    'tests.coffee'
  ]);
});
