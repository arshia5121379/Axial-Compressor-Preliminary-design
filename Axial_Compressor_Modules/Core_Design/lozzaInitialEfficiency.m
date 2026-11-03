function [eta0, SP, dh_is_stage, Vin] = lozzaInitialEfficiency(inp, q)

    rp = struct('fluid', inp.loss.fluid, 'Pscale', inp.loss.Pscale);

    % Per-stage isentropic enthalpy rise, using the preliminary stage count.
    Nstage = max(1, q.nst.N);
    if isfield(inp, 'stage_run') && inp.stage_run
        Nstage = 1;          % multistage march: inp.op.PR already is this stage's PR
    end
    PRstage = inp.op.PR^(1/Nstage);

    S1t = rpState(rp, 'T', inp.op.Tt1, 'P', inp.op.Pt1);
    S2is = rpState(rp, 'P', inp.op.Pt1*PRstage, 'S', S1t.s);
    dh_is_stage = S2is.h - S1t.h;

    % Inlet volumetric flow rate (m^3/s).
    Vin = inp.op.mdot/q.inlet.rho;

    if ~isfinite(dh_is_stage) || dh_is_stage <= 0 || ...
       ~isfinite(Vin) || Vin <= 0
        error('Cannot evaluate Lozza starting efficiency: invalid Vin or isentropic stage enthalpy rise.');
    end

    SP = sqrt(Vin)/(dh_is_stage^(1/4));

    if SP < 1
        eta0 = 0.915*(1 - 0.07108*(log10(SP))^2);
    else
        eta0 = 0.915;
    end

    if ~isfinite(eta0) || eta0 <= 0 || eta0 >= 1
        error('Lozza correlation returned a non-physical starting efficiency (eta_p,0 = %.6f, SP = %.6g).', eta0, SP);
    end

end

%% ------------------------------------------------------------
%  LOSS-BASED POLYTROPIC EFFICIENCY UPDATE
%  eta_p = ((gamma_bar-1)/gamma_bar)*ln(PR_tt)/ln(Tt3/Tt1)
% -------------------------------------------------------------
