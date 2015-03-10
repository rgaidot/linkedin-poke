express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'
User  = mongoose.model 'User'

module.exports = (app) ->
  app.use '/', router

router.get '/users', (req, res, next) ->
  User.find().populate('pokes').exec (err, users) ->
    return next(err) if err
    res.render 'users/index',
      title: 'User list'
      users: users

router.get '/users/new', (req, res, next) ->
  res.render 'users/new',
    title: 'Add user'
    user: new User()

router.get '/users/:id', (req, res, next) ->
  User.findById(req.params.id).populate('pokes').exec (err, user) ->
    return next(err) if err
    res.render 'users/edit',
      title: "Edit user"
      user: user

router.post '/users/create', (req, res, next) ->
  new User(
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
    url_linkedin: req.body.url_linkedin).save (err, user, count) ->
    return next(err) if err
    res.redirect '/users'

router.put '/users/:id', (req, res, next) ->
  User.findById req.params.id, (err, user) ->
    for prop of req.body
      `prop = prop`
      user[prop] = req.body[prop]
    user.save (err) ->
      return next(err) if err
      res.redirect '/users'

router.delete '/users/:id', (req, res, next) ->
  User.remove { _id: req.params.id }, (err, user) ->
    return next(err) if err
    res.redirect '/users'
