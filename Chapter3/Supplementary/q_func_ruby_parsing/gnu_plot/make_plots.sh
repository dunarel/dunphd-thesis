gnuplot ../files/orig_E1_q0.plt
convert -density 400 orig_E1_q0.eps -resize 50% orig_E1_q0.png
gnuplot ../files/orig_E1_pval1.plt
convert -density 400 orig_E1_pval1.eps -resize 50% orig_E1_pval1.png
gnuplot ../files/orig_E1_pval2.plt
convert -density 400 orig_E1_pval2.eps -resize 50% orig_E1_pval2.png
gnuplot ../files/orig_E1_pval3.plt
convert -density 400 orig_E1_pval3.eps -resize 50% orig_E1_pval3.png
#
gnuplot ../files/aligned_E1_q0.plt
convert -density 400 aligned_E1_q0.eps -resize 50% aligned_E1_q0.png
gnuplot ../files/aligned_E1_pval1.plt
convert -density 400 aligned_E1_pval1.eps -resize 50% aligned_E1_pval1.png
gnuplot ../files/aligned_E1_pval2.plt
convert -density 400 aligned_E1_pval2.eps -resize 50% aligned_E1_pval2.png
gnuplot ../files/aligned_E1_pval3.plt
convert -density 400 aligned_E1_pval3.eps -resize 50% aligned_E1_pval3.png

