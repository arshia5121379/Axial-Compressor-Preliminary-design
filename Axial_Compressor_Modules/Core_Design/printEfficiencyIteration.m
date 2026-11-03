function printEfficiencyIteration(H, eta_final)

    fprintf('\n============================================================\n');
    fprintf('  STAGE POLYTROPIC-EFFICIENCY ITERATION\n');
    fprintf('============================================================\n');
    fprintf('  Lozza starting eta_p = %.6f\n', H.eta_initial);
    fprintf('  Size parameter SP    = %.6g\n', H.SP);
    fprintf('  Inlet volume flow    = %.5f m^3/s\n', H.Vin);
    fprintf('  Isentropic stage dh  = %.3f kJ/kg\n', H.dh_is_stage/1e3);
    fprintf('  Convergence tolerance = %.2e\n', H.tolerance);
    fprintf('  Under-relaxation     = %.2f\n', H.relaxation);
    fprintf('  Iterations           = %d / %d\n', numel(H.iteration), H.max_iter);
    fprintf('  Final eta_p          = %.6f\n', eta_final);
    if H.converged
        fprintf('  Convergence          = ACHIEVED\n');
    else
        fprintf('  Convergence          = NOT ACHIEVED (last iterate retained)\n');
    end

    fprintf('\n  %5s %12s %14s %12s\n', 'Iter', 'eta_p used', 'eta_p from loss', '|delta eta|');
    for k = 1:numel(H.iteration)
        fprintf('  %5d %12.6f %14.6f %12.3e\n', ...
            H.iteration(k), H.eta_used(k), H.eta_calculated(k), H.error(k));
    end
end

%% ------------------------------------------------------------
%  GAS PROPERTIES
% -------------------------------------------------------------
