function b3 = computeBlade3D(inp, blade, rad)

    rt = inp.rotor;

    b3.r       = rad.r;
    b3.span    = rad.span;
    b3.kappa1  = rad.st1.beta - rt.incidence;            % rotor LE metal angle
    b3.kappa2  = rad.st2.beta - rt.deviation;            % rotor TE metal angle
    b3.camber  = b3.kappa1 - b3.kappa2;
    b3.stagger = rad.st1.beta - b3.camber/2 - rt.incidence;   % same rule as mean-line
    b3.spacing = 2*pi*rad.r/blade.N;
    b3.sigma   = rt.chord./b3.spacing;                   % constant chord -> sigma ~ 1/r
    b3.tc      = rt.tc_hub + (rt.tc_tip - rt.tc_hub)*rad.span;
    b3.tmax    = b3.tc*rt.chord;

    b3.DH_rotor  = rad.st2.W./rad.st1.W;
    b3.DF_rotor  = 1 - b3.DH_rotor + abs(rad.st2.v - rad.st1.v)./(2*b3.sigma.*rad.st1.W);
    b3.DH_stator = rad.st3.C./rad.st2.C;
    b3.DF_stator = 1 - b3.DH_stator + abs(rad.st2.v - rad.st3.v)./(2*inp.stator.sigma_D*rad.st2.C);
end

%% ------------------------------------------------------------
%  AUTOMATIC PHYSICAL VALIDATION
% -------------------------------------------------------------
