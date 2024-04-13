function penalty = Penalty(Phi, P, simParams)
    q = relativeViolatedFcn(Phi, P, simParams);
    penalty = multistageAssignment(q) * q^(powerOfPenalty(q));
end