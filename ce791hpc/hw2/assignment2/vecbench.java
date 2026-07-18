// java benchmark for vector x vector multiplication
// usage: java vecbench > flops_java.dat

import java.io.*;
import java.util.*;
import java.lang.Runtime;

public class vecbench {

    public static void main(String args[]) {
//	int size = Integer.parseInt(args[0]);
	int size = 1;
	int ntimes = 1024*1024;
        System.out.println("SIZE(words)  "+"       MFLOPS");
	while (size <= 1024*1024) {
		double av[] = mkvector(size);
		double bv[] = mkvector(size);
		double cv[] = new double[size];
        	long startTime, endTime, elapsedTime, flops;
		double Mflops;
		startTime = System.currentTimeMillis();
		for (int i=0; i<ntimes; i++) {
	    		vmult(size, av, bv, cv);
		}
        endTime = System.currentTimeMillis();
	elapsedTime = endTime-startTime;
	flops = 2*ntimes*size;
	Mflops= (double)flops*1e-3/(double) elapsedTime;
        System.out.println(size+"       "+Mflops);
	size = 2*size;
	ntimes = ntimes/2;
	}
    }

    public static double[] mkvector (int length) {
	double count = 1;
	double m[] = new double[length];
	for (int i=0; i<length; i++) {
		m[i] = count++;
	    }
	return(m);
    }

    public static void vmult (int length, 
	                      double[] av, double[] bv, double[] cv) {
	for (int i=0; i<length; i++) {
		    cv[i] += av[i] * bv[i];
		}
    }
}
