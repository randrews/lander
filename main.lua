assert(love, "Run this inside Love")

local quads = {}
local background = nil
local dialogFont = nil
local game = nil
local status_bar = nil
local rocket_img = nil
local particle = nil
local thrust = nil
local world = nil

local ground = nil
local edge = {}
local rocket = {}
local rotate_flag = true

function love.load()
   math.randomseed(os.time())
   rocket.image = love.graphics.newImage('rocket.png')
   background = love.graphics.newImage('background.jpg')
   particle = love.graphics.newImage('particle.png')

   thrust = love.graphics.newParticleSystem(particle, 1000)

   thrust:setColors(
      math.floor(0.94 * 255), math.floor(0.73*255), math.floor(0.18*255), 255, -- start
      math.floor(0.90*255), math.floor(0.49*255), math.floor(0.19*255), 0 -- end
   )

   thrust:setDirection(math.pi * 1.5)
   thrust:setEmissionRate(100)
   thrust:setGravity(0)
   thrust:setLifetime(-1)
   thrust:setParticleLife(0.5, 0.7)
   thrust:setRadialAcceleration(17)
   thrust:setSizes(4, 1)
   thrust:setSizeVariation(1)
   thrust:setSpeed(-150)
   thrust:setSpread(math.pi / 9)
   thrust:setTangentialAcceleration(-100, 100)

   thrust:start()
   -- game = create_game()

   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 10)

   rocket.body = love.physics.newBody(world, 400, 300, 'dynamic')
   rocket.shape = love.physics.newRectangleShape(64, 64)
   local rfix = love.physics.newFixture(rocket.body, rocket.shape)
   rfix:setUserData(rocket)

   edge.body = love.physics.newBody(world, 0, 0, 'static')
   edge.shapes = {}
   table.insert(edge.shapes, love.physics.newEdgeShape(0, 600, 800, 600))
   table.insert(edge.shapes, love.physics.newEdgeShape(0, 0, 800, 0))
   table.insert(edge.shapes, love.physics.newEdgeShape(0, 0, 0, 600))
   table.insert(edge.shapes, love.physics.newEdgeShape(800, 0, 800, 600))

   for _, s in ipairs(edge.shapes) do
      love.physics.newFixture(edge.body, s)
   end

   ground = create_ground(world, 0, 600, 800, 64)
   world:setCallbacks(beginContact, endContact)
end

function beginContact(fix1, fix2, contact)
   if fix1:getUserData() == rocket or fix2:getUserData() == rocket then
      rotate_flag = false
   end
end

function endContact(fix1, fix2, contact)
   if fix1:getUserData() == rocket or fix2:getUserData() == rocket then
      rotate_flag = true
   end
end


function create_ground(world, x1, y1, w, h)
   local body = love.physics.newBody(world, 0, 0, 'static')
   local shape = love.physics.newEdgeShape(x1, y1-h, x1+w, y1-h)
   love.physics.newFixture(body, shape)
   return {x = x1, y = y1-h, w = w, h = h}
end

function love.draw()
   local g = love.graphics

   g.setColor(255, 255, 255)
   g.draw(background, 0, 0)

   g.setColor(255, 255, 255)
   g.draw(thrust, 0, 0)

   g.setColor(96, 96, 96)
   g.rectangle('fill', ground.x, ground.y, ground.w, ground.h)

   g.setColor(255, 255, 255)
   g.draw(rocket.image,
          rocket.body:getX(), rocket.body:getY(), -- position
          rocket.body:getAngle(), -- rotation
          1, 1, -- scale
          32, 32) -- Offset to image center
end

function love.mousepressed(mouse_x, mouse_y)
end

function love.mousereleased()
end

function love.update(dt)
   local dx = love.mouse.getX() - rocket.body:getX()
   local dy = love.mouse.getY() - rocket.body:getY()

   local a = math.atan2(dy, dx)
   local ra = rocket.body:getAngle() - math.pi/2

   thrust:setPosition(rocket.body:getX() - math.cos(ra)*32, rocket.body:getY() - math.sin(ra)*32)
   thrust:setDirection(rocket.body:getAngle() - math.pi/2)

   if love.mouse.isDown('l') then
      thrust:setEmissionRate(100)
      local pwr = 25
      rocket.body:applyForce(math.cos(ra)*pwr, math.sin(ra)*pwr)
   else
      thrust:setEmissionRate(0)
   end

   if rotate_flag then
      rocket.body:setAngle(a + math.pi/2) -- / math.pi * 180
   end

   thrust:update(dt)
   world:update(dt)
end