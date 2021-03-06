-- LOADING SCREEN --
love.graphics.clear(255,255,255)
local w, h = love.window.getMode()
local clockTubeLogo = love.graphics.newImage("assets/images/clockTube-Logo.png")
love.graphics.draw(clockTubeLogo, w / 2 - clockTubeLogo:getWidth() / 2, h / 2 - clockTubeLogo:getHeight() / 2)
love.graphics.present()
--

-- this fixes compatibility for LÖVE 0.10.2 colors (0-255 instead of 0-1)
require('lib.compat')
--

local screenManager

function connected()
	local requestHandler = io.popen('curl --silent "http://example.com"', 'r')
	local response = requestHandler:read('*all')
	
	return (#response > 0)
end

function love.load()
	local screens = {}
	local initialScreen = ''

	if not connected() then
		screens = {
			offline = require('screens.offline')()
		}
		initialScreen = 'offline'
	else
		screens = require('screens._all')
		initialScreen = 'home'
	end

	screenManager = require('lib.ScreenManager')(screens, initialScreen)
	
	-- Additional config
	love.keyboard.setKeyRepeat(true) -- Repeat love.keypressed when long pressing
end

function love.draw()
	screenManager:draw()
end

function love.update(dt)
	screenManager:update(dt)
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	else
		screenManager:keypressed(k)
	end
end 