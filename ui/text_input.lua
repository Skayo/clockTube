local class = require('lib.class')
local fonts = require('assets.fonts._all')

local TextInput = class {
	inputTitleBar = nil,
	layout = 1,
	cursor = { x = 1, y = 1 },
	currInput = '',
	specs = {
		keyboardCols = 10,
		keyboardRows = 4,
		keyWidth = 29.75,
		keyHeight = 22,
		keyboardY = 119
	},
	layouts = {
		{
			name = 'abc',
			rows = {
				'1234567890',
				'qwertyuiop',
				"asdfghjkl'",
				'zxcvbnm,.?'
			}
		},
		{
			name = 'ABC',
			rows = {
				'1234567890',
				'QWERTYUIOP',
				'ASDFGHJKL"',
				'ZXCVBNM;:!'
			}
		},
		{
			name = '123',
			rows = {
				',;:\'"!?  %', -- ¡¿
				'[]{}`$  #', --- £«»
				'<>()   ~^\\', -- €¥
				'|=*/+-@_&.',
			}
		}
	},
	texts = {}
}

function TextInput:init(inputTitleBar)
	self.inputTitleBar = inputTitleBar

	for i, layout in pairs(self.layouts) do
		-- nice little snippet to be able to access a char with currLayout(x,y)
		setmetatable(self.layouts[i].rows, {
			__call = function(t, x, y)
				return t[y]:sub(x, x)
			end
		})

		-- Create keys object for current layout
		self.texts[i] = {}
		for y = 1, self.specs.keyboardRows do
			for x = 1, self.specs.keyboardCols do
				self.texts[i][x .. ',' .. y] = love.graphics.newText(fonts.SegoeUI_bold, self.layouts[i].rows(x, y))
			end
		end
	end
	self.texts['space'] = love.graphics.newText(fonts.SegoeUI_bold, 'Space')
	self.texts['input'] = love.graphics.newText(fonts.SegoeUI, '')
end

function TextInput:draw()
	local currOffsetX, currOffsetY = 1, self.specs.keyboardY

	-- Keys
	for y = 1, self.specs.keyboardRows do
		for x = 1, self.specs.keyboardCols do
			if self.cursor.x == x and self.cursor.y == y then
				love.graphics.setColor(51, 166, 255)
				love.graphics.rectangle('fill', x + currOffsetX, y + currOffsetY, self.specs.keyWidth, self.specs.keyHeight)
			end

			love.graphics.setColor(169, 169, 169)
			love.graphics.rectangle('line', x + currOffsetX, y + currOffsetY, self.specs.keyWidth, self.specs.keyHeight)

			love.graphics.setColor(0, 0, 0)
			love.graphics.draw(self.texts[self.layout][x .. ',' .. y], x + currOffsetX + 10, y + currOffsetY + 3)

			currOffsetX = currOffsetX + self.specs.keyWidth + 1
		end

		currOffsetY = currOffsetY + self.specs.keyHeight + 1
		currOffsetX = 1
	end

	-- Spacebar
	currOffsetX = (currOffsetX + self.specs.keyWidth + 1) * 2

	if self.cursor.y == 5 then
		love.graphics.setColor(51, 166, 255)
		love.graphics.rectangle('fill', 4 + currOffsetX, 5 + currOffsetY, (self.specs.keyWidth + 1) * 6, self.specs.keyHeight)
	end

	love.graphics.setColor(169, 169, 169)
	love.graphics.rectangle('line', 4 + currOffsetX, 5 + currOffsetY, (self.specs.keyWidth + 1) * 6, self.specs.keyHeight)

	love.graphics.setColor(0, 0, 0)
	love.graphics.draw(self.texts['space'], 4 + currOffsetX + 75, 5 + currOffsetY + 3)


	-- Input Text Field
	love.graphics.setColor(169, 169, 169)
	love.graphics.rectangle('line', 20, 30, 280, 80)

	-- Input Text
	love.graphics.setColor(0,0,0)
	love.graphics.draw(self.texts['input'], 25, 35)
end

function TextInput:keypressed(k)
	if k == 'up' then
		self.cursor.y = self.cursor.y - 1
	end

	if k == 'down' then
		self.cursor.y = self.cursor.y + 1
	end

	if k == 'left' then
		self.cursor.x = self.cursor.x - 1
	end

	if k == 'right' then
		self.cursor.x = self.cursor.x + 1
	end

	if k == 'j' then
		if self.cursor.y == 5 then
			self.currInput = self.currInput .. ' '
		else
			local currLayout = self.layouts[self.layout].rows
			self.currInput = self.currInput .. currLayout(self.cursor.x, self.cursor.y)
		end

		self.texts['input']:set(self.currInput)
	end

	if k == 'k' then
		self.currInput = self.currInput:sub(1, #self.currInput-1)
		self.texts['input']:set(self.currInput)
	end

	if k == 'u' then
		self.layout = self.layout + 1
		if self.layout > 3 then
			self.layout = 1
		end

		local nextLayout = self.layout + 1
		if nextLayout > 3 then
			nextLayout = 1
		end

		self.inputTitleBar:setActions({
			{
				key = 'A',
				label = 'Enter'
			},
			{
				key = 'B',
				label = 'Del'
			},
			{
				key = 'Y',
				label = 'Done'
			},
			{
				key = 'X',
				label = self.layouts[nextLayout].name
			},
			{
				key = 'nav',
				label = 'Move'
			}
		})
	end
end

return TextInput