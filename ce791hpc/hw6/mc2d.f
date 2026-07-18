      program MC2DIM
c
c     Runs Monte Carlo on 2-dimensional lattice
c
c     INPUT: 
c       L = dimension of the lattice (size of box)
c       lattype = type of the lattice:
c             1 - simple square 
c             2 - triangular 
c             3 - rhombohedral 
c       V2 = interaction with nearest neighbors
c            V2= -1   FM
c            V2= +1  AFM
c       V1 = interaction with external field
c
c       Tinit, Tfinal = initial, final Temperature
c       nTsteps       = number of Temperature steps (MAX= 500) 
c          (NOTE MAX can be bigger, but check machine memory)
c
c      nMC=L+2                 The no. of steps before sampling.
c      ntimes=125 (Int. > 100) The no. of times sampled for avg.
c  ***** set ntimes=400 (large L > 10) - 800 (small L < 10)
c        to obtain better (i.e., smoother) curves due to longer
c        equilibriation at given T.
c

c
c     OUTPUT:
c       file1.out : T, itime, E, M
c       file2.out : T, Eav, dEav, Mav, dMav, CvT
c       file3.out : T, time, lattice_plot
c      
c       T          = instant Temperature,
c       itime      = instant time at T,
c       E(T,itime) = instant value of Energy per atom,
c       M(T,itime) = instant value of Magnetization per atom,
c       Eav(T)     = average Energy per atom
c       +/- dEav(T)=  and its fluctuation at T, 
c       Mav(T)     = average Magnetization per atom     
c       +/- dMav(T)=  and its fluctuation at T.  
c       Cv(T)      = Average Specific Heat 
c                    (which is related to the pair correlations)
c                   
c
       implicit none 
       
       character IN1FILE*128
       character OUT1FILE*128
       character OUT2FILE*128
       character OUT3FILE*128
       
       parameter(
     1   IN1FILE='in.2d' ,
     1   OUT1FILE='file1.out' ,
     2   OUT2FILE='file2.out' , 
     3   OUT3FILE='file3.out' )
       
       
       integer lattype, L
       real*8  V2, V1
       real*8  Tinit, Tfinal
       integer nTsteps, nMC, ntimes
       real*8  ConcInit
       parameter( ConcInit=0.5 )       
       
       WRITE(*,*) 'Welcome to 2-dim Monte Carlo!'   
      
       call readinpt(  
     1         IN1FILE,
     2         lattype, L, V2, V1,
     3         Tinit, Tfinal, nTsteps, 
     4         nMC, ntimes  )      
     
       WRITE(*,*) 'Input is read successfully...'
       
       call runout(
     1   OUT1FILE ,
     2   OUT2FILE ,
     3   OUT3FILE ,
     1   lattype, L, V2, V1,
     2   Tinit, Tfinal, nTsteps, 
     4   nMC, ntimes,
     3   ConcInit  )

       WRITE(*,*) 'Output is written into files: '
       WRITE(*,*)  OUT1FILE      
       WRITE(*,*)  OUT2FILE
       WRITE(*,*)  OUT3FILE
       WRITE(*,*) 'End of computations.'  
       
      end
     
*******************************************************     
     
      subroutine readinpt(  
     1         IN1FILE,
     2         lattype, L, V2, V1,
     3         Tinit, Tfinal, nTsteps,
     4         nMC, ntimes  )
c
c    Reads input from file IN1FILE 
c       
       character IN1FILE*128       
       integer L,lattype 
       real*8  V2, V1
       integer nTsteps
       real*8  Tinit, Tfinal
                    
       open(UNIT=11, FILE=IN1FILE, 
     ^      ACCESS='SEQUENTIAL',
     ^      STATUS='OLD' )  
         
         read(11,*) lattype, L, V2, V1
         read(11,*) Tinit, Tfinal, nTsteps
         read(11,*) ntimes,iseed
        
       close(11) 
       
        call random_init(iseed)
       nMC=L+2            ! no. of steps before sampling.
