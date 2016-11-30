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

function Grid2d.new( width_or_grid, height )
	local self = {}	
	if type( width_or_grid ) == 'table' then
		local w, h = #width_or_grid, #width_or_grid[1]
		for x = 1, w do
			self[x] = {}
			for y = 1, h do
				self[x][y] = width_or_grid[x][y]
			end
		end
	else
		for x = 1, width_or_grid do
			self[x] = {}
			for y = 1, height do
				self[x][y] = ''
			end
		end
	end
	return setmetatable( self, Grid2dMt )
end

function Grid2d:isInside( x, y, w, h )
	return x >= 1 and y >= 1 and x+(w or 1)-1 <= self:getWidth() and y+(h or 1)-1 <= self:getHeight()
end

function Grid2d:fill( fill, x, y, w, h )
	x, y = math.max( 1, math.min( x or 1, self:getWidth())), math.max( 1, math.min( y or 1, self:getHeight()))
	w, h = math.min( self:getWidth() - x + 1, w or self:getWidth() ), math.min( self:getHeight() - y + 1, h or self:getHeight())
	for x_ = x, x + w-1 do
		local col = self[x]
		for y_ = y, y+h-1 do
			self[x_][y_] = fill( self, x_, y_, self[x][y] )
		end
	end
	return self
end

function Grid2d:blit( src, destx, desty, srcx, srcy, srcw, srch )
	destx, desty = destx or 1, desty or 1
	srcx, srcy = srcx or 1, srcy or 1
	local w, h = Grid2d.getWidth( src ), Grid2d.getHeight( src )
	srcw = math.max( 0, math.min( self:getWidth() - destx + 1, w - srcx + 1, srcw or w ))
	srch = math.max( 0, math.min( self:getHeight() - desty + 1, h - srcy + 1, srch or h ))
	for x = 0, srcw-1 do
		for y = 0, srch-1 do
			self[x+destx][y+desty] = src[x+srcx][y+srcy]
		end
	end
	return self
end

function Grid2d:sub( x, y, w, h )
	local width, height = self:getWidth(), self:getHeight()
	x, y = math.max( 1, math.min( x, width )), math.max( 1, math.min( y, height ))
	w, h = math.min( width - x + 1, w or width ), math.min( height - y + 1, h or height )
	local result = Grid2d.new( w, h )
	for x_ = 1, w do
		for y_ = 1, h do
			result[x_][y_] = self[x_ + x-1][y_ + y-1]
		end
	end
	return result
end

function Grid2d:getWidth()
	return #self
end

function Grid2d:getHeight()
	return #self[1]
end

function Grid2d:flipHorizontal()
	local w, h = self:getWidth(), self:getHeight()
	local result = Grid2d.new( w, h )
	for x = 1, w do
		for y = 1, h do
			result[x][y] = self[w-x+1][y]
		end
	end
	return result
end

function Grid2d:flipVertical()
	local w, h = self:getWidth(), self:getHeight()
	local result = Grid2d.new( w, h )
	for x = 1, w do
		for y = 1, h do
			result[x][y] = self[x][h-y+1]
		end
	end
	return result
end

function Grid2d:transpose()
	local w, h = self:getWidth(), self:getHeight()
	local result = Grid2d.new( h, w )
	for x = 1, w do
		for y = 1, h do
			result[y][x] = self[x][y]
		end
	end
	return result
end

function Grid2d:rotateClockwise()
	local w, h = self:getWidth(), self:getHeight()
	local result = Grid2d.new( h, w )
	for x = 1, w do
		for y = 1, h do
			result[y][w-x+1] = self[x][y]
		end
	end
	return result
end

function Grid2d:rotateCounterClockwise()
	local w, h = self:getWidth(), self:getHeight()
	local result = Grid2d.new( h, w )
	for x = 1, w do
		for y = 1, h do
			result[h-y+1][x] = self[x][y]
		end
	end
	return result
end

function Grid2d:rotateHalfCircle()
	return self:flipVertical():flipHorizontal()
end

function Grid2d:encode( encoder )
	encoder = encoder or defaultEncoder
	if type( encoder ) == 'table' and (getmetatable( encoder ) == nil or getmetatable( encoder ).__call == nil) then
		local e = encoder
		encoder = function( self, x, y, v ) return e[v] end
	end

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
	if type( decoder ) == 'table' and (getmetatable( decoder ) == nil or getmetatable( decoder ).__call == nil) then
		local e = decoder
		decoder = function( self, x, y, v ) return e[v] end
	end
	
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
