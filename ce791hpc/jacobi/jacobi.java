/************************************************************
 analyze water supply options for a town
 exercise taken from CE297 (Dr. John Baugh)
************************************************************/

import java.io.*;
import java.util.*;
import java.lang.Runtime;
import mpi.*;

/*********************************************************** 
 uc = cost (in $) per million gallons per day (mgd)
             for each source
 supply limit = maximum mgd for each source
 hc = hc of water from each source (lb/mgd)
 hc_limit = maximum total hc per mgd
 demand = total demand in mgd
 time1 = wall clock time at the beginning of execution
 time2 = wall clock time at the end of execution
**************************************************************/

public class jacobi {

    public static void main(String args[])  throws MPIException {
       int size = 100;
// declare variables
       int nprocs, i, iam, n, left, right, count;
       int tag1, tag2, nit, k;
       double time1, time2, total_time, mflops;
       double errsq, error, hanal;
       Status status;
/* initialize constant parameters */
       double h0=1.0, hL=0.1;
/* initialize mpi */
       MPI.Init(args);
       iam = MPI.COMM_WORLD.Rank();
       nprocs  = MPI.COMM_WORLD.Size();
/* initialize parallel parameters */
       time1= MPI.Wtime();
       n = size/nprocs;
/* create arrays based on problem size per processor */
       double h [] = new double [n+2];
       double hnew [] = new double [n+2];
       count=1; tag1=1; tag2=2; nit=100000;
       left=iam-1; right=iam+1;

       for (i=0; i <= n+1; i++) h[i] = 0;
       if (iam == 0) h[0] = h0;
       if (iam == nprocs - 1) h[n+1] = hL;

       for (k=1; k <= nit; k++)
         {
/* if i am not processor nprocs-1  send to right neighbor */
            if (iam != nprocs - 1) MPI.COMM_WORLD.Send
                              (h, n, count, MPI.DOUBLE, right, tag1);
/* receive into left ghost buffer */
       if (iam != 0 ) status=MPI.COMM_WORLD.Recv 
                              (h, 0, count, MPI.DOUBLE, left, tag1);
/* if i am not processor 0 send to left neighbor */
       if (iam != 0 ) MPI.COMM_WORLD.Send
                              (h, 1, count, MPI.DOUBLE, left, tag2); 
/* receive into right ghost buffer */
          if (iam != nprocs - 1) status=MPI.COMM_WORLD.Recv
                              (h, n+1, count, MPI.DOUBLE, right, tag2);
/* compute interior */
          for (i = 1; i <= n; i++) hnew[i] = (h[i-1]+h[i+1])/2.0;
/* update */
          for (i = 1; i <= n; i++) h[i] = hnew[i];
/* preserve boundary values */
          if (iam == 0) h[0] = h0;
          if (iam == nprocs - 1) h[n+1] = hL;
       }
       time2= MPI.Wtime();
       total_time=time2-time1;
       mflops = size*nit*2*1e-6/(total_time);
       errsq=0;
       for (i=1; i <=n; i++) {
          hanal = h0+(hL-h0)*(iam*n+i)/(size+1);
          errsq = errsq + (hanal-h[i])*(hanal-h[i]);
       }
       error = Math.sqrt(errsq)/n;
       System.out.println("Myid: "+iam+"  Error: "+error);
       if (iam == 0) {
         System.out.println("Total time: "+total_time);
         System.out.println("Mflops: "+mflops);
       }
       MPI.Finalize();

    }

}
