local GUI = {}

local Util = require("Util")
local menu = require("AbsMenu")

local colors = Util.colors
local keys = Util.keys
local actions = Util.actions
local control_vars = Util.control_vars
local settings = Util.settings

GUI.main_color = settings.main_color

function GUI.random_color()
   local keyset = {}
   for k in pairs(colors) do
      table.insert(keyset, k)
   end
   return colors[keyset[love.math.random(#keyset)]]
end

function GUI.draw_HUD(x, y, score)
   local text_h = Util.hud_height*0.95
   local score_text = love.graphics.newText(love.graphics.newFont(text_h), "Score: "..score.." pts")
   love.graphics.setColor(settings.main_color)
   if control_vars.is_mute then
      local mute_text = love.graphics.newText(love.graphics.newFont(text_h), "MUTE")
      love.graphics.draw(mute_text, settings.resolution_w-mute_text:getWidth(), y)
   end
   love.graphics.draw(score_text, x, y)
end

function GUI.draw_field(x, y, w, h, field)
   for i=1, Util.field_w do
      for j=1, Util.field_h do
         if field[i][j] then
            --love.graphics.setColor(unpack(GUI.random_color()))
            love.graphics.rectangle("fill", (i*Util.sqr_size-Util.sqr_size)+x, (j*Util.sqr_size-Util.sqr_size)+y, Util.sqr_size, Util.sqr_size)
         end
      end
   end
end

function GUI.create_main_menu(x, y, w, h, reset_game)
   local main_menu = menu.new_menu(x, y, w, h)
   local colors_props = {
      label_color = {
         default = settings.main_color,
         focused = colors.BLACK,
      },
      fill_colors = {
         default = colors.BLACK,
         focused = settings.main_color,
         disabled = colors.BLACK,
      },
      outline_colors = {
         default = settings.main_color,
         focused = settings.main_color,
         disabled = colors.BLACK,
      },
   }
   local function singleplr_func()
      reset_game()
      Util.current_screen = Util.screens.on_singleplayer_game
   end
   local function goto_options()
      GUI.create_options_menu(GUI.w, GUI.h)
      Util.current_screen = Util.screens.on_options
   end
   local buttons = {
      {'b_singleplr', "Single Player", colors_props, singleplr_func},
      {'b_multip', "Multiplayer", colors_props},
      {'b_opts', "Options", colors_props, goto_options},
      {'b_ranks', "Rankings", colors_props},
      {'b_quit', "Quit", colors_props, function() love.window.close() end},
   }
   for _, item in ipairs(buttons) do
      main_menu:add_button(unpack(item))
   end
   GUI.main_menu = main_menu
   return GUI.main_menu
end

function GUI.create_pause_menu(w, h)
   local pause_menu = menu.new_menu(0, 0, w, h)
   pause_menu:add_label('title', "Pause", {font = love.graphics.newFont(100), color = settings.main_color, underline = true})
   local colors_props = {
      label_color = {
         default = settings.main_color,
         focused = colors.BLACK,
      },
      fill_colors = {
         default = colors.BLACK,
         focused = settings.main_color,
         disabled = colors.BLACK,
      },
      outline_colors = {
         default = settings.main_color,
         focused = settings.main_color,
         disabled = colors.BLACK,
      },
   }
   local buttons = {
      {'b_resume', "Resume", colors_props, function() Util.current_screen = Util.screens.on_singleplayer_game end},
      {'b_quit', "Quit", colors_props, function() Util.current_screen = Util.screens.on_death end},
   }
   for _, item in ipairs(buttons) do
      pause_menu:add_button(unpack(item))
   end
   pause_menu:set_focus(2)
   GUI.pause_menu = pause_menu
   return GUI.pause_menu
end

function GUI.create_death_menu(w, h, score)
   local death_menu = menu.new_menu(0, 0, w, h)
   local properties = {font = love.graphics.newFont(50), color = settings.main_color}
   death_menu:add_label('title', "Game Over", properties)
   death_menu:add_label('score', "Your score: "..score.." pts", {color = settings.main_color})
   GUI.death_menu = death_menu
   return GUI.death_menu
end

function GUI.create_options_menu(w, h)
   local options_menu = menu.new_menu(0, 0, w, h)
   local properties = {font = love.graphics.newFont(50), color = settings.main_color, underline = true}
   options_menu:add_label('title', "Options", properties)
   local colors_list = {"White", "Red", "Orange", "Yellow", "Lime", "Green",
      "Cyan", "Light Blue", "Dark Blue", "Purple", "Magenta", "Pink"}
   options_menu:add_selector('sl_color', "Color scheme:", colors_list)
   options_menu:add_checkbox('chk_fullscreen', "Fullscreen", {box_align = 'right', state = Util.settings.fullscreen})
   local res_list = {"800 x 600", "1024 x 768", "1366 x 768"}
   options_menu:add_selector('sl_resolution', "Resolution:", res_list)
   local colors_props = {
      label_color = {
         default = settings.main_color,
         focused = colors.BLACK,
      },
      fill_colors = {
         default = colors.BLACK,
         focused = settings.main_color,
         disabled = colors.BLACK,
      },
      outline_colors = {
         default = settings.main_color,
         focused = settings.main_color,
         disabled = colors.BLACK,
      },
   }
   local function go_back()
      -- TODO change settings values
      local data = options_menu:get_data()
      --for k,v in pairs(data) do print(k,v) end
      Util.settings.fullscreen = data.chk_fullscreen
      GUI.create_options_menu(GUI.w, GUI.h)
      Util.apply_settings()
      Util.current_screen = Util.screens.on_main
   end
   options_menu:add_button('b_back', "Back", colors_props, go_back)
   options_menu:set_focus(2)
   GUI.options_menu = options_menu
   return GUI.options_menu
end

function GUI.draw_main_menu()
   local action = GUI.main_menu:run()
   love.graphics.setColor(unpack(settings.main_color))
   local title = love.graphics.newText(love.graphics.newFont(100), "Snakey")
   local title_w = title:getWidth()
   local title_h = title:getHeight()
   local title_x = math.ceil(GUI.w/2)
   local title_y = math.ceil(GUI.w/6)
   local box_w = title_w+30
   local box_h = title_h+20
   local box_x = title_x - box_w/2
   local box_y = title_y - box_h/2
   love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
   love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
   love.graphics.setColor(unpack(colors.BLACK))
   love.graphics.rectangle("fill", box_x, box_y, box_w, box_h)
   love.graphics.setColor(unpack(settings.main_color))
   love.graphics.draw(title, title_x, title_y, nil, nil, nil, title_w/2, title_h/2)
   return action
end

function GUI.draw_pause_menu()
   local action = GUI.pause_menu:run()
   return action
end

function GUI.draw_death_menu(w, h)
   local action = GUI.death_menu:run(function() Util.current_screen = Util.screens.on_main end)
   return action
end

function GUI.draw_options_menu()
   local action = GUI.options_menu:run()
   return action
end

return GUI
