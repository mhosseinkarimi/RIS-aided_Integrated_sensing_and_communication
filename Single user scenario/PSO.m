% PSO Optimization

function [x, fval, exitflag, output] = PSO(P, simParams)
    % PSO initialization
    nvars = simParams.NR;    % number of variables
    lb = zeros(1, nvars);    % lower bound for variables
    ub = 2*pi*ones(1, nvars);% upper bound for variables
    options = optimoptions("particleswarm", "MaxIterations", simParams.PSOIter, ...
        "SwarmSize", simParams.SwarmSize, "FunctionTolerance", ...
        simParams.PSOTol, "MaxStallIterations", 20, "UseParallel", true);   % pso options

    % multi-objective problem formulation
    alpha = simParams.commCoeff;   % communiaction objective coeffitient
    beta = simParams.locCoeff;  % localization objective coeffitien
    ObjFunc = @(phi) -alpha*AchievableRate(diag(exp(1i*phi)), P, simParams) + beta*PEB(diag(exp(1i*phi)), P, simParams);

    % running PSO
    [x, fval, exitflag, output] = particleswarm(ObjFunc, nvars,lb, ub, options);
end