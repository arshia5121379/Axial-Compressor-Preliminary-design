function q = evaluateStageOnce(inp, geo)

    q.gas    = computeGasProperties(inp.op);
    q.inlet  = computeInlet(inp.op, q.gas, inp.inlet);
    q.exitc  = computeExit(inp.op, q.gas, inp.inlet, q.inlet);
    q.stage  = computeFirstStage(inp, q.gas, q.inlet);
    q.diffu  = computeDiffusion(inp, q.stage);
    q.blade  = computeRotorBlade(inp, q.stage, q.inlet);
    q.stator = computeStator(inp, q.gas, q.stage);
    q.reyn   = computeReynolds(inp, q.stage, q.inlet);
    q.nst    = computeStages(inp, q.exitc, q.stator);
    q.extra  = computeAdditional(inp, q.gas, q.inlet, q.stage);
    q.stress = computeRotorStress(inp, q.inlet, q.stage);

    q.radial  = solveRadialEquilibrium(inp, q.gas, q.inlet, q.stage, ...
                                       q.stator, inp.radial.swirl_model);
    q.blade3d = computeBlade3D(inp, q.blade, q.radial);
    q.check   = validateRadial(inp, q.radial, q.blade3d);

    q.loss = computeStageLosses(inp, geo, q.inlet, q.stage, ...
                                q.stator, q.blade, q.radial);
end

%% ------------------------------------------------------------
%  LOZZA (2016) STARTING POLYTROPIC EFFICIENCY
%  SP = sqrt(V_in) / (Delta h_is,stage)^(1/4)
% -------------------------------------------------------------
