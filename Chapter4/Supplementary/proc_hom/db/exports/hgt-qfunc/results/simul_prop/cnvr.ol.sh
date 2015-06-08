#!/bin/sh

#from standalone_02.pdf from pdflatex to new.emf for inclusion in word

echo "usage: cnvr.sh source "
echo "from source.pdf to source_ol.pdf"

source=$1

#text to outlines
gs -dNOPAUSE -dNOCACHE -dBATCH -sDEVICE=epswrite -sOutputFile=${source}-ol.eps $source.pdf

# crop eps
ps2pdf -dEPSCrop ${source}-ol.eps

#verify no fonts anymore
pdffonts ${source}-ol.pdf

#copy to outlines folder
mv ${source}-ol.pdf ol/${source}.pdf

#then in windows 
#"c:\Program Files\Inkscape\inkscape.exe" -f source2.pdf --export-emf source2.emf

