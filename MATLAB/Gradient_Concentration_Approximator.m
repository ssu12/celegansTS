% Motivation: http://www.wormbook.org/wbg/articles/volume-18-number-3/making-linear-chemical-gradients-in-agar/
%
% Question: how many days before can we get away with?
%
%Fick's equation is
%
% dc/dt =D d^2 C/ dx^2 where the d's are partials
%
% Since the petri dish is a solid boundary, we have neumann boundary conditions
%
%
%
% Created by Dr. Andrew Leifer
%
% From resources like:
% http://ramanujan.math.trinity.edu/rdaileda/teach/s12/m3357/lectures/lecture_2_28_short.pdf
%
% http://texas.math.ttu.edu/~gilliam/fall03/m4354_f03/heat_N_web/heat_ex_homo_neum.pdf
%
% we know the general solution
%
%
% for the specific initial conditions f(x)=x*C0 / L,
%
% I figure that we only really care about x=0 because if we know u(x=0,t) we
% should know that u(x=L,t)=C0 - u(x=0,t).
%
% And I assume that the profile along x is roughly linear, although we could check.
 
 
 
 
 
L=1;%cm - width of the petri dish
C0=200; %mM - highest concentration assuming lowest concentration is 0mM
D=0.84*10^-5; %cm^2 / s - diffusion coefficient of solute
days=0.12; %number of days the plates will be allowed to equilibrate
 
 
 
disp('Calculating the concentration at the far end of the plate x=0.');
disp(['We assume a ' num2str(L) 'cm plate with an initial concentration gradient from 0 to ' num2str(C0) ' mM  and D=' num2str(D) 'cm^2/s' ]);
t=0:3*60*60*24*7; %3 weeks
u=C0/2;
for n=1:2:1000
    u= u + ( 2*C0/(pi^2) )*(-2/(n^2))*exp(-D* t*(n*pi/L)^2  );
  end
figure; plot(t/(60*60*24),u);
xlabel('Days')
ylabel('Concentration at x=0 (mM)') %concentration at the end initially with concentration of 0mM
title('Concentration of Solute Based on Equilibration Time')

 
disp(['After ' num2str(days) ...
    'days the concentrations at the end point will be '...
    num2str( u(round(days*60*60*24)) )  'mM and ' ...
    num2str(C0-u(round(days*60*60*24)) ) 'mM'] )
