function inp = defineInputs()

    % [A] Operating conditions
    inp.op.Tt1     = 298;       % Inlet total temperature (K)
    inp.op.Pt1     = 101e3;     % Inlet total pressure (Pa)
    inp.op.gamma   = 1.4;       % Specific heat ratio
    inp.op.cp      = 1004;      % Specific heat (J/kg.K)
    inp.op.mdot    = 100;       % Mass flow rate (kg/s)
    inp.op.PR      = 20;        % Overall compressor pressure ratio
    inp.op.eta_p   = 0.90;      % Temporary seed; overwritten by Lozza starting correlation

    % [B] Inlet design choices
    inp.inlet.Mz1   = 0.50;     % Inlet axial Mach number
    inp.inlet.rh_rt = 0.50;     % Hub-to-tip radius ratio
    inp.inlet.Cz    = 168.8;    % Constant axial velocity (m/s)

    % [C] Rotor design choices
    inp.rotor.Utip      = 450;  % Rotor tip speed (m/s)
    inp.rotor.Rm_target = 0.50; % Target degree of reaction
    inp.rotor.sigma     = 1.00; % Rotor solidity
    inp.rotor.chord     = 0.07; % Rotor chord length (m)
    inp.rotor.DH_target = 0.72; % De Haller ratio
    inp.rotor.tc_hub    = 0.10; % Hub thickness/chord ratio
    inp.rotor.tc_tip    = 0.05; % Tip thickness/chord ratio
    inp.rotor.incidence = 3.7;  % Rotor incidence angle (deg)
    inp.rotor.deviation = 5.0;  % Rotor deviation angle (deg)

    % [D] Stator design choices
    inp.stator.sigma_D  = 1.50; % Stator solidity for D-factor calculation
    inp.stator.sigma    = 1.25; % Stator blade design solidity
    inp.stator.stagger  = 15;   % Stator stagger angle (deg)

    % [E] Reynolds number conditions
    inp.re.rho_ratio_16km = 0.136;  % Density ratio at 16 km relative to sea level
    inp.re.nu16           = 8.54e-5;% Kinematic viscosity at 16 km (m2/s)
    inp.re.Re_min         = 300000; % Minimum chord Reynolds number

    % [F] Blade material / rotor stress inputs
    inp.mat.rho         = 4430;   % Blade density (kg/m3) - Ti-6Al-4V (change to your material)
    inp.mat.taper       = 0.80;   % Blade taper ratio At/Ah (0.8 - 1.0)
    inp.mat.k_area      = 0.70;   % Airfoil area coefficient: A_blade = k_area*(t/c)*c^2
    inp.mat.sigma_allow = 600e6;  % Allowable creep-rupture stress at blade temp (Pa)
                                  % -> read from Fig. 8.85/8.86
    inp.mat.SF_min      = 1.5;    % Minimum acceptable safety factor

    % [G] Radial equilibrium / 3D design
    inp.radial.swirl_model     = 'exponential'; % 'free_vortex' | 'exponential' | 'first_power'
    inp.radial.N               = 41;     % Radial points hub->tip (forced odd so r_m is a grid point)
    inp.radial.print_span      = [0.1 0.2 0.5 0.75]; % Span fractions printed (0 = hub, 1 = tip)
    inp.radial.mass_correction = true;   % Rescale mean-radius axial velocity so mass flow is conserved
    inp.radial.mass_tol        = 1e-3;   % Allowed relative mass-flow error
    inp.radial.eq_tol          = 1e-6;   % Allowed radial-equilibrium residual (relative)
    inp.radial.R_limits        = [0.1 0.9]; % Acceptable degree of reaction
    inp.radial.dR_max          = 0.35;   % Max hub-to-tip reaction variation
    inp.radial.du_max          = 0.25;   % Max (umax-umin)/umean at a station
    inp.radial.DF_max          = 0.60;   % Max local diffusion factor
    inp.radial.plots           = true;

    % [H] Loss model / REFPROP settings
    inp.loss.fluid      = 'air.mix';    % REFPROP fluid file
    inp.loss.source     = 'meanline';   % 'meanline' (stage struct) | 'midspan' (radial solver, span 0.5)
    inp.loss.Pscale     = 1e-3;         % Pa -> pressure unit expected by refpropm (kPa). Use 1 if your wrapper takes Pa
    inp.loss.ks         = 3e-6;         % Blade surface roughness (m)             
    inp.loss.tau_rotor  = 0.01;         % Rotor tip clearance / blade height (-)  
    inp.loss.tau_stator = 0.01;         % Stator clearance / blade height (-)     
    inp.loss.KE         = 0.5;          % Yaras-Sjolander constants (mid-loaded blades, l/C = 0.5)
    inp.loss.KG         = 1.0;

    % [I] Stage-efficiency fixed-point iteration
    inp.eff_iter.max_iter    = 50;      % maximum outer iterations
    inp.eff_iter.tol         = 1e-5;    % absolute convergence tolerance on eta_p
    inp.eff_iter.relaxation  = 0.50;    % under-relaxation factor (0 < omega <= 1)

    % [J] Multistage compressor (stage stacking, Fig. algorithm)
    inp.multi.enable       = true;      % run the multistage extension
    inp.multi.plots        = true;
    inp.multi.PR_tol       = 5e-3;      % accept when |PR_achieved/PR_target - 1| <= tol
    inp.multi.max_outer    = 8;         % max passes of the "new n and/or z ?" loop
    inp.multi.adjust       = 'n_and_z'; % what may change: 'n_and_z' | 'z' | 'n' | 'none'
    inp.multi.Utip_limits  = [400 550]; % allowed tip speed range when n is changed (m/s)
    inp.multi.relax_n      = 0.8;       % under-relaxation of the speed update
    % Per-stage assumptions: [] = repeat the stage-1 value; scalar = same for all;
    % vector = one value per stage (must have >= z entries).
    inp.multi.DH_target    = [];        % rotor De Haller ratio (sets psi, R through the triangles)
    inp.multi.sigma_rotor  = [];        % rotor solidity
    inp.multi.sigma_stator = [];        % stator solidity
    inp.multi.AR           = [];        % blade aspect ratio h/c ([] = constant chord)

    % ---------------- DESIGN GUIDELINES (reference) ----------------
    % Flow coefficient 0.3-0.9 (typ. 0.6)        | Diffusion factor <= 0.6 (typ. 0.45)
    % Axial Mach 0.3-0.6 (typ. 0.55)             | Tip tangential Mach 1.0-1.5 (typ. 1.3)
    % Degree of reaction 0.1-0.9 (typ. 0.5)      | Re_c >= 3e5 (preferred > 5e5)
    % First rotor tip rel. Mach <= 1.7           | Stage avg. solidity 1.0-2.0 (typ. 1.4)
    % Stage avg. aspect ratio 1-4 (typ. < 2)     | Polytropic eff. 0.85-0.92
    % Hub speed omega*rh <= 380 m/s              | Tip speed 450-550 m/s (typ. 500)
    % Loading coeff. 0.2-0.5 (typ. 0.35)         | De Haller W2/W1 >= 0.72 (typ. 0.75)
    % LE radius 5-10% of tmax                    | PR per spool < 20
    % Axial gap 0.23-0.25 cz                     | Blade taper ratio 0.8-1.0 (typ. 0.8)
end

%% ------------------------------------------------------------
%  OUTER FIXED-POINT LOOP FOR STAGE POLYTROPIC EFFICIENCY
%  The Lozza correlation supplies eta_p,0. The existing REFPROP loss
%  module then supplies the updated stage eta_p through PR_tt and Tt3/Tt1.
% -------------------------------------------------------------
