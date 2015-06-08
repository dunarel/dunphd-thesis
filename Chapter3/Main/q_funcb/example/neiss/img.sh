#!/bin/sh

gnuplot < q_func_feta.plt
convert -density 350 q_func_feta.eps -resize 50% -antialias -background white -flatten q_func_feta.png

gnuplot < q_auto_feta.plt
convert -density 350 q_auto_feta.eps -resize 50% -antialias -background white -flatten q_auto_feta.png
