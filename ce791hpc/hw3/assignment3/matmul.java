// java code for matrix x matrix multiplication
// build: "javac -O matmul.java"
// run: "java matmul > matmulj.dat"

// import java.io.*;
// import java.util.*;
// import java.lang.Runtime;


public class matmul {
    static int ntimes = 100;

    public static void main(String args[]) {
//	int size = Integer.parseInt(args[0]);
	int size = 25;
	int ntimes = 1024;
        System.out.println("#SIZE      SUM          MFLOPS");
	while (size <= 800) {
		double a[][] = mkmatrix(size, size, 1);
		double b[][] = mkmatrix(size, size, 2);
		double c[][] = mkmatrix(size, size, 0);
        	long startTime, endTime, elapsedTime, flops;
		double Mflops;
		double sum = 0;
		startTime = System.currentTimeMillis();
		for (int i=0; i<ntimes; i++) {
	    		mmult(size, size, a, b, c);
			sum += c[size-1][size-1];
	        }
        	endTime = System.currentTimeMillis();
		elapsedTime = endTime-startTime;
		flops = 2*ntimes*size*size*size;
		Mflops= flops*1e-3/elapsedTime;
//  compute sum of matrix to avoid deadcode removal
     		for (int i=0; i<size; i++)
     		{
         	  for (int j=0; j<size; j++) sum += c[i][j];
		}
                System.out.println(size+"       "+sum+"    "+Mflops);
		size = 2*size;
		ntimes = ntimes/4;
	 }
    }

    public static double[][] mkmatrix (int rows, int cols, double value) {
	double count = 1;
	double m[][] = new double[rows][cols];
	for (int i=0; i<rows; i++) {
	    for (int j=0; j<cols; j++) {
		m[i][j] = value;
	    }
	}
	return(m);
    }

    public static void mmult (int rows, int cols, 
	                      double[][] a, double[][] b, double[][] c) {
	for (int i=0; i<rows; i++) {
	    for (int j=0; j<cols; j++) {
		c[i][j] = 0;
		for (int k=0; k<cols; k++) {
		    c[i][j] += a[i][k] * b[k][j];
		}
	    }
	}
    }
}
