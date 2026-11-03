function printLossResults(L)

    fprintf('\n============================================================\n');
    fprintf('  STAGE LOSSES & EFFICIENCY  (%s, REFPROP %s)\n', L.source, L.fluid);
    fprintf('============================================================\n');

    fprintf('\n  Thermodynamic states\n');
    fprintf('  %-16s %8s %10s %10s %8s %10s %10s %8s %7s\n', ...
            'station', 'T(K)', 'p(kPa)', 'pt(kPa)', 'rho', 'h(kJ/kg)', 's(J/kgK)', 'cp', 'gamma');
    for k = 1:3
        s = L.st(k);
        fprintf('  %-16s %8.2f %10.2f %10.2f %8.3f %10.2f %10.2f %8.1f %7.4f\n', ...
                s.name, s.T, s.p/1e3, s.pt/1e3, s.rho, s.h/1e3, s.s, s.cp, s.gamma);
    end
    fprintf('  Rotor relative total p: p1tr = %.2f kPa -> p2tr = %.2f kPa\n', L.p.p1tr/1e3, L.p.p2tr/1e3);
    fprintf('  Blade height [m]: hB1 = %.4f, hB2 = %.4f, hB3 = %.4f\n', L.hB);
    fprintf('  Specific work = %.2f kJ/kg\n', L.work/1e3);

    fprintf('\n  Pressure-loss coefficients\n');
    fprintf('  %-22s %10s %10s\n', '', 'rotor', 'stator');
    names = {'Profile Y_p', 'Secondary Y_s', 'End wall Y_EW', 'Shock Y_shock', 'Tip clearance Y_TC', 'TOTAL Y'};
    flds  = {'p', 's', 'ew', 'shock', 'tc', 'tot'};
    for k = 1:numel(flds)
        fprintf('  %-22s %10.5f %10.5f\n', names{k}, L.rotor.(flds{k}), L.stator.(flds{k}));
    end

    fprintf('\n  Diagnostics         %10s %10s\n', 'rotor', 'stator');
    d = {'DF_eq', 'DFeq'; 'Gamma', 'Gam'; 'c_L', 'cL'; 'A*_throat', 'Astar'; 'theta2/C', 'thC'; ...
         'H_TE', 'HTE'; 'Inlet Mach', 'Ma1'; 'Re (chord)', 'Re1'};
    for k = 1:size(d, 1)
        fprintf('  %-18s %10.4g %10.4g\n', d{k,1}, L.rotor.(d{k,2}), L.stator.(d{k,2}));
    end

    fprintf('\n  Efficiencies\n');
    fprintf('  Rotor            eta_R  = %.4f\n', L.eta.R);
    fprintf('  Stage total-total eta_TT = %.4f\n', L.eta.TT);
    fprintf('  Stage static      eta_is = %.4f\n', L.eta.is);
    fprintf('  Stage total-static eta_TS = %.4f\n', L.eta.TS);
    fprintf('  Stage PR (total) = %.4f   PR (total-static) = %.4f\n', L.PR_tt, L.PR_ts);
end

%% ############################################################
%            MULTISTAGE COMPRESSOR MODULE
%   Constant axial velocity Cz, constant tip radius and constant shaft
%   speed n (repeating-stage assumption).  Every stage is a complete run
%   of the single-stage chain (iterateStageEfficiency) at its own inlet
%   p/T and its own annulus (continuity at fixed r_tip).
% ############################################################

%% ------------------------------------------------------------
%  STAGE PRESSURE RATIOS FROM EQUAL TOTAL-TEMPERATURE RISE
%  dTt_stage = dTt_compressor / z ,  pi_s,i = (1 + dTt/Tt_in,i)^(eta_p*g/(g-1))
%  prod(pi_s,i) = PR exactly.
% -------------------------------------------------------------
