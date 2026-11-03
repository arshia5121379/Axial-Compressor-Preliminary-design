%% ============================================================
%   AXIAL COMPRESSOR PRELIMINARY DESIGN  (functional / struct based)
%   Main driver; calculation and plotting functions are in separate module files.
%   Every group of related variables lives in one structure.
% =============================================================
clc;
clear;
close all;

% ---------- LOAD MODULAR FUNCTION FILES ----------
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
moduleDir = fullfile(scriptDir, 'Axial_Compressor_Modules');
if ~exist(moduleDir, 'dir')
    error('Module folder not found: %s', moduleDir);
end
addpath(genpath(moduleDir));


% ---------- AUTOMATIC OUTPUT EXPORT ----------
% Each run gets its own folder so previous results are not overwritten.
outputDir = fullfile(pwd, ['Axial_Compressor_Results_' datestr(now,'yyyymmdd_HHMMSS')]);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
diaryFile = fullfile(outputDir, 'console_output.txt');
diary(diaryFile);
diary on;

fprintf('\nOutput directory: %s\n', outputDir);

%% ============================================================
%              1. USER-DEFINED DESIGN PARAMETERS
% =============================================================
inp = defineInputs();

%% ============================================================
%              1b. BLADE GEOMETRY SELECTIONS  (user-editable)
%   Rotor and stator are fully independent.  [] = use existing value.
%   Angles in deg, lengths in m.  Flow angles come from the radial solver.
% =============================================================
geo.span_stations = [0 0.5 1];  % radial sections (span fraction: 0 hub, 0.5 mean, 1 tip)
geo.n_blades_plot = 5;          % adjacent blades drawn in the cascade figures
geo.plots         = true;
geo.bb_span_pct   = [50];       % stage blade-to-blade view at these span % (0 = hub, 100 = tip); any values/any number
geo.blades_3d     = Inf;        % blades per row in the 3D solid view (Inf = full wheel)

% ---------------- ROTOR ----------------
geo.rotor.profile       = 'NACA65';   % 'DCA' | 'NACA65' | 'A4K6' | 'C4'
geo.rotor.camberline    = 'parabolic'; % 'circular' | 'parabolic'  (used by C4; DCA is circular;
                                      %  NACA65 / A4K6 use their own tabulated camberline)
geo.rotor.camber_mode   = 'flow';     % 'flow'  : theta = (beta1-i)-(beta2-dev) from velocity triangles
                                      % 'theta' : use geo.rotor.theta
                                      % 'cl0'   : use geo.rotor.Cl0
                                      % 'bc'    : use geo.rotor.b_c (C4 + parabolic only)
geo.rotor.theta         = 10;         % camber angle (camber_mode = 'theta')
geo.rotor.Cl0           = 1.0;        % isolated lift coefficient (camber_mode = 'cl0')
geo.rotor.b_c           = 0.04;       % max camber / chord (camber_mode = 'bc')
geo.rotor.a_c           = 0.50;       % parabolic max-camber location, 0.25 < a/c < 0.75
geo.rotor.a4k6_relation = 'exact';    % A4K6 theta(Cl0): 'exact' | 'approx'
geo.rotor.stagger_mode  = 'auto';     % 'auto': gamma = kappa1 - chi1  |  'user': geo.rotor.stagger
geo.rotor.stagger       = 50;
geo.rotor.chord         = [];         % [] -> inp.rotor.chord
geo.rotor.spacing_mode  = 'blades';   % 'blades' (s = 2*pi*r/N) | 'sigma' | 'pitch'
geo.rotor.nblades       = [];         % [] -> blade count of the mean-line design
geo.rotor.sigma         = [];         % [] -> inp.rotor.sigma
geo.rotor.pitch         = 0.07;       % (spacing_mode = 'pitch')
geo.rotor.incidence     = [];         % [] -> inp.rotor.incidence
geo.rotor.deviation     = [];         % [] -> inp.rotor.deviation
geo.rotor.tc            = [];         % t_max/c: [] = existing hub->tip law | scalar | one value per section
geo.rotor.r0_tb         = 0.05;       % DCA edge radius / t_max
geo.rotor.npts          = 200;        % chordwise points

