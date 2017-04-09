local lu = require('luaunit')
local StreetView = require('street_view')


function testCenter()
  local sv = StreetView:new({w=100, h=75})

  lu.assertEquals(0, sv.x)
  lu.assertEquals(0, sv.y)

  sv:center({x=0, y=0})
  lu.assertEquals(0, sv.x)
  lu.assertEquals(0, sv.y)

  sv:center({x=25, y=0})
  lu.assertEquals(0, sv.x)
  lu.assertEquals(0, sv.y)

  sv:center({x=50, y=0})
  lu.assertEquals(0, sv.x)
  lu.assertEquals(0, sv.y)

  sv:center({x=51, y=0})
  lu.assertEquals(1, sv.x)
  lu.assertEquals(0, sv.y)
end

function testToScreen()
  local sv = StreetView:new({w=100, h=75, screenx=10, screeny=10})

  lu.assertEquals(sv:toScreen({x=0,y=0}), {x=10, y=10})

  sv:center({x=50, y=0})
  lu.assertEquals(sv:toScreen({x=0,y=0}), {x=10, y=10})

  sv:center({x=51, y=0})
  lu.assertEquals(sv:toScreen({x=0,y=0}), {x=9, y=10})

  sv:center({x=100, y=0})
  lu.assertEquals(sv:toScreen({x=50,y=0}), {x=10, y=10})
end

function testToWorld()
  local sv = StreetView:new({w=100, h=75, screenx=10, screeny=10})

  lu.assertEquals(sv:toWorld({x=0,y=0}), {x=-10, y=-10})
  lu.assertEquals(sv:toWorld({x=10,y=10}), {x=0, y=0})
  lu.assertEquals(sv:toWorld({x=110,y=85}), {x=100, y=75})
end

os.exit(lu.LuaUnit.run())
