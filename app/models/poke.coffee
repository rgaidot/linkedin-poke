mongoose = require 'mongoose'
Schema   = mongoose.Schema

PokeSchema = new Schema(
  name: String
  keywords: String
  location_params: String
  industry_params: String
  relationship_params: String
  position_params: String
  active: Boolean
  user: {
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
    index: true
  }
)

PokeSchema.virtual('date')
  .get (-> this._id.getTimestamp())

mongoose.model 'Poke', PokeSchema
