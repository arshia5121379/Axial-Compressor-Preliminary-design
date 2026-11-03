function rho = isentropicDensity(gas, op, Pt, Tt, Csq)
    T   = Tt - Csq/(2*op.cp);
    rho = Pt./(gas.R*Tt).*(T/Tt).^(1/(op.gamma-1));
end

%% ------------------------------------------------------------
%  ONE STATION: VELOCITIES, ANGLES, THERMODYNAMICS ALONG RADIUS
% -------------------------------------------------------------
