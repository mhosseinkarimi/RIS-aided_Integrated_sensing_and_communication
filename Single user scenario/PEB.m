% Cramer-Rao Lower Bound
function CRLB = PEB(Phi, P, simParams)
    % PRS is assumed to be: x[n] = 1
    x = 1;

    % initialization
    c = 3e8; % wave propagation speed
    N = simParams.N;    % number of OFDM subcarriers
    W = simParams.W;    % bandwidth
    b = simParams.b; % BS position
    r = simParams.r; % RIS position
    m = simParams.m; % MS position
    NR = simParams.NR; % Number of RIS elements
    NB = simParams.NB; % Number of BS antenna

    lambda = c/simParams.fc;  % wavelength
    [HBR, hRM, f] = GenerateSystemModel(simParams);
    tauRM = norm(m - r)/c; % ToA at MS
    dBR = norm(r - b);   % BR distance
    thetaBR = acos((r(1)-b(1))/dBR); % AoD at BS
    phiBR = -pi + thetaBR;  % AoA at RIS
    tauBR = dBR/c; % ToA at RIS
    rhoBR = lambda/(4*pi*dBR); % free space loss BR
    dRM = norm(m - r);  % RIS and MS distance
    thetaRM = -acos((m(1)-r(1))/dRM);    % AoD at RIS
    tauRM = dRM/c;   % ToA at MS
    rhoRM = lambda/(4*pi*dRM);   % free space loss RIS-MS

    % FIM for estimation of [tauRM, thetaRM]
    J_eta = zeros(2, 2, N); % FIM for eta = [tauRM, thetaRM]
    for n = 1:N
        mu = sqrt(P)*hRM(:,:,n)*Phi*HBR(:,:,n)*f*x;
        dmu_dtauRM = -mu*(1/tauRM + 1i*2*pi*n*W/N);
        g = -1i*2*pi*(0:(NR-1))*(lambda/2)/lambda * cos(thetaRM);
        dmu_dthetaRM = sqrt(P)*rhoBR*rhoRM*(g.*ctranspose(antennaSteering(thetaRM, NR, lambda/2, lambda)))...
            *Phi*antennaSteering(phiBR, NR, lambda/2, lambda)*...
            ctranspose(antennaSteering(thetaBR, NB, lambda/2, lambda))*...
            exp(-1i*2*pi*n*W*(tauBR+tauRM)/N)*f*x;
        dmuH_dtauRM = ctranspose(dmu_dtauRM);
        dmuH_dthetaRM = ctranspose(dmu_dthetaRM);
        J_eta(1, 1, n) = dmuH_dtauRM*dmu_dtauRM;
        J_eta(1, 2, n) = dmuH_dtauRM*dmu_dthetaRM;
        J_eta(2, 1, n) = dmuH_dthetaRM*dmu_dtauRM;
        J_eta(2, 2, n) = dmuH_dthetaRM*dmu_dthetaRM;
    end

    % Jacobian Matrix
    T = zeros(2, 2);
    T(1, 1) = cos(thetaRM)/c;
    T(1, 2) = sin(thetaRM)/c;
    T(2, 1) = sin(thetaRM)/norm(m-r);
    T(2, 2) = -cos(thetaRM)/norm(m-r);
    
    % FIM for position estimation [mx, my]
    J_m = zeros(2, 2, N); % FIM for m = [mx, my]
    for n = 1:N
        J_m(:, :, n) = T*J_eta(:, :, n)*transpose(T);
    end
    
    % sum over all subcarriers
    J_tilde = sum(J_m, 3);
    
    CRLB = (trace(pinv(J_tilde)));
end
