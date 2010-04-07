class Camera < Detonator::Model
  self.connection = Mongo::Connection.new.db("detonator_test")

  key :model, String
  key :num, Integer
  key :cost, Float
  key :bought_at, Time
  key :last_used_on, Date

  timestamps
end

