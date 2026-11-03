function [inp, calc, hist] = iterateStageEfficiency(inp, geo)

    cfg = inp.eff_iter;

    % First preliminary pass: obtain inlet state and an estimate of the
    % number of stages / per-stage pressure ratio for the Lozza size factor.
    prelim = evaluateStageOnce(inp, geo);
    [eta0, SP0, dhis0, Vin0] = lozzaInitialEfficiency(inp, prelim);

    eta = eta0;
    hist.iteration = [];
    hist.eta_used = [];
    hist.eta_calculated = [];
    hist.error = [];
    hist.relaxed_eta = [];

    converged = false;

    for it = 1:cfg.max_iter
        inp.op.eta_p = eta;

        % Recalculate the complete chain for the current assumed efficiency.
        q = evaluateStageOnce(inp, geo);

        % Convert the loss-based stage total-total result to polytropic
        % efficiency using the total pressure and total-temperature ratios.
        eta_loss = polytropicEfficiencyFromLoss(q.loss);

        err = abs(eta_loss - eta);
        eta_next = eta + cfg.relaxation*(eta_loss - eta);

        hist.iteration(end+1,1) = it;
        hist.eta_used(end+1,1) = eta;
        hist.eta_calculated(end+1,1) = eta_loss;
        hist.error(end+1,1) = err;
        hist.relaxed_eta(end+1,1) = eta_next;

        if ~isfinite(eta_loss) || eta_loss <= 0 || eta_loss >= 1
            error('Stage efficiency iteration produced a non-physical eta_p = %.6f. Check loss correlations and REFPROP states.', eta_loss);
        end

        if err < cfg.tol
            eta = eta_loss;
            converged = true;
            break;
        end

        eta = eta_next;
    end

    if ~converged
        warning('StageEfficiency:NoConvergence', ...
            'Stage efficiency did not converge in %d iterations (last |deta_p| = %.3e).', ...
            cfg.max_iter, hist.error(end));
    end

    % Final evaluation with the accepted efficiency so every reported
    % quantity corresponds to the same final eta_p.
    inp.op.eta_p = eta;
    calc = evaluateStageOnce(inp, geo);

    hist.eta_initial = eta0;
    hist.SP = SP0;
    hist.dh_is_stage = dhis0;
    hist.Vin = Vin0;
    hist.eta_final = eta;
    hist.converged = converged;
    hist.tolerance = cfg.tol;
    hist.max_iter = cfg.max_iter;
    hist.relaxation = cfg.relaxation;
end

%% ------------------------------------------------------------
%  ONE COMPLETE EVALUATION AT THE CURRENT eta_p
% -------------------------------------------------------------
