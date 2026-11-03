function [usq, v] = evalStation(M, x, a, b, um2, side)
    if side == 1
        v   = M.v1(x,a,b);
        usq = um2 - 2*M.I1(x,a,b);
    else
        v   = M.v2(x,a,b);
        usq = um2 - 2*M.I2(x,a,b);
    end
end

%% ------------------------------------------------------------
%  ISENTROPIC DENSITY (constant Pt, Tt along radius)
% -------------------------------------------------------------
