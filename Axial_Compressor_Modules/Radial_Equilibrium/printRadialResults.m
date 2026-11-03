function printRadialResults(inp, stage, rad, b3, chk, radAll)

    sp = inp.radial.print_span;
    at = @(f) interp1(rad.span, f, sp, 'pchip');

    fprintf('\n============================================\n');
    fprintf('   RADIAL EQUILIBRIUM  (3D DESIGN, Sect. 9.3.7)\n');
    fprintf('============================================\n');
    fprintf('Swirl model             = %s (n = %d)\n', rad.model, rad.n);
    fprintf('Parameter a             = %.3f m/s\n', rad.a);
    fprintf('Parameter b             = %.3f m/s\n', rad.b);
    fprintf('Stage work (mean-line)  = %.3f kJ/kg\n', rad.dht/1e3);
    fprintf('Mean-radius reaction    = %.4f (from mean-line)\n', rad.Rcm);
    fprintf('Hub / mean / tip radius = %.4f / %.4f / %.4f m\n', rad.rh, rad.rm, rad.rt);
    fprintf('Mean-line Cz            = %.2f m/s\n', rad.um_ref);
    fprintf('Mean u at st 1/2/3      = %.2f / %.2f / %.2f m/s\n', rad.um);
    fprintf('Deviation from Cz       = %+.2f / %+.2f / %+.2f %%\n', 100*(rad.um/rad.um_ref - 1));
    if abs(stage.Reaction - inp.rotor.Rm_target) > 0.01
        fprintf('NOTE: mean-line reaction (%.3f) differs from Rm_target (%.2f);\n', ...
                stage.Reaction, inp.rotor.Rm_target);
        fprintf('      the De Haller choice sets it, and it is used as the reference.\n');
    end

    hdr = @(t) fprintf('\n--- %s ---\n', t);
    head = @() fprintf('  %-28s%s\n', 'span (0 = hub, 1 = tip)', sprintf('%10.2f', sp));

    % ---------------- ROTOR
    hdr('ROTOR BLADE (spanwise)');
    head();
    pr('Radius (m)',            '%10.4f', at(rad.r));
    pr('Blade speed U (m/s)',   '%10.2f', at(rad.U));
    fprintf('  INFLOW (station 1)\n');
    pr('Absolute angle alpha1 (deg)', '%10.2f', at(rad.st1.alpha));
    pr('Relative angle beta1 (deg)',  '%10.2f', at(rad.st1.beta));
    pr('Axial velocity u1 (m/s)',     '%10.2f', at(rad.st1.u));
    pr('Whirl velocity v1 (m/s)',     '%10.2f', at(rad.st1.v));
    pr('Absolute velocity C1 (m/s)',  '%10.2f', at(rad.st1.C));
    pr('Relative velocity W1 (m/s)',  '%10.2f', at(rad.st1.W));
    pr('Relative Mach M1r',           '%10.3f', at(rad.st1.Mrel));
    fprintf('  OUTFLOW (station 2)\n');
    pr('Absolute angle alpha2 (deg)', '%10.2f', at(rad.st2.alpha));
    pr('Relative angle beta2 (deg)',  '%10.2f', at(rad.st2.beta));
    pr('Axial velocity u2 (m/s)',     '%10.2f', at(rad.st2.u));
    pr('Whirl velocity v2 (m/s)',     '%10.2f', at(rad.st2.v));
    pr('Absolute velocity C2 (m/s)',  '%10.2f', at(rad.st2.C));
    pr('Relative velocity W2 (m/s)',  '%10.2f', at(rad.st2.W));
    fprintf('  PERFORMANCE\n');
    pr('Degree of reaction R',        '%10.3f', at(rad.R));
    pr('R (constant-u formula)',      '%10.3f', at(rad.R_cu));
    pr('Euler work (kJ/kg)',          '%10.3f', at(rad.work)/1e3);
    pr('De Haller W2/W1',             '%10.3f', at(b3.DH_rotor));
    pr('Diffusion factor',            '%10.3f', at(b3.DF_rotor));

    % ---------------- STATOR
    hdr('STATOR BLADE (spanwise)');
    head();
    fprintf('  INFLOW (station 2)\n');
    pr('Absolute angle alpha2 (deg)', '%10.2f', at(rad.st2.alpha));
    pr('Axial velocity u2 (m/s)',     '%10.2f', at(rad.st2.u));
    pr('Whirl velocity v2 (m/s)',     '%10.2f', at(rad.st2.v));
    pr('Absolute velocity C2 (m/s)',  '%10.2f', at(rad.st2.C));
    fprintf('  OUTFLOW (station 3)\n');
    pr('Absolute angle alpha3 (deg)', '%10.2f', at(rad.st3.alpha));
    pr('Axial velocity u3 (m/s)',     '%10.2f', at(rad.st3.u));
    pr('Whirl velocity v3 (m/s)',     '%10.2f', at(rad.st3.v));
    pr('Absolute velocity C3 (m/s)',  '%10.2f', at(rad.st3.C));
    fprintf('  PERFORMANCE\n');
    pr('Stage reaction R',            '%10.3f', at(rad.R));
    pr('Stator enthalpy share 1-R',   '%10.3f', 1 - at(rad.R));
    pr('De Haller C3/C2',             '%10.3f', at(b3.DH_stator));
    pr('Diffusion factor',            '%10.3f', at(b3.DF_stator));

    % ---------------- 3D ROTOR GEOMETRY
    hdr('ROTOR BLADE 3D GEOMETRY');
    head();
    pr('LE metal angle kappa1 (deg)', '%10.2f', at(b3.kappa1));
    pr('TE metal angle kappa2 (deg)', '%10.2f', at(b3.kappa2));
    pr('Camber angle (deg)',          '%10.2f', at(b3.camber));
    pr('Stagger angle (deg)',         '%10.2f', at(b3.stagger));
    pr('Solidity (constant chord)',   '%10.3f', at(b3.sigma));
    pr('Thickness/chord',             '%10.3f', at(b3.tc));
    pr('Max thickness (mm)',          '%10.2f', at(b3.tmax)*1e3);

    % ---------------- CHECKS
    hdr('VALIDATION CHECKS');
    for k = 1:size(chk.items,1)
        if chk.items{k,2}, tag = 'PASS'; else, tag = 'FLAG'; end
        fprintf('  [%s] %-42s %s\n', tag, chk.items{k,1}, chk.items{k,3});
    end
    if chk.pass
        fprintf('  Overall: all checks passed\n');
    else
        fprintf('  Overall: some checks flagged (review above)\n');
    end

    % ---------------- MODEL COMPARISON
    hdr('SWIRL MODEL COMPARISON (hub / mean / tip)');
    fprintf('  %-13s %-22s %-22s %-22s %s\n', 'model', 'R', 'u2 (m/s)', 'v2 (m/s)', 'flags');
    for k = 1:numel(radAll)
        q = radAll{k};  e = [1 q.imid numel(q.r)];
        nflag = sum(~[q.check.items{:,2}]);
        fprintf('  %-13s %6.3f %6.3f %6.3f    %6.1f %6.1f %6.1f    %6.1f %6.1f %6.1f    %d\n', ...
            q.model, q.R(e), q.st2.u(e), q.st2.v(e), nflag);
    end

    fprintf('\n============================================\n');
end
