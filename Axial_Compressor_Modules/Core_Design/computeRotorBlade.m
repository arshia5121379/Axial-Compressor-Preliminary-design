function blade = computeRotorBlade(inp, stage, inlet)

    r = inp.rotor;

    blade.tc_mean = (r.tc_hub + r.tc_tip)/2;
    blade.tmax    = blade.tc_mean*r.chord;
    blade.rLE     = 0.05*blade.tmax;

    blade.kappa1  = stage.beta1 - r.incidence;
    blade.kappa2  = stage.beta2 - r.deviation;
    blade.camber  = blade.kappa1 - blade.kappa2;
    blade.stagger = stage.beta1 - blade.camber/2 - r.incidence;

    blade.spacing = r.chord/r.sigma;
    blade.N       = round(2*pi*inlet.rm/blade.spacing);
end

%% ------------------------------------------------------------
%  STATOR CONDITIONS
% -------------------------------------------------------------
