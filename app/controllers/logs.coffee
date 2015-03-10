express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'
Log  = mongoose.model 'Log'

module.exports = (app) ->
  app.use '/', router

router.get '/logs', (req, res, next) ->
  Log.find().populate('poke').exec (err, logs) ->
    return next(err) if err
    res.render 'logs/index',
      title: 'Logs worker'
      logs: logs
