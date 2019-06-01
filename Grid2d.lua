local Grid2d = {}

Grid2d.__index = Grid2d

local function defaultEncoder( self, x, y, v )
	return v
end

local function defaultDecoder( self, x, y, v )
	return v
end

local function getWidth( self )
	return #self
end

local function getHeight( self )
	return #self[1]
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
	return setmetatable( self, Grid2d )
end

function Grid2d:fill( fill, x, y, w, h )
	if x and x < 0 then x = width + x + 1 end
	if y and y < 0 then y = height + y + 1 end
	if w and w < 0 then w = width + w + 1 end
	if h and h < 0 then h = height + h + 1 end
	x, y = math.max( 1, math.min( x or 1, getWidth( self ))), math.max( 1, math.min( y or 1, getHeight( self )))
	w, h = math.min( getWidth( self ) - x + 1, w or getWidth( self ) ), math.min( getHeight( self ) - y + 1, h or getHeight( self ))
	local mt = getmetatable( fill )
	if type( fill ) ~= 'function' or type( fill ) == 'table' and  (mt == nil or mt.__call == nil) then
		local newv = fill
		fill = function( self, x, y, v ) return newv end
	end
	for x_ = x, x + w-1 do
		local col = self[x]
		for y_ = y, y+h-1 do
			local v = fill( self, x_, y_, self[x][y] )
			if v ~= nil then
				self[x_][y_] = v
			end
		end
	end
	return self
end

function Grid2d:blit( src, destx, desty, srcx, srcy, srcw, srch )
	destx, desty = destx or 1, desty or 1
	srcx, srcy = srcx or 1, srcy or 1
	local w, h = getWidth( src ), getHeight( src )
	if destx and destx < 0 then destx = getWidth( self ) + destx + 1 end
	if desty and desty < 0 then desty = getHeight( self )  + desty + 1 end
	if srcx and srcx < 0 then srcx = x + srcx + 1 end
	if srcy and srcy < 0 then srcy = y + srcy + 1 end
	if srcw and srcw < 0 then srcw = w + srcw + 1 end
	if srch and srch < 0 then srch = h + srch + 1 end
	srcw = math.max( 0, math.min( getWidth( self ) - destx + 1, w - srcx + 1, srcw or w ))
	srch = math.max( 0, math.min( getHeight( self ) - desty + 1, h - srcy + 1, srch or h ))
	for x = 0, srcw-1 do
		for y = 0, srch-1 do
			self[x+destx][y+desty] = src[x+srcx][y+srcy]
		end
	end
	return self
end

function Grid2d:sub( x, y, w, h )
	local width, height = getWidth( self ), getHeight( self )
	if x and x < 0 then x = width + x + 1 end
	if y and y < 0 then y = height + y + 1 end
	if w and w < 0 then w = width + w + 1 end
	if h and h < 0 then h = height + h + 1 end
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
	return getWidth( self )
end

function Grid2d:getHeight()
	return getHeight( self )
end

function Grid2d:flipHorizontal()
	local w, h = getWidth( self ), getHeight( self )
	local result = Grid2d.new( w, h )
	for x = 1, w do
		for y = 1, h do
			result[x][y] = self[w-x+1][y]
		end
	end
	return result
end

function Grid2d:flipVertical()
	local w, h = getWidth( self ), getHeight( self )
	local result = Grid2d.new( w, h )
	for x = 1, w do
		for y = 1, h do
			result[x][y] = self[x][h-y+1]
		end
	end
	return result
end

function Grid2d:transpose()
	local w, h = getWidth( self ), getHeight( self )
	local result = Grid2d.new( h, w )
	for x = 1, w do
		for y = 1, h do
			result[y][x] = self[x][y]
		end
	end
	return result
end

function Grid2d:rotateClockwise()
	local w, h = getWidth( self ), getHeight( self )
	local result = Grid2d.new( h, w )
	for x = 1, w do
		for y = 1, h do
			result[y][w-x+1] = self[x][y]
		end
	end
	return result
end

function Grid2d:rotateCounterClockwise()
	local w, h = getWidth( self ), getHeight( self )
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
	local w, h = getWidth( self ), getHeight( self )
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

Grid2d.__index = Grid2d
Grid2d.__tostring = Grid2d.encode

return setmetatable( Grid2d, {__call = function(_,...)
	return Grid2d.new( ... )
end })
