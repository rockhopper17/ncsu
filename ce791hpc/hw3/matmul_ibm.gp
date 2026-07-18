set logscale x 10
set xtics (1,50,100,200,800)
set xlabel "Matrix Size (words)"
set title "Matrix-Matrix Multiplication"
set yrange [0:1000]
set term x11
set term postscript color
plot "< awk '{ print $1,$2}' matmulc.dat" title "C" with linespoints, \
     "< awk '{ print $1,$2}' matmulf.dat" title "Fortran" with linespoints,\
     "< awk '{ print $1,$3}' matmulj.dat" title "Java" with linespoints
