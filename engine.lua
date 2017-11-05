local engine = {}

local Util = require("Util")
local GUI = require("GUI")

local Snake = require ("Snake")
local Fruit = require ("Fruit")

local field = {}
local snake, fruit
local sfx = Util.sfx
local keys = Util.keys
local actions = Util.actions

local function handle_playing(key)
   if Util.current_screen == Util.screens.on_singleplayer_game then
      if key == keys.DOWN or key == keys.S or
      key == keys.UP or key == keys.W or
      key == keys.LEFT or key == keys.A or
      key == keys.RIGHT or key == keys.D then
         snake:set_direction(1, key)
      elseif key == keys.M then
         Util.control_vars.is_mute = not Util.control_vars.is_mute
      elseif key == keys.KP_MINUS then
         Util.velocity = Util.velocity + 0.05
      elseif key == keys.KP_PLUS then
         if Util.velocity > 0 then
            Util.velocity = Util.velocity - 0.05
         end
      elseif key == keys.SPACE or key == keys.ESC then
         Util.current_screen = Util.screens.on_pause
      end
   elseif Util.current_screen == Util.screens.on_multiplayer_game then
      -- TODO
   end
end

local function handle_exception(key)
   function love.keypressed(key)
      if key == keys.SPACE or key == keys.ESC or key == keys.ENTER then
         Util.current_screen = Util.screens.on_main
      end
   end
end

local function valid_fruit(snake, fruit)
   for i=1, #snake:get_segments() do
      local reset = false
      while snake:get_X(i) == fruit:get_X() and snake:get_Y(i) == fruit:get_Y() do
         reset = true
         fruit:set_X(love.math.random(2, (Util.field_w)-1))
         fruit:set_Y(love.math.random(2, (Util.field_h)-1))
      end
      if reset then
         i = 1
      end
   end
   return fruit
end

local function reset_game(gamemode)

   GUI.create_pause_menu(0, 200, Util.w, Util.h-200)

   -- sets field
   for i=1, Util.field_w do
      field[i] = {}
      for j=1, Util.field_h do
         field[i][j] = i == 1 or j == 1 or i == Util.field_w or j == Util.field_h
      end
   end

   -- sets snake and fruit
   snake = Snake.new(math.ceil(Util.field_w/2), math.ceil(Util.field_h/2))
   fruit = Fruit.new(love.math.random(2, (Util.field_w)-1), love.math.random(2, (Util.field_h)-1))
   fruit = valid_fruit(snake, fruit)

   for i=1, Util.initial_size-1 do
      snake:add_segment()
   end
   for _, segment in ipairs(snake:get_segments()) do
      field[segment.x][segment.y] = true
   end

   -- plays start tune
   if not Util.control_vars.is_mute then
      sfx.inicio:play()
   end
end

local function move_snake()
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
   love.timer.sleep(Util.velocity)
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

local function reset_fruit(fruit)
   fruit:set_X(love.math.random(2, (Util.field_w)-1))
   fruit:set_Y(love.math.random(2, (Util.field_h)-1))
   return fruit
end

local function die()
   Util.current_screen = Util.screens.on_death
   if not Util.control_vars.is_mute then
      sfx.toque:play()
   end
end

local function game_mechanics()
   if Util.current_screen == Util.screens.on_singleplayer_game then
      for i=1, Util.field_w do
         for j=1, Util.field_h do
            field[i][j] = i == 1 or j == 1 or i == Util.field_w or j == Util.field_h
         end
      end
      field[fruit:get_X()][fruit:get_Y()] = true
      if snake:get_X(1) > 1 and snake:get_Y(1) > 1 and snake:get_X(1) < Util.field_w and snake:get_Y(1) < Util.field_h then
         for i, segment in ipairs(snake:get_segments()) do
            if i ~= 1 then
               if segment.x == snake:get_X(1) and segment.y == snake:get_Y(1) then
                  die()
               end
            end
         end
         move_snake()
      else
         die()
      end
      if snake:get_X(1) == fruit:get_X() and snake:get_Y(1) == fruit:get_Y() then
         snake:add_segment()
         apply_effect(fruit)
         fruit = valid_fruit(snake, reset_fruit(fruit))
         if not Util.control_vars.is_mute then
            sfx.ponto:play()
         end
      end
   elseif Util.current_screen == Util.screens.on_multiplayer_game then
      -- TODO
   end
end

local function run(snake, field)
   local score = (#snake:get_segments()-Util.initial_size)*100
   if Util.current_screen == Util.screens.on_main then
      return GUI.draw_main_menu()
   elseif Util.current_screen == Util.screens.on_pause then
      return GUI.draw_pause_menu()
   elseif Util.current_screen == Util.screens.on_death then
      GUI.create_death_menu(GUI.w, GUI.h, score)
      return GUI.draw_death_menu(GUI.w, GUI.h)
   elseif Util.current_screen == Util.screens.on_singleplayer_game then
      GUI.draw_HUD(0, 0, score)
      GUI.draw_field(0, Util.hud_height, GUI.w, GUI.h-Util.hud_height, field, Util.sqr_size)
      game_mechanics()
      return actions.PASSTHROUGH
   elseif Util.current_screen == Util.screens.on_multiplayer_setup then
      -- TODO
   elseif Util.current_screen == Util.screens.on_multiplayer_game then
      -- TODO
   elseif Util.current_screen == Util.screens.on_options then
      -- TODO
   elseif Util.current_screen == Util.screens.on_rankings then
      -- TODO
   end
end

function engine.start()
   GUI.create_main_menu(0, 200, Util.w, Util.h-200, reset_game)
   GUI.w, GUI.h = Util.w, Util.h
   reset_game()
end

function love.draw()
   local action, key = run(snake, field)
   if Util.current_screen == Util.screens.on_singleplayer_game then
      function love.keypressed(key)
         if key then
            handle_playing(key)
         end
      end
   elseif Util.current_screen == Util.screens.on_multiplayer_game then
      -- TODO
   elseif not action and Util.current_screen == Util.screens.on_death then
      handle_exception()
   end
end

return engine