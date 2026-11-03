function re = computeReynolds(inp, stage, inlet)

    re.rho16     = inp.re.rho_ratio_16km*inlet.rho;
    re.Re_chord  = stage.W1*inp.rotor.chord/inp.re.nu16;
    re.chord_min = inp.re.Re_min*inp.re.nu16/stage.W1;
end

%% ------------------------------------------------------------
%  NUMBER OF STAGES
% -------------------------------------------------------------
