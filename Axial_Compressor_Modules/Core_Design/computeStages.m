function nst = computeStages(inp, exitc, stator)

    nst.dT_stage = stator.Tt2 - inp.op.Tt1;
    nst.dT_comp  = exitc.Tt   - inp.op.Tt1;
    nst.exact    = nst.dT_comp/nst.dT_stage;
    nst.N        = ceil(nst.exact);
    nst.PR_stage = inp.op.PR^(1/nst.N);
end

%% ------------------------------------------------------------
%  ADDITIONAL DESIGN PARAMETERS
% -------------------------------------------------------------
