#! /bin/sh
set -x
#matmul > matmul.out
gnuplot < matmul_ibm.gp > matmul.ps
gv matmul.ps
