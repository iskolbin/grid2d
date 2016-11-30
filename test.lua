local test1 = [[
....................
.......#######......
.......#.....#......
.....###.....##.....
.....#.....####.....
.....#.....#........
.....#.....+........
.....#.....#........
.....#######........
....................]]

local Grid2d = require'Grid2d'

local test1p = Grid2d.decode( test1 )

print( test1p )

local test2p = Grid2d.decode( test1 ):fill( function( self, x, y, s )
	if s == '#' then
		if self[x][y+1] ~= '#' and self[x][y-1] ~= '#' then
			return '-'
		elseif self[x+1][y] ~= '#' and self[x-1][y] ~= '#' then
			return '|'
		else
			return 'o'
		end
	end
	return s
end )

print( test2p )

print( Grid2d.new( 10, 10 ):fill( function() return '@' end ))

print( Grid2d.new( 10, 10 ):fill( function() return '@' end ):fill( function() return '.' end, 3, 3, 4, 3 ))

print( 'sub')

print( test2p:sub( 3, 3, 5, 4 ))
print()
print( test2p:sub( 3, 3 ))
print()

local test2 = [[
123::
::4::
::5::]]

print( test2 )
print()

print( 'flip hor')
print( Grid2d.decode( test2 ):flipHorizontal())

print( 'flip vert')
print( Grid2d.decode( test2 ):flipVertical())

print( 'rot cw')
print( Grid2d.decode( test2 ):rotateClockwise())

print( 'rot ccw')
print( Grid2d.decode( test2 ):rotateCounterClockwise())

print( 'rot half')
print( Grid2d.decode( test2 ):rotateHalfCircle())

print( 'rot trans')
print( Grid2d.decode( test2 ):transpose())

local x = Grid2d.decode( test2 )
print( Grid2d.decode( test1 ):blit( x ))
print( Grid2d.decode( test1 ):blit( x, 5, 5 ))
print( Grid2d.decode( test1 ):blit( x, 5, 5, 2, 2 ))
print( Grid2d.decode( test1 ):blit( x, 5, 5, 2, 2, 1, 1 ))

