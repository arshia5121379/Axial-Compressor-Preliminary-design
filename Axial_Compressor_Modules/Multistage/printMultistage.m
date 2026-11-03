function printMultistage(ms, inp)

    S = ms.stage;  O = ms.overall;  P = ms.plan;  H = ms.history;

    fprintf('\n============================================================\n');
    fprintf('  MULTISTAGE AXIAL COMPRESSOR\n');
    fprintf('============================================================\n');
    fprintf('  Stage-1 pitchline total temperature rise = %.2f K\n', ms.stage1_dT);
    fprintf('  Compressor total temperature rise (plan) = %.2f K\n', P.dT_comp);
    fprintf('  Stages needed at stage-1 rise            = %.2f\n', ms.stage1_exact);
    fprintf('  Selected number of stages z              = %d\n', ms.z);
    fprintf('  Planned equal rise per stage             = %.2f K\n', P.dT_stage);

    fprintf('\n  "New values n and/or z ?" loop (target PR = %.3f, tol = %.2f %%)\n', H.PR_target, 100*H.tol);
    fprintf('  %5s %4s %10s %10s %10s %10s %9s\n', 'pass', 'z', 'Utip(m/s)', 'n(rpm)', 'PR', 'error %', 'eta_p');
    for k = 1:numel(H.iter)
        fprintf('  %5d %4d %10.2f %10.1f %10.4f %10.3f %9.4f\n', ...
            H.iter(k), H.z(k), H.Utip(k), H.rpm(k), H.PR(k), 100*H.err(k), H.eta_p(k));
    end
    if H.converged, fprintf('  Result: ACCEPTED (n and z unchanged -> Stop)\n');
    else,           fprintf('  Result: NOT within tolerance (last pass retained)\n'); end

    fprintf('\n  Stage-by-stage results\n');
    fprintf('  %3s %8s %9s %7s %7s %7s %7s %7s %7s %6s %6s %6s %6s %6s %6s %5s\n', ...
        'i', 'Tt_in', 'pt_in', 'PRplan', 'PR', 'dTt', 'eta_p', 'rh(m)', 'h(mm)', 'Um', ...
        'phi', 'psi', 'R', 'Mr1', 'DFr', 'Nrot');
    for i = 1:numel(S)
        s = S(i);
        fprintf('  %3d %8.2f %9.2f %7.4f %7.4f %7.2f %7.4f %7.4f %7.1f %6.1f %6.3f %6.3f %6.3f %6.3f %6.3f %5d\n', ...
            s.i, s.Tt_in, s.pt_in/1e3, s.PR_plan, s.PR, s.dTt, s.eta_p, s.rh, 1e3*s.h, s.Um, ...
            s.phi, s.psi, s.R, s.Mr1, s.DF_rotor, s.Nrotor);
    end
    fprintf('  (Tt in K, pt in kPa, Um in m/s)\n');

    fprintf('\n  FINAL COMPRESSOR DATA\n');
    fprintf('  Number of stages               = %d\n',      ms.z);
    fprintf('  Shaft speed                    = %.1f rpm\n', O.rpm);
    fprintf('  Tip speed (all stages)         = %.2f m/s\n', O.Utip);
    fprintf('  Max hub speed                  = %.2f m/s\n', O.Uh_max);
    fprintf('  Overall total pressure ratio   = %.4f  (target %.4f)\n', O.PR, inp.op.PR);
    fprintf('  Overall total temp. ratio      = %.4f\n',    O.TR);
    fprintf('  Exit total temperature         = %.2f K\n',  O.Tt_out);
    fprintf('  Exit total pressure            = %.2f kPa\n', O.pt_out/1e3);
    fprintf('  Total temperature rise         = %.2f K\n',  O.dTt);
    fprintf('  Overall polytropic efficiency  = %.4f\n',    O.eta_p);
    fprintf('  Overall isentropic (tt) eff.   = %.4f\n',    O.eta_is);
    fprintf('  Specific work (REFPROP dh_t)   = %.2f kJ/kg\n', O.w/1e3);
    fprintf('  Sum of stage Euler work        = %.2f kJ/kg\n', O.work_euler/1e3);
    fprintf('  Shaft power                    = %.3f MW\n', O.power/1e6);
    fprintf('  Inlet  hub / tip radius        = %.4f / %.4f m\n', S(1).rh, ms.rt);
    fprintf('  Exit   hub / tip radius        = %.4f / %.4f m  (exit Mz = %.3f)\n', O.exit.rh, ms.rt, O.exit.Mz);
    fprintf('  Exit blade height              = %.2f mm\n', 1e3*O.exit.h);
    fprintf('  Total rotor blades             = %d\n',      O.Nrotor_total);
    fprintf('  Stage PR range                 = %.4f (stage 1) ... %.4f (stage %d)\n', S(1).PR, S(end).PR, ms.z);
    fprintf('============================================================\n');
end

%% ------------------------------------------------------------
%  FIGURE: STAGE PRESSURE RATIO vs STAGE NUMBER
% -------------------------------------------------------------
