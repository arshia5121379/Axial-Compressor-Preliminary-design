function radAll = compareSwirlModels(inp, gas, inlet, stage, stator, blade)

    names  = {'free_vortex', 'exponential', 'first_power'};
    radAll = cell(1,3);
    for k = 1:3
        rk = solveRadialEquilibrium(inp, gas, inlet, stage, stator, names{k});
        bk = computeBlade3D(inp, blade, rk);
        rk.blade3d = bk;
        rk.check   = validateRadial(inp, rk, bk);
        radAll{k}  = rk;
    end
end

%% ------------------------------------------------------------
%  PRINT RESULTS
% -------------------------------------------------------------
