assert(love, "Run this inside Love")

local quads = {}
local background = nil
local dialogFont = nil
local game = nil
local status_bar = nil
local rocket = nil
local particle = nil
local thrust = nil

local rocket_pos = {
   x = 400,
   y = 300,
   a = 0
}

function love.load()
   math.randomseed(os.time())
   rocket = love.graphics.newImage('rocket.png')
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
   --thrust:setSpread(math.pi / 9)
   thrust:setTangentialAcceleration(-100, 100)

   thrust:start()
   -- game = create_game()
end

function love.draw()
   local g = love.graphics
   g.draw(background, 0, 0)

   g.draw(thrust, 0, 0)
   g.draw(rocket,
          rocket_pos.x, rocket_pos.y, -- position
          rocket_pos.a, -- rotation
          1, 1, -- scale
          32, 32) -- Offset to image center
end

function love.mousepressed(mouse_x, mouse_y)
end

function love.mousereleased()
end

function love.update(dt)
   if love.mouse.isDown('l') then
      thrust:setEmissionRate(100)
   else
      thrust:setEmissionRate(0)
   end

   local dx = love.mouse.getX() - rocket_pos.x
   local dy = love.mouse.getY() - rocket_pos.y

   local a = math.atan2(dy, dx)
   rocket_pos.a = a + math.pi/2 -- / math.pi * 180

   thrust:setPosition(rocket_pos.x, rocket_pos.y)
   thrust:setDirection(a)
   thrust:update(dt)
end