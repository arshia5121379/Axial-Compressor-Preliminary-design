function d = computeDiffusion(inp, stage)

    d.C3 = inp.inlet.Cz;

    d.Dr = 1 - stage.W2/stage.W1 ...
           + abs(stage.Ctheta2)/(2*inp.rotor.sigma*stage.W1);

    d.Ds = 1 - d.C3/stage.C2 ...
           + abs(stage.Ctheta2)/(2*inp.stator.sigma_D*stage.C2);

    d.DH_rotor  = stage.W2/stage.W1;
    d.DH_stator = d.C3/stage.C2;
end

%% ------------------------------------------------------------
%  ROTOR BLADE DESIGN
% -------------------------------------------------------------
