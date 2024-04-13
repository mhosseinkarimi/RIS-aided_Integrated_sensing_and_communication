% test script
clc, clear, close all;
%% Setting the simulation parameters
simParams.fc = 100e9; % fc
simParams.W = 500e6; % bandwidth
simParams.N = 31; % number of OFDM subcarriers
simParams.NB = 4; % number of antennas in BS
simParams.NR = 32; % number of RIS elements
simParams.b = [0, 0]; % BS position
simParams.r = [5, 10]; % RIS position
simParams.m = [7, 7]; % MS position
simParams.N0 = 1e-14;   % noise power
simParams.PSOIter = 100;    % number of PSO iterations
simParams.SwarmSize = 20;   % PSO swarm size
simParams.PSOTol = 0;    % PSO tolorence
simParams.objFcnMethod = "penalty";
simParams.commCoeff = 0.2; % communication objective function coeffitient
simParams.locCoeff = 0.8;  % localization objective function ceffitient
simParams.MonteCarloIter = 10; % number of Monte Carlo simulations
simParams.MonteCarloDisplayPhase = false;
simParams.MonteCarloDisplayObjFn = true;

%% PSO optimization
PdB = 0:5:60;

RValues = zeros(1, numel(PdB));
CRLBValues = zeros(1, numel(PdB));
GValues = zeros(1, numel(PdB));

for j = 1:numel(PdB)

    [meanR, meanCRLB, objValue, G] = MonteCarloSimulation(db2pow(PdB(j)), simParams);
    RValues(1, j) = meanR;
    CRLBValues(1, j) = meanCRLB;
    GValues(1, j) = G;
end

%% Defining Signal-to-noise-ratio
% channel parameters
c = 3e8;    % wave propagation speed
lambda = c/simParams.fc; % wave length
dBR = norm(simParams.r - simParams.b);   % BR distance
dRM = norm(simParams.m - simParams.r);  % RIS and MS distance
rhoBR = lambda/(4*pi*dBR); % free space loss BR
rhoRM = lambda/(4*pi*dRM);   % free space loss RIS-MS
% Defining SNR
SNR = PdB + pow2db(rhoBR^2*rhoRM^2/simParams.N0);
Gain = pow2db(GValues) - SNR;

%% Evaluation of Random and Constant RIS phases
RValuesRandom = zeros(1, numel(PdB));
RValuesConstant = zeros(1, numel(PdB));

CRLBValuesRandom = zeros(1, numel(PdB));
CRLBValuesConstant = zeros(1, numel(PdB));


for j = 1:numel(PdB)
    [meanR, meanCRLB] = MonteCarloSimulationRandomPhase(db2pow(PdB(j)), simParams);
    RValuesRandom(j) = meanR;
    CRLBValuesRandom(j) = meanCRLB;
end

for j = 1:numel(PdB)
    [meanR, meanCRLB] = MonteCarloSimulationConstantPhase(db2pow(PdB(j)), simParams);
    RValuesConstant(j) = meanR;
    CRLBValuesConstant(j) = meanCRLB;
end

%% Plots
figure ();
semilogy(PdB, CRLBValuesRandom, "r--", LineWidth=1.5);
hold on;
semilogy(PdB, CRLBValuesConstant, "g-.", LineWidth=1.5);
semilogy(SNR, CRLBValues, LineWidth=1.5)
xlabel("SNR [dB]", Interpreter="latex");
ylabel("PEB [m]", Interpreter="latex");
legend(["Random phase", "Constant phase", "PSO"]);
title("CRLB for Single User RIS-aided Integrated Sensing and Communication System")
grid("on");

figure();
plot(PdB, RValuesRandom, "r--", LineWidth=1.5);
hold on;
plot(PdB, RValuesConstant, "g-.", LineWidth=1.5);
semilogy(SNR, RValues, LineWidth=1.5);
xlabel("SNR [dB]", Interpreter="latex");
ylabel("Achievabe Rate [bits/Hz/s]", Interpreter="latex");
legend(["Random phase", "Constant phase", "PSO"]);
title("Achievable Rate for Single User RIS-aided Integrated Sensing and Communication System")
grid("minor");

figure();
plot(SNR, Gain);
xlabel("SNR [dB]", Interpreter="latex");
ylabel("PEB [m]", Interpreter="latex");
title("Gain Due to the Usage of RIS");
