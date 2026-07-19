h_in = [0:10000:100000]';
fid = fopen('atmos_output.txt','wt');
%
[h, hG, T, p, rho, a_inf, mu] = simple_atmos(h_in, 1);
fprintf(fid,'Variation with geopotential altitude\n');
fprintf(fid,'---------------------------------------------------------------------------\n');
fprintf(fid,'   h(km)   hG(km)  T(K)     p(N/m^2)     rho(kg/m^3) a_inf(m/s)  mu(SI)\n');
fprintf(fid,'---------------------------------------------------------------------------\n');
fprintf(fid,'%6.0f   %6.0f   %7.2f   %8.4e   %8.4e   %5.1f   %8.4e\n',[h/1e3,hG/1e3,T,p,rho,a_inf,mu]');
%
[h, hG, T, p, rho, a_inf, mu] = simple_atmos(h_in, 0);
fprintf(fid,'\n\n\n\n');
fprintf(fid,'Variation with geometric altitude\n');
fprintf(fid,'---------------------------------------------------------------------------\n');
fprintf(fid,'   h(km)   hG(km)  T(K)     p(N/m^2)     rho(kg/m^3) a_inf(m/s)  mu(SI)\n');
fprintf(fid,'---------------------------------------------------------------------------\n');
fprintf(fid,'%6.0f   %6.0f   %7.2f   %8.4e   %8.4e   %5.1f   %8.4e\n',[h/1e3,hG/1e3,T,p,rho,a_inf,mu]');

fclose all;