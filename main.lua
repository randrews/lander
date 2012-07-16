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

local edge = {}
local rocket = {}

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
   love.physics.newFixture(rocket.body, rocket.shape)

   edge.body = love.physics.newBody(world, 0, 0, 'static')
   edge.shapes = {}
   table.insert(edge.shapes, love.physics.newEdgeShape(0, 600, 800, 600))
   table.insert(edge.shapes, love.physics.newEdgeShape(0, 0, 800, 0))
   table.insert(edge.shapes, love.physics.newEdgeShape(0, 0, 0, 600))
   table.insert(edge.shapes, love.physics.newEdgeShape(800, 0, 800, 600))

   for _, s in ipairs(edge.shapes) do
      love.physics.newFixture(edge.body, s)
   end
end

function love.draw()
   local g = love.graphics
   g.draw(background, 0, 0)

   g.draw(thrust, 0, 0)
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
   rocket.body:setAngle(a + math.pi/2) -- / math.pi * 180

   thrust:setPosition(rocket.body:getX() - math.cos(a)*32, rocket.body:getY() - math.sin(a)*32)
   thrust:setDirection(a)

   if love.mouse.isDown('l') then
      thrust:setEmissionRate(100)
      local pwr = 25
      rocket.body:applyForce(math.cos(a)*pwr, math.sin(a)*pwr)
   else
      thrust:setEmissionRate(0)
   end

   thrust:update(dt)
   world:update(dt)
end