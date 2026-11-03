function S = rpState(rp, k1, v1, k2, v2)

    if strcmp(k1, 'P'), v1 = v1*rp.Pscale; end
    if strcmp(k2, 'P'), v2 = v2*rp.Pscale; end

    [T, P, D, H, Sx, Cp, Cv, A, V] = refpropm('TPDHSCOAV', k1, v1, k2, v2, rp.fluid);

    S.T = T;      S.P = P/rp.Pscale;  S.rho = D;
    S.h = H;      S.s = Sx;
    S.cp = Cp;    S.cv = Cv;          S.gamma = Cp/Cv;
    S.a = A;      S.mu = V;
end

%% ------------------------------------------------------------
%  KINEMATICS AT MEAN-LINE OR MID-SPAN
%  ang = relative angle (rotor) / absolute angle (stator), deg
% -------------------------------------------------------------
