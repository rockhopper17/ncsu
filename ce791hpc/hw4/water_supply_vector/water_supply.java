/************************************************************
 analyze water supply options for a town
 exercise taken from CE297 (Dr. John Baugh)
************************************************************/

import java.io.*;
import java.util.*;
import java.lang.Runtime;

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

public class water_supply {

    public static void main(String args[]) {
       int noptions = 100000;
/* construct array objects*/
       double ad1 [] = new double [noptions];
       double ad2 [] = new double [noptions];
       double ad3 [] = new double [noptions];
       double cost[] = new double[noptions];
       Random generator = new Random();
// declare variables
       double uc1, uc2, uc3;
       double sl1, sl2, sl3;
       double hc1, hc2, hc3;
       double min_cost, avg_hc=0, hc_limit, demand;
       double time1, time2, time3, time4;
       double time_obj, time_gen, time_tot, mflops;
       int i, j, min_cost_index=0;
/* initialize constant parameters */
       uc1=500; uc2 = 1000; uc3=2000;
       sl1=25; sl2=120; sl3=100;
       hc1=200; hc2=2300; hc3=700;
       hc_limit=1200; demand = 150;
       time1=0; time2=0; time3=0; time4=0;
// place a call to System.gc to eliminate inconsistent timing 
//    due to garbage collection
       System.gc();
       time1= (double) System.currentTimeMillis();
//       System.out.println("time1 ="+time1);
/* initialize design variables subject to constraints */
       for (i=0; i<noptions; i++) {
          ad3[i] = 0;
          while (ad3[i] > sl3 ||
                 ad3[i] <= 0 ||
                 avg_hc >= hc_limit) {
                ad1[i]=generator.nextDouble()*sl1;
                ad2[i]=generator.nextDouble()*sl2;
                ad3[i]=demand-ad1[i]
                                   - ad2[i];
                avg_hc = (ad1[i]*hc1
                              +ad2[i]*hc2
                              +ad3[i]*hc3)/demand;
            }
        }
        time2= (double) System.currentTimeMillis();
//       System.out.println("time2 ="+time2);
/* time to generate alternatives */
        time_gen=(time2-time1)*1e-3;
/* calculate cost */
        min_cost = 1e10;
        for (i=0; i<noptions; i++) {
         cost[i] = uc1*ad1[i] 
                     +uc2*ad2[i]
                     +uc3*ad3[i];
        } 
        time3= (double) System.currentTimeMillis();
//        System.out.println("time3 ="+time3);
        time_obj=(time3-time2)*1e-3;
        for (i=0; i<noptions; i++) {
           if (cost[i] <= min_cost) {
               min_cost = cost[i];
               min_cost_index = i;
            } 
        }
        mflops = 5*noptions*1e-6/time_obj;
        time4= (double) System.currentTimeMillis();
//        System.out.println("time4 ="+time4);
        time_tot=(time4-time1)*1e-3;
        System.out.println("Amount drawn from source1 = "
                  +ad1[min_cost_index]+" mgd");
        System.out.println("Amount drawn from source2 = "
                  +ad2[min_cost_index]+" mgd");
        System.out.println("Amount drawn from source3 = "
                  +ad3[min_cost_index]+" mgd");
        System.out.println("Minimum cost = " + min_cost +" dollars");
        System.out.println("Time to generate alternatives  = "
           +time_gen+" secs");
        System.out.println("Time to calculate objective = "
           +time_obj+ " secs");
        System.out.println("Mflop rating for objective calculation = " 
           +mflops+"  mflops");
        System.out.println("Total time = "+time_tot+" secs");
    }

}
