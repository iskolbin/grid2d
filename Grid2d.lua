local Grid2d = {}

local Grid2dMt

local function defaultFill( f )
	f = f == nil and '' or f
	return function(self, x, y, v )
		return f
	end
end

local function defaultEncoder( self, x, y, v )
	return v
end

local function defaultDecoder( self, x, y, v )
	return v
end

function Grid2d.new( width, height )
	local self = {}	
	for x = 1, width do
		self[x] = {}
		for y = 1, height do
			self[x][y] = ''
		end
	end
	return setmetatable( self, Grid2dMt )
end

function Grid2d:fill( fill )
	fill = fill or defaultFill
	local width, height = self:getWidth(), self:getHeight()
	for x = 1, width do
		self[x] = {}
		for y = 1, height do
			self[x][y] = fill( self, x, y, self[x][y] )
		end
	end
	return self
end

function Grid2d:fillRect( x, y, w, h, fill )
	fill = fill or defaultFill
	
	for x_ = x, x + w-1 do
		local col = self[x]
		for y_ = y, y+h-1 do
			self[x_][y_] = fill( self, x_, y_, self[x][y] )
		end
	end
	return self
end

function Grid2d:slice( x, y, w, h )
	x, y = math.max( 1, math.min( x, self:getWidth())), math.max( 1, math.min( y, self:getHeight()))
	w, h = math.min( self:getWidth() - x + 1, w ), math.min( self:getHeight() - y + 1, h )
	local out = Grid2d.new( w, h )
	for x_ = 1, w do
		for y_ = 1, h do
			out[x_][y_] = self[x_ + x][y_ + y]
		end
	end
	return out
end

function Grid2d:getWidth()
	return #self
end

function Grid2d:getHeight()
	return #self[1]
end

function Grid2d:map( f )
	local out = Grid2d.new( self:getWidth(), self:getHeight())
	for x = 1, self:getWidth() do
		for y = 1, self:getHeight() do
			out[x][y] = f( self, x, y, self[x][y] )
		end
	end
	return out
end

function Grid2d:clone()
	local w, h = self:getWidth(), self:getHeight()
	local out = Grid2d.new( w, h )
		
	for x = 1, w do
		for y = 1, h do
			out[x][y] = grid[x][y]
		end
	end
		
	return out
end


function Grid2d:encode( encoder )
	encoder = encoder or defaultEncoder

	local t, k = {}, 0
	local w, h = self:getWidth(), self:getHeight()
	for y = h, 1, -1 do
		for x = 1, w do
			k = k + 1
			t[k] = encoder( self, x, y, self[x][y] )
		end
		k = k + 1
		t[k] = '\n'
	end
	return table.concat( t )
end
	

function Grid2d.decode( str, decoder )
	decoder = decoder or defaultDecoder
	
	local ts = {}
	local k = 0
	
	for s in str:gmatch("[^\r\n]+") do
		k = k + 1
		ts[k] = s
	end
		
	local w, h = #ts[1], #ts
	local self = Grid2d.new( w, h )
		
	for x = 1, w do
		for y = 1, h do
			self[x][y] = decoder( self, x, y, ts[h-y+1]:sub( x, x ) )
		end
	end
		
	return self
end

Grid2dMt = {
	__index = Grid2d,
	__tostring = Grid2d.encode,
}

return Grid2d
