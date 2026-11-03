function ms = designMultistageCompressor(inp, geo, calc)

    cfg  = inp.multi;
    rt   = calc.inlet.rt;
    z    = calc.nst.N;                  % from the stage-1 temperature-rise count
    Utip = inp.rotor.Utip;
    PRt  = inp.op.PR;
    eta_plan = inp.op.eta_p;
    adj  = lower(cfg.adjust);
    zLocked = any(strcmp(adj, {'n', 'none'}));
    Uprev = [];  fprev = [];
    converged = false;

    H = struct('iter', [], 'z', [], 'Utip', [], 'rpm', [], 'PR', [], 'err', [], 'eta_p', []);

    for k = 1:cfg.max_outer
        base = inp;
        base.rotor.Utip = Utip;
        plan = planStagePressureRatios(base, z, eta_plan);
        ms   = marchStages(base, geo, plan, rt);

        err = ms.overall.PR/PRt - 1;
        H.iter(end+1,1) = k;            H.z(end+1,1)    = z;
        H.Utip(end+1,1) = Utip;         H.rpm(end+1,1)  = ms.overall.rpm;
        H.PR(end+1,1)   = ms.overall.PR; H.err(end+1,1) = err;
        H.eta_p(end+1,1) = ms.overall.eta_p;
        eta_plan = ms.overall.eta_p;

        if abs(err) <= cfg.PR_tol
            converged = true;  break;
        end
        if strcmp(adj, 'none'), break; end

        % ---- new z ?   (nearest whole number of stages at the present speed)
        lnRatio = log(PRt)/log(ms.overall.PR);
        if ~zLocked
            zNew    = max(1, round(z*lnRatio));
            zLocked = true;
            if zNew ~= z
                z = zNew;  Uprev = [];  fprev = [];
                continue;
            end
        end
        if strcmp(adj, 'z'), break; end

        % ---- new n ?   (secant on ln(PR) vs Utip; first step: dT ~ U^2)
        f = log(ms.overall.PR) - log(PRt);
        if isempty(Uprev) || abs(f - fprev) < 1e-12
            Unew = Utip*lnRatio^(0.5*cfg.relax_n);
        else
            Unew = Utip - cfg.relax_n*f*(Utip - Uprev)/(f - fprev);
        end
        Unew = Utip*min(max(Unew/Utip, 0.9), 1.1);                     % max +-10 % per pass
        Unew = min(max(Unew, cfg.Utip_limits(1)), cfg.Utip_limits(2)); % speed limits
        if abs(Unew - Utip) < 1e-6
            warning('Multistage:SpeedLimit', ...
                'Tip speed limit reached (Utip = %.1f m/s); PR target not met.', Utip);
            break;
        end
        Uprev = Utip;  fprev = f;  Utip = Unew;
    end

    if ~converged
        warning('Multistage:NoConv', ...
            'Overall PR = %.3f vs target %.3f (|error| = %.2f %%) after %d pass(es).', ...
            ms.overall.PR, PRt, 100*abs(err), numel(H.iter));
    end

    H.converged = converged;
    H.PR_target = PRt;
    H.tol       = cfg.PR_tol;
    ms.history  = H;
    ms.converged = converged;
    ms.stage1_dT    = calc.nst.dT_stage;       % first-stage pitchline dTt
    ms.stage1_exact = calc.nst.exact;          % dTt_comp / dTt_stage (not rounded)
end

%% ------------------------------------------------------------
%  PRINT FINAL COMPRESSOR DATA
% -------------------------------------------------------------
