function printResults(inp, gas, inlet, exitc, stage, diffu, blade, stator, reyn, nst, extra, stress) %#ok<INUSL>

    fprintf('\n============================================\n');
    fprintf('       AXIAL COMPRESSOR DESIGN RESULTS\n');
    fprintf('============================================\n');

    fprintf('\n--- INLET CONDITIONS ---\n');
    fprintf('Static temperature      = %.2f K\n',   inlet.T);
    fprintf('Speed of sound          = %.2f m/s\n', inlet.a);
    fprintf('Axial velocity          = %.2f m/s\n', inlet.Cz);
    fprintf('Static pressure         = %.2f kPa\n', inlet.P/1000);
    fprintf('Density                 = %.4f kg/m3\n', inlet.rho);
    fprintf('Flow area               = %.5f m2\n',  inlet.A);

    fprintf('\n--- INLET GEOMETRY ---\n');
    fprintf('Tip radius              = %.4f m\n', inlet.rt);
    fprintf('Hub radius              = %.4f m\n', inlet.rh);
    fprintf('Pitchline radius        = %.4f m\n', inlet.rm);
    fprintf('Blade height            = %.4f m\n', inlet.h);

    fprintf('\n--- EXIT CONDITIONS ---\n');
    fprintf('Total pressure          = %.2f kPa\n', exitc.Pt/1000);
    fprintf('Total temperature       = %.2f K\n',   exitc.Tt);
    fprintf('Static temperature      = %.2f K\n',   exitc.T);
    fprintf('Static pressure         = %.2f kPa\n', exitc.P/1000);
    fprintf('Density                 = %.4f kg/m3\n', exitc.rho);
    fprintf('Exit Mach number        = %.4f\n',     exitc.M);
    fprintf('Exit flow area          = %.5f m2\n',  exitc.A);

    fprintf('\n--- EXIT GEOMETRY ---\n');
    fprintf('Tip radius              = %.4f m\n', exitc.rt);
    fprintf('Hub radius              = %.4f m\n', exitc.rh);
    fprintf('Blade height            = %.4f m\n', exitc.h);

    fprintf('\n--- FIRST STAGE ---\n');
    fprintf('Pitchline velocity      = %.2f m/s\n', stage.Um);
    fprintf('Shaft speed             = %.2f RPM\n', stage.RPM);
    fprintf('Inlet beta angle        = %.2f deg\n', stage.beta1);
    fprintf('Exit beta angle         = %.2f deg\n', stage.beta2);
    fprintf('Inlet relative velocity = %.2f m/s\n', stage.W1);
    fprintf('Exit relative velocity  = %.2f m/s\n', stage.W2);
    fprintf('Relative inlet Mach     = %.3f\n',     stage.Mr1);
    fprintf('Absolute exit angle     = %.2f deg\n', stage.alpha2);
    fprintf('Loading coefficient     = %.3f\n',     stage.psi);
    fprintf('Degree of reaction      = %.3f\n',     stage.Reaction);

    fprintf('\n--- BLADE DESIGN ---\n');
    fprintf('Thickness/chord         = %.3f\n',    blade.tc_mean);
    fprintf('Maximum thickness       = %.5f m\n',  blade.tmax);
    fprintf('Leading edge radius     = %.5f m\n',  blade.rLE);
    fprintf('Leading edge angle      = %.2f deg\n', blade.kappa1);
    fprintf('Trailing edge angle     = %.2f deg\n', blade.kappa2);
    fprintf('Camber angle            = %.2f deg\n', blade.camber);
    fprintf('Stagger angle           = %.2f deg\n', blade.stagger);
    fprintf('Rotor blade spacing     = %.4f m\n',  blade.spacing);
    fprintf('Number of rotor blades  = %d\n',      blade.N);

    fprintf('\n--- REYNOLDS NUMBER ---\n');
    fprintf('Density at 16 km        = %.4f kg/m3\n', reyn.rho16);
    fprintf('Minimum chord           = %.4f m\n',     reyn.chord_min);
    fprintf('Reynolds number         = %.0f\n',       reyn.Re_chord);

    fprintf('\n--- ADDITIONAL PARAMETERS ---\n');
    fprintf('Flow coefficient        = %.3f\n',     extra.phi);
    fprintf('Tip tangential Mach     = %.3f\n',     extra.MT);
    fprintf('Tip relative Mach       = %.3f\n',     extra.M1r_tip);
    fprintf('Hub rotational speed    = %.2f m/s\n', extra.Uh);
    fprintf('Aspect ratio            = %.3f\n',     extra.AR);
    fprintf('Stage average solidity  = %.3f\n',     extra.sigma_stage);
    fprintf('Rotor diffusion factor  = %.3f\n',     diffu.Dr);
    fprintf('Stator diffusion factor = %.3f\n',     diffu.Ds);
    fprintf('Rotor De Haller         = %.3f\n',     diffu.DH_rotor);
    fprintf('Stator De Haller        = %.3f\n',     diffu.DH_stator);

    fprintf('\n--- STAGE DESIGN ---\n');
    fprintf('Temperature rise/stage  = %.2f K\n', nst.dT_stage);
    fprintf('Total temperature rise  = %.2f K\n', nst.dT_comp);
    fprintf('Calculated stages       = %.2f\n',   nst.exact);
    fprintf('Selected stages         = %d\n',     nst.N);
    fprintf('Equal stage PR          = %.4f\n',   nst.PR_stage);

    fprintf('\n--- ROTOR STRESS (BLADE ROOT) ---\n');
    fprintf('Blade density           = %.0f kg/m3\n', inp.mat.rho);
    fprintf('Root blade area         = %.3f cm2\n',   stress.Ab_hub*1e4);
    fprintf('Tip blade area          = %.3f cm2\n',   stress.Ab_tip*1e4);
    fprintf('Taper ratio At/Ah       = %.2f\n',       stress.Ab_tip/stress.Ab_hub);
    fprintf('Taper implied by t/c    = %.2f\n',       stress.taper_from_tc);
    fprintf('Centrifugal force root  = %.2f kN\n',    stress.Fc_root/1e3);
    fprintf('Centrifugal stress root = %.2f MPa\n',   stress.sigma_c_root/1e6);
    fprintf('sigma_c/rho (Eq.8.204)  = %.0f m2/s2\n', stress.sigma_rho_int);
    fprintf('sigma_c/rho (AN2,8.206) = %.0f m2/s2\n', stress.sigma_rho_AN2);
    fprintf('Stress (AN2 approx.)    = %.2f MPa\n',   stress.sigma_c_AN2/1e6);
    fprintf('Allowable stress        = %.2f MPa\n',   inp.mat.sigma_allow/1e6);
    fprintf('Safety factor           = %.2f\n',       stress.SF);
    if stress.ok
        fprintf('Stress check            = PASS\n');
    else
        fprintf('Stress check            = FAIL (reduce Utip or taper blade more)\n');
    end

    fprintf('\n============================================\n');
end
%% ------------------------------------------------------------
%  PRINT: RADIAL / 3D RESULTS
% -------------------------------------------------------------
