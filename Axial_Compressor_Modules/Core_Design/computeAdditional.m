function ex = computeAdditional(inp, gas, inlet, stage) %#ok<INUSL>

    ex.phi         = inp.inlet.Cz/stage.Um;
    ex.MT          = inp.rotor.Utip/inlet.a;
    ex.Wtip        = sqrt(inp.inlet.Cz^2 + inp.rotor.Utip^2);
    ex.M1r_tip     = ex.Wtip/inlet.a;
    ex.Uh          = stage.omega*inlet.rh;
    ex.AR          = inlet.h/inp.rotor.chord;
    ex.sigma_stage = (inp.rotor.sigma + inp.stator.sigma)/2;
end

%% ------------------------------------------------------------
%  ROTOR CENTRIFUGAL STRESS (BLADE ROOT)   Eqs. 8.201 - 8.206
% -------------------------------------------------------------
