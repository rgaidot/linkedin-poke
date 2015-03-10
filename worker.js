require('coffee-script/register');
var express = require('express')
  , config = require('./config/config')
  , glob = require('glob')
  , mongoose = require('mongoose')
  , poke_job = require('./app/jobs/poke');

mongoose.connect(config.db);
var db = mongoose.connection;
db.on('error', function () {
  throw new Error('unable to connect to database at ' + config.db);
});

var models = glob.sync(config.root + '/app/models/*.coffee');
models.forEach(function (model) {
  require(model);
});

var Poke = mongoose.model('Poke');
var Log = mongoose.model('Log');

Poke.find({ active: true }).populate('user').exec(function(err, pokes) {
  pokes.forEach(function(poke) {
    poke_job.run(poke, function(d){
      d.forEach(function(entry) {
        for (var value in entry){
          var log = new Log({
            linkedin_id: entry[value].uid,
            linkedin_name: entry[value].name,
            linkedin_url: entry[value].linkedin_url,
            visited_at: entry[value].visited_at,
            poke: poke._id,
          }).save();
        }
      });
    });
  });
});
