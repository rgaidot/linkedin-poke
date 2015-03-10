mongoose = require 'mongoose'
Schema   = mongoose.Schema

LogSchema = new Schema(
  visited_at: type: Date
  linkedin_name: String
  linkedin_id: String
  linkedin_url: String
  poke: {
    type: mongoose.Schema.Types.ObjectId
    ref: 'Poke'
    index: true
  }
)

LogSchema.virtual('date')
  .get (-> this._id.getTimestamp())

mongoose.model 'Log', LogSchema
