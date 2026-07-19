#some constants
R=1  #this is radius of the star
M=1 #mass of star
G=100  #fake gravitational constant

#create the objects
sun1=sphere(pos=vector(4.5*R,0,0), radius=R, color=color.yellow)
sun2=sphere(pos=vector(-4.5*R,0,0), radius=R, color=color.orange)
#set the masss and momentum of the stars
sun1.m=M
sun2.m=M
sun1.p=vector(0,2,0)*sun1.m
sun2.p=vector(0,-2,0)*sun2.m
#notice that the total momentum is zero vector


attach_trail(sun1)
attach_trail(sun2)

t=0
dt=0.001

while t<50:
    rate(1000)
    #calculate the vector from star 1 to 2
    r12=sun2.pos-sun1.pos

    #calculate the gravitational force on 1
    F12=-G*sun1.m*sun2.m*norm(r12)/mag(r12)**2
    #forces come in pairs, so F21 is opposite
    F21=-F12
  
    #update the momentum
    sun1.p=sun1.p+(F21)*dt
    sun2.p=sun2.p+(F12)*dt
    
    #update the position
    sun1.pos=sun1.pos+sun1.p*dt/sun1.m
    sun2.pos=sun2.pos+sun2.p*dt/sun2.m
   
    #update time
    t=t+dt
