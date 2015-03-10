path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    app:
      name: 'linkedin-bot-viewer'
    port: 3000
    db: 'mongodb://localhost/linkedin-poke-development'

  test:
    root: rootPath
    app:
      name: 'linkedin-bot-viewer'
    port: 3000
    db: 'mongodb://localhost/linkedin-poke-test'

  production:
    root: rootPath
    app:
      name: 'linkedin-poke'
    port: process.env.PORT
    db: process.env.MONGO_URL

module.exports = config[env]
