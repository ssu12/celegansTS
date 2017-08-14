CompTime = [0.14 253 17 734 1329 43];
Optimals = [37 23 39 19 12 33];
OpTime = [216200]; Opt = [0];
plot(Optimals,CompTime,'o');hold on;plot(Opt,OpTime,'o','Color','r');
xlabel({'Percent Solution is Longer','Than Optimal Path','(Dimensionless)'});
ylabel({'Computation Time (s)'});set(gca,'yscale','log');grid on;axis tight;
set(gca,'tickdir','out');xli = xlim*1.05-1;yli = ylim*1.35;
xlim(xli);ylim(yli);legend({'Quasi-Optimal Solutions','Optimal Solution'});