c       ntimes=125         ! no. of times sampled for avg.
       
      return
      end 
      
******************************************************* 

      subroutine runout(
     1   OUT1FILE ,
     2   OUT2FILE ,
     3   OUT3FILE ,
     1   lattype, L, V2, V1,
     2   Tinit, Tfinal, nTsteps, 
     4   nMC, ntimes, 
     3   ConcInit )
     
c
c    Calculates everything and writes
c    output into files OUT1FILE, OUT2FILE, OUT3FILE.
c     
       character OUT1FILE*128
       character OUT2FILE*128
       character OUT3FILE*128

       integer lattype, L
       real*8  V2, V1
       real*8  Tinit, Tfinal, dT
       integer nTsteps, iTstep
       real*8  ConcInit
       
       integer L_p, nTsteps_p, nlattyp_p, ntime_p
       parameter( 
     1   L_p=128,
     2   nTsteps_p=500,
     3   nlattyp_p=8,
     4   ntime_p=2000 )   
       
       real*8  Einst( nTsteps_p, ntime_p )
       integer Minst( nTsteps_p, ntime_p )
       real*8  rMinst( ntime_p )
       real*8  Et( ntime_p )
       integer Mt( ntime_p )
       real*8  Eav( nTsteps_p ), dEav( nTsteps_p )
       real*8  E2av( nTsteps_p ), CvT( nTsteps_p )
       real*8  avM( nTsteps_p ), dMav( nTsteps_p ) 
       real*8  Eavg, avgM, dEavg, avgdM, E2avg, Cv

c  Internal variables:       
       integer itime, M, i,j
       real*8  T, E
cc nncoords:
       integer nnnumber, nnnum_p
       parameter( nnnum_p=8 ) 
       integer idx(nnnum_p), jdy(nnnum_p) 
cc latinit:
       integer ijatom(0:L_p+1,0:L_p+1) 
c  functions:
       real*8  Energy, dEnergy            
       
c  MEMORY CHECK
       if(L       .gt. L_p)  then
           write(*,*) "  L gt L_MAX: reset L .le.", L_p
       endif
       if(nTsteps .gt. nTsteps_p) then
           write(*,*) "  nTsteps gt nTsteps_p: reset .le.", nTsteps_p
       endif

       
       call nncoords(
     1       lattype, 
     2       nnnumber, nnnum_p,
     3       idx, jdy )
       
       call latinit(
     1       lattype, L, L_p,
     2       ConcInit,
     1       ijatom  )  
       
       E = Energy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,
     6       M  )       
                    
       dT=(Tfinal-Tinit)/dfloat(nTsteps-1)
       
       open(UNIT=31, FILE=OUT1FILE, status='UNKNOWN')
       open(UNIT=32, FILE=OUT2FILE, status='UNKNOWN')
       open(UNIT=33, FILE=OUT3FILE, status='UNKNOWN')
       open(UNIT=34, FILE='file4.out', status='UNKNOWN')
       
       
       WRITE(*,*) 'E=',E,' V1=',V1,' V2=',V2
       WRITE(*,*) 'Start loop over Temperature:' 
c
c    Loop over Tempetature
c       
      do 100 iTstep=1, nTsteps
       T=Tinit+dT*(iTstep-1)
       
       call MonteCar(
     1       lattype, L, L_p,  
     2       nnnumber, nnnum_p,
     3       idx, jdy,
     4       V2, V1, 
     5       T,  
     1       E, M,
     2       Et, Mt,
     2       ijatom ,
     6       nMC, ntimes, ntime_p )  
                    
       Eavg=0
       E2avg=0
       avgM=0
       Cv=0
       do 111 itime=1,ntimes
         Einst(iTstep,itime)=Et(itime)
         Minst(iTstep,itime)=Mt(itime) 
         rMinst(itime)=dfloat(Mt(itime))/dfloat(L*L)
         write(31,1131) T, itime, 
     ^         Et(itime)/dfloat(L*L), rMinst(itime)      
