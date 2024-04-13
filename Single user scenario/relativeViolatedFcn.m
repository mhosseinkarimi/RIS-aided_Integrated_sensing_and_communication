function q = relativeViolatedFcn(Phi, P, simParams)
    % calculation of optimal value
    i = 1:simParams.NR;
    lambda = 3e8/simParams.fc;
    delta = lambda/2;
    phi_BL = -pi + acos(((simParams.r(1) - simParams.b(1))/norm(simParams.r-simParams.b)));
    theta_LM = -acos(((simParams.m(1)-simParams.r(1))/norm(simParams.r-simParams.m)));
    phi_incremental = mod(2*pi*(i-1)*delta*(sin(theta_LM)-sin(phi_BL))/lambda, 2*pi);
    Phi_incremental = diag(exp(1i*phi_incremental));
% %     R_incremental = AchievableRate(Phi_incremental, P, simParams);
    CRLB_incremental = PEB(Phi_incremental, P, simParams);

    % constraint: 0.95*R_incremental - R < 0
%     constraint = 0.95*R_incremental - AchievableRate(Phi, P, simParams);
    
    constraint = PEB(Phi, P, simParams) - 1.05*CRLB_incremental;
    q = max([0, constraint]);
end

