//
// mpiJava version : Kumar
//                   September 2002
//                   NCSU
//

import java.io.*;

import mpi.*;

public class jpi {

  static void main(String[] args) throws MPIException {
     
    double     PI = Math.PI;
    double h, sum, x;
    int myid, numprocs, i;
    boolean done = false;
    int n = 100000;
    double mypi[]= new double [1];
    double pi[]= new double [1];
    double start_time, end_time, elapsed_time, Error;
    String input [] = new String[8];

    MPI.Init(args);

    myid = MPI.COMM_WORLD.Rank();
    numprocs  = MPI.COMM_WORLD.Size();

        start_time = MPI.Wtime();
        sum = 0.0;
        h   = 1.0 / (double) n;
        for (i = myid + 1; i <= n; i += numprocs)
                {
                x = h * ((double)i - 0.5);  
                sum += 4/(1+x*x);
        }
        mypi[0] = h * sum;
        MPI.COMM_WORLD.Reduce(mypi,0,pi,0,1,MPI.DOUBLE,MPI.SUM,0);
        end_time = MPI.Wtime();
	elapsed_time = end_time-start_time;
        if (myid == 0)
            {
	     Error = Math.abs(pi[0] - PI);
             System.out.println("\n pi is approximately "+pi[0]);
             System.out.println("\n Error is  "+Error);
             System.out.println("\n Wall clock time = "+  elapsed_time + " secs");
        }
    MPI.Finalize();    
  }
}
