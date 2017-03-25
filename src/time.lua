local Time = {}

function Time:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.minutes = o.minutes or 700
  o.day = o.day or 27
  o.month = o.month or 6

  return o
end

function Time:advance(amount)
  self.minutes = self.minutes + amount

  if self.minutes > 1440 then
    self.minutes = 1
    self.day = self.day + 1
  end

  if self.day > 30 then
    self.day = 1
    self.month = self.month + 1
  end

  if self.month > 12 then
    self.month = 1
  end
end

function Time:timestamp()
  return self.minutes + (self.day * 1440) + (self.month * 44640)
end

function Time:date()
  local months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}
  return ("%d, %s"):format(self.day, months[self.month])
end

function Time:time()
  return ("%d:%d"):format((self.minutes / 60), self.minutes % 60)
end

return Time