1131     format(1X, F18.9,TR1,I4,TR1,F18.9,TR1,F12.9)        
         Eavg=Eavg+Et(itime)
         E2avg=E2avg+Et(itime)*Et(itime)
         avgM=avgM+rMinst(itime)
111    continue 
       Eavg = Eavg/dfloat(ntimes)
       E2avg = E2avg/dfloat(ntimes)
       avgM = avgM/dfloat(ntimes)
       avM( iTstep ) = avgM         
       
       dEavg=0
       avgdM=0
       do 112 itime=1,ntimes
         dEavg = dEavg + (Et(itime)-Eavg)**2
         avgdM = avgdM + (rMinst(itime)-avgM)**2
112    continue 
       dEavg = dEavg/dfloat(ntimes*(ntimes-1))
       avgdM = avgdM/dfloat(ntimes*(ntimes-1))
       dEavg = sqrt( dEavg ) 
       avgdM = sqrt( avgdM )
       dMav( iTstep ) = avgdM
       Eav( iTstep ) = Eavg/dfloat(L*L)  
       E2av( iTstep ) = E2avg/dfloat(L*L*L*L)    
       dEav( iTstep ) = dEavg/dfloat(L*L) 
       Cv = ((E2avg - Eavg*Eavg)/(T*T))/dfloat(L*L*L*L)
       CvT(iTstep)=(E2av(iTstep)- Eav(iTstep)**2)/(T*T)
       
       write(32,1132) T, Eav(iTstep), dEav(iTstep),
     ^       avM( iTstep ), dMav( iTstep ), CvT(iTstep)
1132   format(1X,F15.9,TR1,F18.9,TR1,F17.9,
     ^      TR2,F12.9,TR1,F12.9,TR1,F15.10) 
     
       write(33,*) 'T=',T
       do 133 i=0,L+1
         write(33,1133) ( (ijatom(i,j)+1)/2 , j=0,L+1 )
1133     format(1X,128I1)
133    continue            
           
100   continue       

      close(31)
      close(32)
      close(33)
      close(34)
 
      return
      end       
       
*******************************************************
      subroutine MonteCar(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1, 
     5       T, 
     1       E, M, 
     2       Et, Mt,    
     2       ijatom ,
     6       nMC, ntimes, ntime_p ) 
           
       integer lattype, L, L_p, nnnumber, nnnum_p
       integer idx(nnnum_p), jdy(nnnum_p)       
       real*8  V2, V1, T, E, dE, Et( ntime_p )
       integer M, Mt( ntime_p )
       integer ijatom(0:L_p+1,0:L_p+1)
       integer nMC, ntimes, ntime_p 
       integer iMC, itime
      
       integer i,j
       real*8  r, beta
       real*8  random, dEnergy
       integer nreject,nacrais,naclower
       
       nattemp=0
       nreject=0
       nacrais=0
       naclower=0
       beta=1.0/T
       
       do 101 itime=1,ntimes
        do 102 iMC=1, nMC 
        
cc      Periodic Boundary: ijatom
c    (1,1)=(1,L+1)=(L+1,1)=(L+1,L+1) 

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,1,1  )   
         if(dE .le. 0)then
             ijatom(1,1)=-ijatom(1,1)
             ijatom(1,L+1)=-ijatom(1,L+1)
             ijatom(L+1,1)=-ijatom(L+1,1)
             ijatom(L+1,L+1)=-ijatom(L+1,L+1)
             M=M+2*ijatom(1,1) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(1,1)=-ijatom(1,1)
             ijatom(1,L+1)=-ijatom(1,L+1)
             ijatom(L+1,1)=-ijatom(L+1,1)
             ijatom(L+1,L+1)=-ijatom(L+1,L+1)             
             M=M+2*ijatom(1,1) 
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
 
