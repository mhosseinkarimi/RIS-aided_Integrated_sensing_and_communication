% clc, clear, close all;

simParams.fc = 100e9; % fc
simParams.W = 500e6; % bandwidth
simParams.N = 31; % number of OFDM subcarriers
simParams.NB = 4; % number of antennas in BS
simParams.NR = 32; % number of RIS elements
simParams.b = [0, 0]; % BS position
simParams.r = [5, 10]; % RIS position
simParams.m = [7, 7]; % MS position
simParams.N0 = 1e-14;   % noise power

PdB = 0:5:60;

RValues_incremental = zeros(1, numel(PdB));
CRLBValues_incremental = zeros(1, numel(PdB));

% incremental phase
i = 1:simParams.NR;
lambda = 3e8/simParams.fc;
delta = lambda/2;
phi_BL = -pi + acos(((simParams.r(1) - simParams.b(1))/norm(simParams.r-simParams.b)));
theta_LM = -acos(((simParams.m(1)-simParams.r(1))/norm(simParams.r-simParams.m)));
phi = mod(2*pi*(i-1)*delta*(sin(theta_LM)-sin(phi_BL))/lambda, 2*pi);
Phi = diag(exp(1i*phi));

for j = 1:numel(PdB)
    RValues_incremental(j) = AchievableRate(Phi, db2pow(PdB(j)), simParams);
    CRLBValues_incremental(j) = PEB(Phi, db2pow(PdB(j)), simParams);
%     save("results\incremental_32.mat", "CRLBValues_incremental", "RValues_incremental");
end

% Calculating the objective function
alpha = 0.2;
beta = 0.8;
objFn = -alpha * RValues_incremental + beta*CRLBValues_incremental;

plot(PdB, real(objFn))

% PSO optimized results
% load("results\number_of_elements_32_crlb.mat")
% load("results\number_of_elements_32_r.mat")
% channel parameters
c = 3e8;    % wave propagation speed
lambda = c/simParams.fc; % wave length
dBR = norm(simParams.r - simParams.b);   % BR distance
dRM = norm(simParams.m - simParams.r);  % RIS and MS distance
rhoBR = lambda/(4*pi*dBR); % free space loss BR
rhoRM = lambda/(4*pi*dRM);   % free space loss RIS-MS
SNR = PdB + pow2db(rhoBR^2*rhoRM^2/simParams.N0);

figure ();
semilogy(SNR, CRLBValues_incremental, "b-", LineWidth=1.5);
hold on;
% for k = 1:10
%     semilogy(PdB, CRLBValues(:, :, k), "--", LineWidth=1.5);
% end

semilogy(SNR, CRLBValues, "r--", LineWidth=1.5);
xlabel("P [dBWatt]", Interpreter="latex");
ylabel("PEB [m]", Interpreter="latex");
legend(["Theoretical bound", "PSO optimization"]);
grid("on");
title("Comparison of CRLB for PSO and Theoretical Bound $N_{RIS} = 32$", Interpreter="latex");
figure();
semilogy(SNR, RValues_incremental, "b-", LineWidth=1.5);
hold on;
% for k = 1:10
%     semilogy(PdB, RValues(:, :, k), "--", LineWidth=1.5);
%     hold on;
% end
semilogy(SNR, RValues, "r--", LineWidth=1.5);
xlabel("P [dBWatt]", Interpreter="latex");
ylabel("Achievabe Rate [bits/Hz/s]", Interpreter="latex");
legend(["Theoretical bound", "PSO optimization"]);
grid("minor");
title("Comparison of CRLB for PSO and Theoretical Bound $N_{RIS} = 32$", Interpreter="latex");