% ---------------- STATOR ----------------
geo.stator.profile       = 'C4';
geo.stator.camberline    = 'parabolic';
geo.stator.camber_mode   = 'flow';
geo.stator.theta         = 40;
geo.stator.Cl0           = 1.5;
geo.stator.b_c           = 0.08;
geo.stator.a_c           = 0.45;
geo.stator.a4k6_relation = 'exact';
geo.stator.stagger_mode  = 'auto';
geo.stator.stagger       = 20;
geo.stator.chord         = [];         % [] -> inp.rotor.chord
geo.stator.spacing_mode  = 'sigma';
geo.stator.nblades       = 40;
geo.stator.sigma         = [];         % [] -> inp.stator.sigma
geo.stator.pitch         = 0.05;
geo.stator.incidence     = 0;
geo.stator.deviation     = 6;
geo.stator.tc            = 0.08;
geo.stator.r0_tb         = 0.05;
geo.stator.npts          = 200;

%% ============================================================
%              2. ITERATIVE STAGE-EFFICIENCY CALCULATION
%   Lozza (2016) provides the initial polytropic efficiency.
%   Kinematics, thermodynamics, radial equilibrium and stage losses
%   are recalculated until the loss-based eta_p converges.
% =============================================================
[inp, calc, etaIter] = iterateStageEfficiency(inp, geo);

gas     = calc.gas;
inlet   = calc.inlet;
exitc   = calc.exitc;
stage   = calc.stage;
diffu   = calc.diffu;
blade   = calc.blade;
stator  = calc.stator;
reyn    = calc.reyn;
nst     = calc.nst;
extra   = calc.extra;
stress  = calc.stress;
radial  = calc.radial;
blade3d = calc.blade3d;
check   = calc.check;
loss    = calc.loss;

% Compare alternative radial-swirl models only after convergence.
radAll  = compareSwirlModels(inp, gas, inlet, stage, stator, blade);

%% ============================================================
%              3. BLADE GEOMETRY  (downstream of the aero solver)
% =============================================================

rows    = buildBladeRows(inp, geo, blade, radial);
rowsBB  = buildStageSections(inp, geo, blade, radial);   % sections at geo.bb_span_pct

%% ============================================================
%              4. RESULTS
% =============================================================
printResults(inp, gas, inlet, exitc, stage, diffu, blade, stator, reyn, nst, extra, stress);
printRadialResults(inp, stage, radial, blade3d, check, radAll);
printLossResults(loss);
printEfficiencyIteration(etaIter, inp.op.eta_p);
printBladeGeometry(rows);

if inp.radial.plots
    plotRadialResults(radial, blade3d);
    plotModelComparison(radAll);
end
if geo.plots
    plotCascades(rows, geo);
    plotBlades3D(rows, geo);
    plotStageBB(rowsBB, geo);
end


%% ============================================================
%              5. MULTISTAGE COMPRESSOR  (stage-stacking algorithm)
%   a) stage pressure ratios from equal total-temperature rise per stage
%   b) march i = 1..z : stage p/T -> phi, psi, R -> AR, sigma ->
%      stage calculation (Lozza start + loss-based eta_p loop, Sect. 2)
%   c) "new values n and/or z ?" loop until the overall PR is met
% =============================================================
ms = [];  % Keep a defined value when the multistage option is disabled.
if inp.multi.enable
    ms = designMultistageCompressor(inp, geo, calc);
    printMultistage(ms, inp);
    if inp.multi.plots
        plotStagePressureRatio(ms);
        plotMultistageResults(ms);
    end
end

%% ============================================================
%              6. AUTOMATIC PNG + TXT EXPORT
%   Saves every figure generated in this run as a PNG image.
%   Writes console output plus all principal input/output structures
%   (including radial distributions, blade geometry and multistage data)
%   into a readable TXT report using tabulated numeric data.
% =============================================================
exportDesignResults(outputDir, inp, geo, calc, etaIter, radAll, ...
                    rows, rowsBB, ms);

fprintf('\nPNG figures and TXT data have been exported to:\n%s\n', outputDir);
diary off;

%% ############################################################
%                       LOCAL FUNCTIONS
% ############################################################

%% ------------------------------------------------------------
%  INPUTS
% -------------------------------------------------------------

% All calculation, geometry, plotting, loss, multistage, and export functions
% are stored as separate .m files in Axial_Compressor_Modules.