c    (1,L)=(1,0)=(L+1,0)=(L+1,L)   

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,1,L  )   
         if(dE .le. 0)then
             ijatom(1,L)=-ijatom(1,L)
             ijatom(1,0)=-ijatom(1,0)
             ijatom(L+1,0)=-ijatom(L+1,0)
             ijatom(L+1,L)=-ijatom(L+1,L)
             M=M+2*ijatom(1,L) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(1,L)=-ijatom(1,L)
             ijatom(1,0)=-ijatom(1,0)
             ijatom(L+1,0)=-ijatom(L+1,0)
             ijatom(L+1,L)=-ijatom(L+1,L)             
             M=M+2*ijatom(1,L) 
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
         
c    (L,1)=(0,1)=(0,L+1)=(L,L+1) 

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,L,1  )   
         if(dE .le. 0)then
             ijatom(L,1)=-ijatom(L,1)
             ijatom(0,1)=-ijatom(0,1)
             ijatom(0,L+1)=-ijatom(0,L+1)
             ijatom(L,L+1)=-ijatom(L,L+1)
             M=M+2*ijatom(L,1) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(L,1)=-ijatom(L,1)
             ijatom(0,1)=-ijatom(0,1)
             ijatom(0,L+1)=-ijatom(0,L+1)
             ijatom(L,L+1)=-ijatom(L,L+1)
             M=M+2*ijatom(L,1) 
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
    
c    (L,L)=(0,0)=(0,L)=(L,0)

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,L,L  )   
         if(dE .le. 0)then
             ijatom(L,L)=-ijatom(L,L)
             ijatom(0,0)=-ijatom(0,0)
             ijatom(0,L)=-ijatom(0,L)
             ijatom(L,0)=-ijatom(L,0)
             M=M+2*ijatom(L,L) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(L,L)=-ijatom(L,L)
             ijatom(0,0)=-ijatom(0,0)
             ijatom(0,L)=-ijatom(0,L)
             ijatom(L,0)=-ijatom(L,0)
             M=M+2*ijatom(L,L) 
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
   
c    (1,j)=(L+1,j)
       do 5 j=2,L-1 

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,1,j  )   
         if(dE .le. 0)then
             ijatom(1,j)=-ijatom(1,j)
             ijatom(L+1,j)=-ijatom(L+1,j)             
             M=M+2*ijatom(L+1,j) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(1,j)=-ijatom(1,j)
             ijatom(L+1,j)=-ijatom(L+1,j)             
             M=M+2*ijatom(L+1,j) 
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
              
5      continue
c    (L,j)=(0,j)         
       do 6 j=2,L-1 

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,L,j  )   
         if(dE .le. 0)then
             ijatom(L,j)=-ijatom(L,j)
             ijatom(0,j)=-ijatom(0,j)             
             M=M+2*ijatom(L,j) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(L,j)=-ijatom(L,j)
             ijatom(0,j)=-ijatom(0,j)             
             M=M+2*ijatom(L,j)             
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
        
6      continue 
c    (i,1)=(i,L+1)
       do 7 i=2,L-1 
        
         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,i,1  )   
         if(dE .le. 0)then
             ijatom(i,1)=-ijatom(i,1)
             ijatom(i,L+1)=-ijatom(i,L+1)             
             M=M+2*ijatom(i,1) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(i,1)=-ijatom(i,1)
             ijatom(i,L+1)=-ijatom(i,L+1)             
             M=M+2*ijatom(i,1) 
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
                
7      continue 
c    (i,L)=(i,0)
       do 8 i=2,L-1 

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,i,L  )   
         if(dE .le. 0)then
             ijatom(i,L)=-ijatom(i,L)
             ijatom(i,0)=-ijatom(i,0)             
             M=M+2*ijatom(i,L) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(i,L)=-ijatom(i,L)
             ijatom(i,0)=-ijatom(i,0)             
             M=M+2*ijatom(i,L) 
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
               
