function theta = multistageAssignment(q)
%     if q < 1
%         theta = 1;
%     elseif q < 10
%         theta = 20;
%     else
%         theta = 10*q;
%     end

    if q < 1e-6
        theta = 1;
    elseif q < 1e-3
        theta = 20;
    else
        theta = 1000;
    end
end
