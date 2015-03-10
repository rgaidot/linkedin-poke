mongoose = require 'mongoose'
Schema   = mongoose.Schema

UserSchema = new Schema(
  name: String
  email: String
  password: String
  url_linkedin: String
  pokes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Poke'
    index: true
  }]
)

UserSchema.virtual('date')
  .get (-> this._id.getTimestamp())

mongoose.model 'User', UserSchema