8      continue 
cc   (i,j):   ijatom(i,j) = 1 or -1
       do 91 i=2,L-1
        do 92 j=2,L-1 

         dE=dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,i,j  )   
         if(dE .le. 0)then
             ijatom(i,j)=-ijatom(i,j)                      
             M=M+2*ijatom(i,j) 
             E=E+dE
             naclower=naclower+1
         else if( random() .le. exp(-beta*dE) )then
             ijatom(i,j)=-ijatom(i,j)                      
             M=M+2*ijatom(i,j)               
             E=E+dE
             nacrais=nacrais+1 
         else     
             nreject=nreject+1     
         endif         
                   
92      continue
91     continue
                
102    continue

       Et(itime)=E
       Mt(itime)=M

101   continue 
     
       write(34,1134) T,nacrais,naclower,nreject
1134   format(1X, F18.9, 3I12)       
       
c       WRITE(*,*) ' N attempts=',
c     ^             nreject+nacrais+naclower,
c     ^            ' N rejected=',nreject     
c       WRITE(*,*) ' N accepted with E_raising=',
c     ^    nacrais,', E_lowering=',naclower
c       WRITE(*,*) 'T=',T,' E=',E/dfloat(L*L),' M=',M 
      end

*******************************************************
      real*8 function Energy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,
     6       M  ) 
       integer lattype, L, L_p,nnnumber, nnnum_p
       integer idx(nnnum_p), jdy(nnnum_p) 
       real*8  V2, V1, E2, E1
       integer iE1, iE2, inE2
       integer ijatom(0:L_p+1,0:L_p+1), iatom
       integer M
       integer i,j,k,i2,j2
       
       
       iE1=0       
         do 21 i=1,L
          do 22 j=1,L     
           iE1=iE1+ijatom(i,j)
22        continue
21       continue  
       M=iE1       
       E1=V1*iE1
       
       iE2=0
       do 31 i=1,L
        do 32 j=1,L
         inE2=0 
         do 33 k=1,nnnumber
           i2=i+idx(k)
           j2=j+jdy(k)
           inE2=inE2+ijatom(i2,j2)
33       continue           
         iE2=iE2+ijatom(i,j)*inE2 
32      continue
31     continue  
       E2=V2*iE2
       Energy=E1+0.5*E2
      end 
*******************************************************
      real*8 function dEnergy(
     1       lattype, L, L_p,       
     2       nnnumber, nnnum_p,       
     3       idx, jdy,
     4       V2, V1,      
     5       ijatom,i,j  ) 
       integer lattype, L, L_p,nnnumber, nnnum_p
       integer idx(nnnum_p), jdy(nnnum_p) 
       real*8  V2, V1, dE2, dE1
       integer idE2, inE2
       integer ijatom(0:L_p+1,0:L_p+1)
       integer i,j       
       integer k,i2,j2
       
        dE1=-2*ijatom(i,j)*V1
       
         inE2=0 
         do 33 k=1,nnnumber
           i2=i+idx(k)
           j2=j+jdy(k)
           inE2=inE2+ijatom(i2,j2)
33       continue           
         idE2=-2*ijatom(i,j)*inE2   
        dE2=V2*idE2
       dEnergy=dE1+dE2
      end          
       
*******************************************************       
      subroutine latinit(
     1       lattype, L, L_p,
     2       ConcInit,
     1       ijatom  ) 
c
c    Initialises lattice and buffer layer.
c      ijatom(i,j) = 1 or -1
c
       implicit none 
       integer lattype, L, L_p
       real*8  ConcInit      
       integer ijatom(0:L_p+1,0:L_p+1)
       integer itype 
       integer i,j 
       integer nexttype
       
cc   Periodic Boundary: ijatom
c    (1,1)=(1,L+1)=(L+1,1)=(L+1,L+1)           
       itype=nexttype(ConcInit)
       ijatom(1,1)=itype
       ijatom(1,L+1)=itype
       ijatom(L+1,1)=itype
       ijatom(L+1,L+1)=itype
c    (1,L)=(1,0)=(L+1,0)=(L+1,L)       
       itype=nexttype(ConcInit)    
       ijatom(1,L)=itype
       ijatom(1,0)=itype
       ijatom(L+1,0)=itype
       ijatom(L+1,L)=itype
