function [H_BR, h_RM, f] = GenerateSystemModel(simParams)
   % initialization
   c = 3e8; % wave propagation speed
   lambda = c/simParams.fc; % wavelength
   W = simParams.W; % bandwidth
   N = simParams.N; % Number of OFDM subcarriers
   NB = simParams.NB; % number of antennas in BS
   NR = simParams.NR; % number of RIS elements
   b = simParams.b; % BS position
   r = simParams.r; % RIS position
   m = simParams.m; % MS position

   % BS -> RIS channel
   dBR = norm(r - b);   % BR distance
   thetaBR = acos((r(1)-b(1))/dBR); % AoD at BS
   phiBR = -pi + thetaBR;  % AoA at RIS
   tauBR = dBR/c; % ToA at RIS
   rhoBR = lambda/(4*pi*dBR); % free space loss BR
   H_BR = zeros(NR, NB, N);
   for n = 1:N
       H_BR(:, :, n) = rhoBR*exp(-1i*2*pi*tauBR*n*W/N)*...
           antennaSteering(phiBR, NR, lambda/2, lambda)*...
           ctranspose(antennaSteering(thetaBR, NB, lambda/2, lambda));
   end

   % RIS -> MS channel
   dRM = norm(m - r);  % RIS and MS distance
   thetaRM = -acos((m(1)-r(1))/dRM);    % AoD at RIS
   tauRM = dRM/c;   % ToA at MS
   rhoRM = lambda/(4*pi*dRM);   % free space loss RIS-MS
   h_RM = zeros(1, NR, N);
   for n = 1:N
       h_RM(:, :, n) = rhoRM*ctranspose(antennaSteering(thetaRM, NR, lambda/2, lambda))*...
           exp(-1i*2*pi*tauRM*n*W/N);
   end

   % Precoding 
   f = 1/sqrt(NB) * antennaSteering(thetaBR, NB, lambda/2, lambda);
end