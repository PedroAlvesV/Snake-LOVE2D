local GUI = require 'GUI'

local Snake = require 'Snake'
local Fruit = require 'Fruit'

local w, h = 800, 600
local debug, mute, pause, inic, death = false, false, false, false, false
local snake, fruit, field, sfx = {}, {}, {}
local initial_size = 4
local v = 0.05

sfx = {
   ponto = love.audio.newSource("/sfx/ponto.ogg", "static"),
   toque = love.audio.newSource("/sfx/toque.ogg", "static"),
   inicio = love.audio.newSource("/sfx/inicio.ogg", "static"),
}

love.window.setTitle("Snakey")

local function start(first_time)

   -- sets field
   for i=1, w/10 do
      field[i] = {}
      for j=1, h/10 do
         field[i][j] = i == 1 or j == 1 or i == w/10 or j == h/10
      end
   end

   -- sets snake and fruit
   snake = Snake.new(w/20, h/20)
   fruit = Fruit.new(love.math.random(2, (w/10)-1), love.math.random(2, (h/10)-1))
   for i=2, initial_size do
      snake:add_segment()
   end
   for _, segment in ipairs(snake:get_segments()) do
      field[segment.x][segment.y] = true
   end

   -- plays start tune
   if not mute and not first_time then
      sfx.inicio:play()
   end
end

local function move_snake(v)
   local function follow_segment(index, direction)
      if index <= #snake:get_segments() then
         local segment = snake:get_segments()[index]
         if segment.direction == 'up' then
            snake:set_Y(index, snake:get_Y(index)-1)
         elseif segment.direction == 'down' then
            snake:set_Y(index, snake:get_Y(index)+1)
         elseif segment.direction == 'left' then
            snake:set_X(index, snake:get_X(index)-1)
         elseif segment.direction == 'right' then
            snake:set_X(index, snake:get_X(index)+1)
         end
         field[segment.x][segment.y] = true
         follow_segment(index+1, snake:get_direction(index))
         if index > 1 then
            snake:set_direction(index, direction)
         end
      end
   end
   follow_segment(1, snake:get_direction(1))
   love.timer.sleep(v)
end

local function apply_effect(fruit)
   local effect = fruit:get_effect()
   if effect == 1 then
      return -- normal fruit, has no special effect
   elseif effect == 2 then
      -- adds several fake fruits
   elseif effect == 3 then
      -- hurts/cuts snake
   elseif effect == 4 then
      -- mirrors controls
   elseif effect == 5 then
      -- turns field
   elseif effect == 6 then
      -- adds fake/mimic snake
   elseif effect == 7 then
      -- speeds snake up
   elseif effect == 8 then
      -- makes snake walk backwards
   elseif effect == 9 then
      -- empty
   elseif effect == 10 then
      -- empty
   end
end

local function reset_fruit()
   fruit:set_X(love.math.random(2, (w/10)-1))
   fruit:set_Y(love.math.random(2, (h/10)-1))
end

local function die()
   death = true
   inic = false
   if not mute then
      sfx.toque:play()
   end
end

function love.load()
   start(true)
end

function love.keypressed(key)
   if key == ('m') then
      mute = not mute
   end
   if key == ('kp-') then
      v = v + 0.05
   end
   if key == ('kp+') then
      if v > 0 then
         v = v - 0.05
      end
   end
   if key == ('space') then
      if inic then
         pause = not pause
      else
         if death then
            death = not death
         end
         inic = not death
         start(false)
      end
   end
   if key == ('\'') then
      debug = not debug
   end
   if key == ('up') or key == ('down') or key == ('left') or key == ('right') or key == ('w') or key == ('s') or key == ('a') or key == ('d') then
      if key == ('w') then
         key = 'up'
      end
      if key == ('s') then
         key = 'down'
      end
      if key == ('a') then
         key = 'left'
      end
      if key == ('d') then
         key = 'right'
      end
      snake:set_direction(1, key)
   end
   if key == ('escape') then
      if inic then
         inic = false
         pause = false
         death = false
      else
         love.window.close()
      end
   end
end

function love.update(dt)
   if inic then
      if not pause and not death then
         for i=1, w/10 do
            for j=1, h/10 do
               field[i][j] = i == 1 or j == 1 or i == w/10 or j == h/10
            end
         end
         field[fruit:get_X()][fruit:get_Y()] = true
         if snake:get_X(1) > 1 and snake:get_Y(1) > 1 and snake:get_X(1) < w/10 and snake:get_Y(1) < h/10 then
            for i, segment in ipairs(snake:get_segments()) do
               if i ~= 1 then
                  if segment.x == snake:get_X(1) and segment.y == snake:get_Y(1) then
                     die()
                  end
               end
            end
            move_snake(v)
         else
            die()
         end
         if snake:get_X(1) == fruit:get_X() and snake:get_Y(1) == fruit:get_Y() then
            snake:add_segment()
            apply_effect(fruit)
            reset_fruit()
            if not mute then
               sfx.ponto:play()
            end
         end
      end
   end
end

function love.draw()
   if not inic and not death then
      GUI.logo_screen(w, h)
   else
      if not death then 
         GUI.draw_field(w, h, field)
         if pause then
            GUI.pause_screen(w, h)
         end
         if mute then
            love.graphics.setFont(love.graphics.newFont(40))
            love.graphics.print("MUTE", w-117, 0)
         end
      else
         GUI.death_screen(w, h, #snake:get_segments()-initial_size)
      end
   end
end
