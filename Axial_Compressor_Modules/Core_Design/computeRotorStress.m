function s = computeRotorStress(inp, inlet, stage)

    m = inp.mat;
    r = inp.rotor;

    % --- Blade areas (m2)
    s.Ab_hub = m.k_area*r.tc_hub*r.chord^2;        % root area
    s.Ab_tip = m.taper*s.Ab_hub;                   % tip area (linear taper)
    s.taper_from_tc = r.tc_tip/r.tc_hub;           % info: taper implied by t/c

    % --- Annulus area for AN^2 form: A = 2*pi*rm*(rt-rh)
    s.A_ann = 2*pi*inlet.rm*(inlet.rt-inlet.rh);

    % --- Taper distribution Ab(r)/Ah (Eq. 8.205)
    s.r        = linspace(inlet.rh, inlet.rt, 200);
    s.Ab_ratio = 1 - (s.r-inlet.rh)/(inlet.rt-inlet.rh)*(1 - s.Ab_tip/s.Ab_hub);
    s.Ab_r     = s.Ab_ratio*s.Ab_hub;

    % --- Root centrifugal force (Eq. 8.201) and stress
    s.Fc_root = m.rho*stage.omega^2*trapz(s.r, s.Ab_r.*s.r);   % N
    s.sigma_c_root = s.Fc_root/s.Ab_hub;                       % Pa

    % --- Eq. 8.204 integral form (sigma/rho)
    s.sigma_rho_int = stage.omega^2*trapz(s.r, s.Ab_ratio.*s.r);

    % --- Eq. 8.206 pitchline AN^2 approximation
    s.sigma_rho_AN2 = (stage.omega^2*s.A_ann/(4*pi))*(1 + s.Ab_tip/s.Ab_hub);
    s.sigma_c_AN2   = m.rho*s.sigma_rho_AN2;

    % --- Margin
    s.SF = m.sigma_allow/s.sigma_c_root;
    s.ok = s.SF >= m.SF_min;
end

%% ------------------------------------------------------------
%  SWIRL-DISTRIBUTION MODEL LIBRARY  (Sect. 9.3.7)
%  x = r/rm.  v1 = rotor-inlet whirl, v2 = rotor-exit whirl.
%  u^2(x) = um^2 - 2*I(x)   (integral of the radial equilibrium eq.
%  from r_m to r, for constant total enthalpy).
%  R(x) = 1 + (u1m^2-u2m^2)/(4*b*w*rm) + M.R(x,a,b,w*rm)
%  To add a new distribution: add one case with v1, v2, I1, I2, R.
% -------------------------------------------------------------
