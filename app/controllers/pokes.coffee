express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'
User  = mongoose.model 'User'
Poke  = mongoose.model 'Poke'

module.exports = (app) ->
  app.use '/', router

router.get '/pokes', (req, res, next) ->
  Poke.find().populate('user').exec (err, pokes) ->
    return next(err) if err
    res.render 'pokes/index',
      title: 'Poke list'
      pokes: pokes

router.get '/users/:id/pokes/new', (req, res, next) ->
  User.findById req.params.id, (err, user) ->
    return next(err) if err
    res.render 'pokes/new',
      title: 'Add poke'
      user: user
      poke: new Poke()

router.get '/users/:user_id/pokes/:id', (req, res, next) ->
  Poke.findById(req.params.id).populate('user').exec (err, poke) ->
    return next(err) if err
    res.render 'pokes/edit',
      title: "Edit poke"
      poke: poke
      user: poke.user

router.post '/pokes/create', (req, res, next) ->
  User.findById req.body.user_id, (err, user) ->
    return next(err) if err
    new Poke(
      name: req.body.name,
      keywords: req.body.keywords,
      location_params: req.body.location_params,
      industry_params: req.body.industry_params,
      relationship_params: req.body.relationship_params,
      position_params: req.body.position_params,
      active: (req.body.active isnt undefined ? true : false),
      user: req.body.user_id).save (err, poke, count) ->
        return next(err) if err
        user.pokes.push poke._id
        user.save (err) ->
          return next(err) if err
      res.redirect "/users/#{user._id}"

router.put '/pokes/:id', (req, res, next) ->
  Poke.findById req.params.id, (err, poke) ->
    for prop of req.body
      `prop = prop`
      poke[prop] = req.body[prop]
    poke.active = req.body.active isnt undefined ? true : false
    poke.save (err) ->
      return next(err) if err
      res.redirect "/users/#{req.body.user_id}"

router.delete '/pokes/:id', (req, res, next) ->
  Poke.remove { _id: req.params.id }, (err, poke) ->
    return next(err) if err
    res.redirect 'back'
