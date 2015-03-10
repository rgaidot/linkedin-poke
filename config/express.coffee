express = require 'express'
glob = require 'glob'

favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
compress = require 'compression'
connect = require 'connect'
methodOverride = require 'method-override'

module.exports = (app, config) ->
  app.set 'views', config.root + '/app/views'
  app.set 'view engine', 'jade'

  env = process.env.NODE_ENV || 'development'
  app.locals.ENV = env;
  app.locals.ENV_DEVELOPMENT = env == 'development'
  app.use logger 'dev'
  app.use bodyParser.json()
  app.use bodyParser.urlencoded(
    extended: true
  )

  app.use cookieParser()
  app.use compress()
  app.use express.static config.root + '/public'
  app.use methodOverride((req, res) ->
    if req.body and typeof req.body == 'object' and req.body.hasOwnProperty '_method'
      method = req.body._method
      delete req.body._method
      return method
    return
  )

  controllers = glob.sync config.root + '/app/controllers/**/*.coffee'
  controllers.forEach (controller) ->
    require(controller)(app);

  app.use (req, res, next) ->
    err = new Error 'Not Found'
    err.status = 404
    next err

  # development error handler
  # will print stacktrace
  if app.get('env') == 'development'
    app.use (err, req, res, next) ->
      res.status err.status || 500
      res.render 'error',
        message: err.message
        error: err
        title: 'error'

  # production error handler
  # no stacktraces leaked to user
  app.use (err, req, res, next) ->
    res.status err.status || 500
    res.render 'error',
      message: err.message
      error: {}
      title: 'error'
