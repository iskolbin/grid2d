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

local test2p = Grid2d.decode( test1 ):map( function( self, x, y, s )
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

print( Grid2d.new( 10, 10 ):fill( function() return '@' end ):fillRect( 3,3, 4,3, function() return '.' end ))

print( test2p:slice( 3,3, 5, 4 ))

