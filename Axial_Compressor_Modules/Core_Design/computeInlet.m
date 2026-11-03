function inlet = computeInlet(op, gas, inI)

    g = op.gamma;
    f = 1 + (g-1)*inI.Mz1^2/2;

    inlet.T   = op.Tt1/f;                          % Static temperature
    inlet.a   = sqrt((g-1)*op.cp*inlet.T);         % Speed of sound
    inlet.Cz  = inI.Mz1*inlet.a;                   % Axial velocity
    inlet.P   = op.Pt1/f^(g/(g-1));                % Static pressure
    inlet.rho = inlet.P/(gas.R*inlet.T);           % Density
    inlet.A   = op.mdot/(inlet.rho*inlet.Cz);      % Flow area

    inlet.rt  = sqrt(inlet.A/(pi*(1-inI.rh_rt^2)));% Tip radius
    inlet.rh  = inI.rh_rt*inlet.rt;                % Hub radius
    inlet.rm  = (inlet.rt+inlet.rh)/2;             % Pitchline radius
    inlet.h   = inlet.rt-inlet.rh;                 % Blade height
end

%% ------------------------------------------------------------
%  COMPRESSOR EXIT CONDITIONS + ANNULUS GEOMETRY
% -------------------------------------------------------------
