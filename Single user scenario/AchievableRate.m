% Acheivable Rate
function R = AchievableRate(Phi, P, simParams)
    N = simParams.N; % number of OFDM subcarriers
    N0 = simParams.N0; % noise power
    [H_BR, h_RM, f] = GenerateSystemModel(simParams);
    
    R = 0;
    for n = 1:N
        h = h_RM(:, :, n)*Phi*H_BR(:, :, n);
        R = R + log2(1 + P/N0 * abs(h*f)^2);
%         R = R + P/N0 * abs(h*f)^2;
    end
