% Monte Carlo Simulations 
function [meanR, meanCRLB, meanObj, G] = MonteCarloSimulation(P, simParams)
    % Objective function values
    R = zeros(1, simParams.MonteCarloIter);
    CRLB = zeros(1, simParams.MonteCarloIter);
    ObjFcn = zeros(1, simParams.MonteCarloIter);
    G = zeros(1, simParams.MonteCarloIter);
    % Display
    if simParams.MonteCarloDisplayPhase == true
        phiRealization = zeros(simParams.MonteCarloIter, simParams.NR);
    end
    
    for k = 1:simParams.MonteCarloIter
        % PSO optimization
        [phi, fval, exitflag, output] = PSO(P, simParams);
        
%         [phi, fval, exitflag, output] = PSO(P, alpha(k), beta(k), simParams);
        % evaluate CRLB and AR
        [H_BR, h_RM, f] = GenerateSystemModel(simParams);
        gain = 0;
        for n = 1:simParams.N
            h = h_RM(:, :, n)*diag(exp(1i*phi))*H_BR(:, :, n);
            gain = gain + P/simParams.N0 * abs(h*f)^2;
        end
        G(k) = gain/simParams.N;
        R(k) = AchievableRate(diag(exp(1i*phi)), P, simParams);
        CRLB(k) = PEB(diag(exp(1i*phi)), P, simParams);
        ObjFcn(k) = fval;

        % Display
        if simParams.MonteCarloDisplayPhase == true
            phiRealization(k, :) = phi;
        end
    end

    % plot results
    if simParams.MonteCarloDisplayPhase == true
        % Phase distribution
        figure(1);
        boxplot(phiRealization, string(1:simParams.NR));
    end
    
    if simParams.MonteCarloDisplayObjFn == true
        % R and CRLB
        figure("Name", join(["P = ", num2str(pow2db(P))]));
        boxplot([real(R)', real(CRLB)'], ["Achievable Rate", "PEB"]);
        title(join(["Distribution of Objective Function Values, P = ", num2str(pow2db(P))]));
    end


    % extraction of the mean values
    meanR = mean(R);
    meanCRLB = mean(CRLB);
    meanObj = mean(ObjFcn);
end