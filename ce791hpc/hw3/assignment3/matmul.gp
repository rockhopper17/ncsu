set logscale x 10
set xtics (1,50,100,200,400,800)
set xlabel "Matrix Size (words)"
set title "Matrix-Matrix Multiplication"
set yrange [0:500]
set term x11
#set term postcript color
plot "matmulc.dat" notitle  with linespoints
