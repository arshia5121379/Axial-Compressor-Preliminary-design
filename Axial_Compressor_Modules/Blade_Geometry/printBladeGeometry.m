function printBladeGeometry(rows)

    fprintf('\n============================================\n');
    fprintf('   BLADE GEOMETRY (spanwise sections)\n');
    fprintf('============================================\n');
    for nm = {'rotor', 'stator'}
        S = rows.(nm{1});
        F = @(f) cellfun(@(s) s.(f), S);
        fprintf('\n--- %s: %s, %s camberline ---\n', upper(nm{1}), S{1}.profile, S{1}.camberline);
        fprintf('  %-28s%s\n', 'span (0 = hub, 1 = tip)', sprintf('%10.2f', F('span')));
        pr('Radius (m)',              '%10.4f', F('r'));
        pr('Inlet flow angle (deg)',  '%10.2f', F('flow_in'));
        pr('Outlet flow angle (deg)', '%10.2f', F('flow_out'));
        pr('LE blade angle kappa1',   '%10.2f', F('kappa1'));
        pr('TE blade angle kappa2',   '%10.2f', F('kappa2'));
        pr('Incidence i (deg)',       '%10.2f', F('incidence'));
        pr('Deviation (deg)',         '%10.2f', F('deviation'));
        pr('Camber theta (deg)',      '%10.2f', F('theta'));
        pr('chi1 (deg)',              '%10.2f', F('chi1'));
        pr('chi2 (deg)',              '%10.2f', F('chi2'));
        pr('Stagger gamma (deg)',     '%10.2f', F('stagger'));
        pr('Equivalent Cl0',          '%10.3f', F('Cl0'));
        pr('Equivalent radius Rc (m)','%10.4f', F('Rc'));
        pr('Chord (m)',               '%10.4f', F('chord'));
        pr('Pitch (m)',               '%10.4f', F('pitch'));
        pr('Solidity',                '%10.3f', F('sigma'));
        pr('Max thickness (mm)',      '%10.2f', 1e3*F('tmax'));
        pr('Max thickness at x/c',    '%10.3f', F('xtmax_c'));
        % Report leading-edge coordinates in the assembled axial-radial
        % machine frame, not the local section frame (where makeSection
        % intentionally stores every LE at [0;0]).
        xLE = zeros(1,numel(S));
        yLE = F('r');
        if strcmp(nm{1},'stator')
            Rrows = rows.rotor;
            for kk = 1:numel(S)
                R = Rrows{kk};
                % Match the stator placement used in plotStageBB: the
                % stator LE follows the rotor TE with a half-chord gap.
                xLE(kk) = max([R.up(1,:) R.lo(1,:)]) + 0.5*R.chord;
            end
        end
        TE = cell2mat(cellfun(@(s) s.TE, S, 'UniformOutput', false));
        pr('LE axial x (m)',           '%10.4f', xLE);
        pr('LE radial y (m)',          '%10.4f', yLE);
        pr('TE axial x (local, m)',    '%10.4f', TE(1,:));
        pr('TE tangential y (local, m)','%10.4f', TE(2,:));
        if strcmp(S{1}.profile, 'A4K6')
            A = cell2mat(cellfun(@(s) s.theta_A4K6(:), S, 'UniformOutput', false));
            pr('A4K6 theta exact (deg)',  '%10.2f', A(1,:));
            pr('A4K6 theta approx (deg)', '%10.2f', A(2,:));
        end
    end
    fprintf('\n============================================\n');
end

%% ------------------------------------------------------------
%  BLADE-TO-BLADE FIGURES  (rotor and stator, one subplot per section)
% -------------------------------------------------------------
