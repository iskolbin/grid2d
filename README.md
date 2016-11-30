Grid2d
======

Lua library with class for handling 2d grids like in tile-based games.

Grid2d.new( width, height )
---------------------------
Creates new grid with chosen dimensions.

Grid2d.new( src )
-----------------
Creates new grid copying all elements from `src`. 

Grid2d:isInside( x, y, w = 1, h = 1 )
-------------------------------------
Checks if the rectangle is inside the grid

Grid2d:fill( f, x = 1, y = 1, w = maxwidth, h = maxheight )
-----------------------------------------------------------
Apply `f` function to all cells in the selected rectangle. Changes grid __inplace__.

Grid2d:blit( src, destx = 1, desty = 1, srcx = 1, srcy = 1, srcw = maxwidth of src, srch = maxheight of src )
-------------------------------------------------------------------------------------------------------------
Put cells from `src` in the rectangle `(srcx,srcy,srcw,srch)` into the grid with offset `(destx,desty)`.
Crop result if out of bounds. Changes grid __inplace__.

Grid2d:sub( x, y, w = maxwidth, h = maxheight )
-----------------------------------------------
Create a slice from the original grid. Original grid is not changed.

Grid2d:getWidth()
-----------------
Returns grid's width.

Grid2d:getHeight()
------------------
Returns grid's height.

Grid2d:clone()
--------------
Clones current grid.

Grid2d:flipHorizontal()
-----------------------
Returns the grid with cells flipped horizontally.
```
123..    ..321
..4.. -> ..4..
..5..    ..5..
```

Grid2d:flipVertical()
---------------------
Returns the grid with cells flipped vertically.
```
123..    ..3..
..4.. -> ..4..
..5..    125..
```

Grid2d:rotateClockwise()
------------------------
Returns the grid with cells rotated clockwise on 90 degrees.
```
123..    ..1
..4.. -> ..2
..5..    543
         ...
         ...
```

Grid2d:rotateCounterClockwise()
-------------------------------
Returns the grid with cells rotated counter clockwise on 90 degrees.
```
123..    ...
..4.. -> ...
..5..    345
         2..
         1..
```

Grid2d:rotateHalfCircle()
-------------------------
Returns the grid with cells rotated on 180 degrees.
```
123..    ..5..
..4.. -> ..4..
..5..    ..321
```

Grid2d:transpose()
------------------
Transposes the grid copy, i.e. swaps rows and columns.
```
123..    ...
..4.. -> ...
..5..    543
         ..2
         ..1
```

Grid2d:encode( encoder )
------------------------
Encodes grid into string. Encoder can be either mapping table or encoding function.

Grid2d.decode( str, decoder )
-----------------------------
Creates grid from string `str` using `decoder`. Decoder can be either mapping table or encoding function.
