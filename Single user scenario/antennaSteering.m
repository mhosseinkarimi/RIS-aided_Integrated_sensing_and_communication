function a = antennaSteering(theta, N, delta, lambda)
    a = zeros(N, 1);
    for n = 1:N
        a(n) = exp(1i*2*pi*(n-1)*delta*sin(theta)/lambda);
    end
end