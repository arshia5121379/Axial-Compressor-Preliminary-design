function stage = computeFirstStage(inp, gas, inlet) %#ok<INUSL>

    Cz = inp.inlet.Cz;

    % --- Rotation
    stage.Um    = inp.rotor.Utip*(inlet.rm/inlet.rt);
    stage.omega = inp.rotor.Utip/inlet.rt;
    stage.RPM   = stage.omega*60/(2*pi);

    % --- Rotor inlet triangle
    stage.alpha1 = 0;
    stage.beta1  = atand(stage.Um/Cz);
    stage.W1     = sqrt(Cz^2 + stage.Um^2);
    stage.Mr1    = stage.W1/inlet.a;

    % --- Rotor exit triangle (De Haller based)
    stage.W2      = inp.rotor.DH_target*stage.W1;
    stage.beta2   = acosd(Cz/stage.W2);
    stage.Wtheta2 = Cz*tand(stage.beta2);
    stage.Ctheta2 = stage.Um - stage.Wtheta2;
    stage.alpha2  = atand(stage.Ctheta2/Cz);
    stage.C2      = sqrt(Cz^2 + stage.Ctheta2^2);

    % --- Loading and reaction
    stage.psi      = stage.Ctheta2/stage.Um;
    stage.Reaction = 1 - stage.Ctheta2/(2*stage.Um);
end

%% ------------------------------------------------------------
%  DIFFUSION FACTORS + DE HALLER
% -------------------------------------------------------------
