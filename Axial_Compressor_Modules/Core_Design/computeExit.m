function exitc = computeExit(op, gas, inI, inlet)

    g = op.gamma;

    exitc.Pt  = op.PR*op.Pt1;
    exitc.tau = op.PR^((g-1)/(op.eta_p*g));
    exitc.Tt  = op.Tt1*exitc.tau;

    exitc.T   = exitc.Tt - inI.Cz^2/(2*op.cp);
    exitc.a   = sqrt((g-1)*op.cp*exitc.T);
    exitc.M   = inI.Cz/exitc.a;
    exitc.P   = exitc.Pt/(1+(g-1)*exitc.M^2/2)^(g/(g-1));
    exitc.rho = exitc.P/(gas.R*exitc.T);
    exitc.A   = op.mdot/(exitc.rho*inI.Cz);

    % Constant tip radius assumption
    exitc.rt  = inlet.rt;
    exitc.rh  = sqrt(exitc.rt^2 - exitc.A/pi);
    exitc.rm  = (exitc.rt+exitc.rh)/2;
    exitc.h   = exitc.rt-exitc.rh;
end

%% ------------------------------------------------------------
%  FIRST STAGE: PITCHLINE + ROTOR VELOCITY TRIANGLES
% -------------------------------------------------------------
