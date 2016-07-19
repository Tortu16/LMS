%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         Proyecto 1
%
%                        Luis Jimenez
%
%   Cancelacion activa de ruido auditivo para mejora en la 
%   captura de voz utilizando un algoritmo adaptativo LMS.   
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
%file = csvread('C:\Users\luisd\Dropbox\Maestria\Procesamiento Adaptativo\Proyecto\Adaptive Noise Canceling\FanNoise2.txt',1);
file = csvread('C:\Users\ljimenez\Documents\MATLAB\FanNoise2.txt',1);

% Longitud de la senal en muestras
N = size(file);
N = N(1);

% Varianzas de dos procesos estocasticos artificiales
var1 = 0.27;
var2 = 0.1;

% Generacion de los procesos estocasticos artificiales
%va1 = 2*file(1:N,1);
va1 = sqrt(var1)*randn(N,1);
va2 = sqrt(var2)*randn(N,1);

% Calculo de la varianza del ruido correlacionado d(n)
% Esta senal es el resultado del efecto de un filtro IIR sobre ruido blanco
% va1

vard =  var1/(1-0.8458*0.8458);

% Construye la senal de ruido correlacionado al de referencia

d(N) = 0;
d(1) = va1(1);
for k = 2:N
    d(k) = va1(k) - 0.8458*d(k-1);
end

% Construye la senal de entrada del filtro u = senal + v1

dn(N)=0;
for n=1:N;
dn(n)=sin((0.03*pi).*n+0.2*pi);
end;

u = dn' + va1;

Rsignal = 2*file(:,1);
Rnoise = 2*file(:,2);

Asignal = u;
Anoise = d;

filterOrder = 4;
AwLMS = zeros(filterOrder,1);
RwLMS = zeros(filterOrder,1);

Amu = 1/(filterOrder*var(Anoise))
Rmu = 1/(filterOrder*var(Rnoise))

Ae(N) = 0;
Re(N) = 0;

%wt2(N,:) = wLMS;
Atemp = zeros(filterOrder,1);
Rtemp = zeros(filterOrder,1);

for k = filterOrder:N
    %temp = [noise(k); noise(k-1);noise(k-2); ... ; noise(k-m+1)]
    for m = 1:filterOrder
        Atemp(m) = Anoise(k-m+1);
        Rtemp(m) = Rnoise(k-m+1);
    end
    
    %%%%%%%%%%%%%%      NLMS      %%%%%%%%%%%%%%
    
    % Opera en la senal Artificial
    Ae(k) = Asignal(k) - AwLMS'*Atemp;
    AwLMS = AwLMS + (Amu/(Atemp'*Atemp))*Ae(k)*Atemp;
    
    % Opera en la senal Real (adquirida)
    Re(k) = Rsignal(k) - RwLMS'*Rtemp;
    RwLMS = RwLMS + (Amu/(Rtemp'*Rtemp))*Re(k)*Rtemp;
    %wt2(k,1) = wLMS(1);
    %wt2(k,2) = wLMS(2);
end

AwLMS
RwLMS
% plot(noise(248574:249574),'b')
% hold
% plot(signal(248574:249574),'r')
% plot(dn(248574:249574),'g')
% plot(e(248574:249574),'k')

Afigure = figure('Name','Senales Simuladas');
subplot(2,2,1)
plot(Anoise(N/2:floor(2*N/3)),'b')
title('Senal de ruido artificial');
subplot(2,2,2)
plot(Asignal(N/2:floor(2*N/3)),'r')
title('Senal sinusoidal ruidosa artificial');
subplot(2,2,3)
plot(dn(N/2:floor(2*N/3)),'g')
title('Senal de sinusoidal artificial');
subplot(2,2,4)
plot(Ae(N/2:floor(2*N/3)),'k')
title('Senal de error artificial');
Asnr = [snr(Asignal, 51100, 6) snr(Ae, 51100, 6)]
Athd = [thd(Asignal) thd(Ae)]

Rfigure = figure('Name','Senales Reales');
subplot(2,2,1)
plot(Rnoise(N/2:floor(2*N/3)),'b')
title('Senal de ruido adquirida');
subplot(2,2,2)
plot(Rsignal(N/2:floor(2*N/3)),'r')
title('Senal de voz ruidosa adquirida');
subplot(2,2,3)
plot(Re(N/2:floor(2*N/3)),'k')
title('Senal de error adquirida');
Rsnr = [snr(Rsignal, 51100, 6) snr(Re, 51100, 6)]
Rthd = [thd(Rsignal) thd(Re)]

%sound(Rsignal(1:248574),51100)
%sound(Re(1:248574),51100)
