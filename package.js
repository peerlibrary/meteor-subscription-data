Package.describe({
  name: 'peerlibrary:subscription-data',
  summary: "Reactive and shared subscription data context",
  version: '0.7.1',
  git: 'https://github.com/peerlibrary/meteor-subscription-data.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.4.4.5');

  // Core dependencies.
  api.use([
    'coffeescript@2.0.3_3',
    'ecmascript',
    'mongo',
    'underscore',
    'tracker',
    'ejson'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:assert@0.2.5',
    'peerlibrary:check-extension@0.4.0',
    'peerlibrary:data-lookup@0.2.1',
    'peerlibrary:extend-publish@0.5.0'
  ]);

  api.addFiles([
    'server.coffee'
  ], 'server');

  api.addFiles([
    'client.coffee'
  ], 'client');
});

Package.onTest(function (api) {
  api.versionsFrom('METEOR@1.4.4.5');

  // Core dependencies.
  api.use([
    'coffeescript@2.0.3_3',
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
    'peerlibrary:reactive-publish@0.6.0',
    'peerlibrary:classy-test@0.3.0'
  ]);

  api.addFiles([
    'tests.coffee'
  ]);
});
