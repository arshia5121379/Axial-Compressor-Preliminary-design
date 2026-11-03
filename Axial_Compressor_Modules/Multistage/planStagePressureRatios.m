function plan = planStagePressureRatios(inp, z, eta_p)

    g      = inp.op.gamma;
    Tt1    = inp.op.Tt1;
    dTcomp = Tt1*(inp.op.PR^((g-1)/(eta_p*g)) - 1);
    dT     = dTcomp/z;
    k      = (1:z).';

    plan.z        = z;
    plan.eta_p    = eta_p;
    plan.dT_comp  = dTcomp;
    plan.dT_stage = dT;
    plan.Tt_in    = Tt1 + (k-1)*dT;
    plan.Tt_out   = plan.Tt_in + dT;
    plan.PR_s     = (plan.Tt_out./plan.Tt_in).^(eta_p*g/(g-1));
    plan.PR_cum   = cumprod(plan.PR_s);
end

%% ------------------------------------------------------------
%  ANNULUS AT A STATION (perfect gas, constant Cz, fixed tip radius)
% -------------------------------------------------------------