c    (L,1)=(0,1)=(0,L+1)=(L,L+1)
       itype=nexttype(ConcInit)      
       ijatom(L,1)=itype
       ijatom(0,1)=itype
       ijatom(0,L+1)=itype
       ijatom(L,L+1)=itype
c    (L,L)=(0,0)=(0,L)=(L,0)
       itype=nexttype(ConcInit)
       ijatom(L,L)=itype
       ijatom(0,0)=itype
       ijatom(0,L)=itype
       ijatom(L,0)=itype
c    (1,j)=(L+1,j)
       do 5 j=2,L-1 
         itype=nexttype(ConcInit)
         ijatom(1,j)=itype
         ijatom(L+1,j)=itype
5      continue
c    (L,j)=(0,j)         
       do 6 j=2,L-1 
         itype=nexttype(ConcInit)
         ijatom(L,j)=itype
         ijatom(0,j)=itype
6      continue 
c    (i,1)=(i,L+1)
       do 7 i=2,L-1 
         itype=nexttype(ConcInit)
         ijatom(i,1)=itype
         ijatom(i,L+1)=itype
7      continue 
c    (i,L)=(i,0)
       do 8 i=2,L-1 
         itype=nexttype(ConcInit)
         ijatom(i,L)=itype
         ijatom(i,0)=itype
8      continue 
cc   (i,j):   ijatom(i,j) = 1 or -1
       do 91 i=2,L-1
        do 92 j=2,L-1
         ijatom(i,j)=nexttype(ConcInit)          
92      continue
91     continue
       return
      end
*******************************************************       
      integer function nexttype(ConcInit)
       real*8 ConcInit, random
       if(ConcInit .le. random() )then
         nexttype=-1
       else
         nexttype=1
       endif
       return
      end
         
       
       

*******************************************************       
      subroutine nncoords(
     1       lattype,
     1       nnnumber, nnnum_p, 
     2       idx, jdy )  
       implicit none    
       integer lattype    
       integer nnnumber, nnnum_p
       integer idx(nnnum_p), jdy(nnnum_p)
       
       if( lattype .eq. 1 )then
         write(6,*) ' Simple square lattice '
         nnnumber=4
         idx(1)=1
         jdy(1)=0
         idx(2)=0
         jdy(2)=1
         idx(3)=-1
         jdy(3)=0
         idx(4)=0
         jdy(4)=-1
       else if( lattype .eq. 2 )then 
         write(6,*) ' Triangular lattice '
         nnnumber=6
         idx(1)=1
         jdy(1)=0
         idx(2)=0
         jdy(2)=1
         idx(3)=-1
         jdy(3)=1
         idx(4)=-1
         jdy(4)=0
         idx(5)=0 
         jdy(5)=-1
         idx(6)=1
         jdy(6)=-1
       else
         write(6,*) ' Rombohedral lattice '
         nnnumber=2
         idx(1)=1
         jdy(1)=0
         idx(2)=-1
         jdy(2)=0
       end if
       
       return
       end    

       subroutine random_init(iseed)
          integer iseed
          real*8 r_int
          common /rand/r_int

          r_int = iseed

   
       end
        
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      real*8 FUNCTION random()
cccccc______ Generates random numbers 0<r<1 ____________cccccc 
cc  multipl=524287 => Period=max=2**31-2 , rinit_int=any int.

        real*8 scope, multipl, scopinv, rinit_int
        parameter(   scope=2.0d0**31-1.0d0,
     2               scopinv=1.0/scope ,
     3               multipl=524287.0d0 ,
     4               rinit_int=1321.0d0  
     6                                 )
c        real*8 r_int/rinit_int/
        real*8 r_int
        common /rand/r_int
c        SAVE r_int        
        
      if (r_int.eq.0.d0) then r_int = rinit_int
      r_int=dmod(r_int*multipl, scope)
      random=r_int*scopinv
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
