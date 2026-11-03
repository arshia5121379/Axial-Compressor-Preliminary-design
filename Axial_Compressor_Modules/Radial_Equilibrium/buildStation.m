function s = buildStation(gas, op, Pt, Tt, usq, v, U)
    s.usq   = usq;
    s.u     = sqrt(max(usq,0));
    s.v     = v;
    s.C     = sqrt(s.u.^2 + v.^2);
    s.alpha = atan2d(v, s.u);               % absolute flow angle
    s.Wt    = U - v;                        % relative whirl
    s.W     = sqrt(s.u.^2 + s.Wt.^2);
    s.beta  = atan2d(s.Wt, s.u);            % relative flow angle
    s.T     = Tt - s.C.^2/(2*op.cp);
    s.rho   = isentropicDensity(gas, op, Pt, Tt, s.C.^2);
    s.a     = sqrt(op.gamma*gas.R*s.T);
    s.M     = s.C./s.a;
    s.Mrel  = s.W./s.a;
end

%% ------------------------------------------------------------
%  RADIAL EQUILIBRIUM SOLVER  (stations 1, 2, 3)
%  Mean-line results (rm, rh, rt, omega, Cz, work, R_m) are used as
%  reference and are NOT modified; only the radial redistribution
%  is computed.  Repeating stage: v3 = v1.
% -------------------------------------------------------------
