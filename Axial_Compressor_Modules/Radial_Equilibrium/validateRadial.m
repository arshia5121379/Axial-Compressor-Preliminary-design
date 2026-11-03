function c = validateRadial(inp, rad, b3)

    ri = inp.radial;
    items = {};   % {label, pass, detail}

    usq_all = [rad.st1.usq, rad.st2.usq, rad.st3.usq];

    % 1. axial velocity real and positive
    ok = all(isfinite(usq_all)) && all(usq_all > 0);
    items(end+1,:) = {'Axial velocity real and positive', ok, ...
        sprintf('min u = %.2f m/s', sqrt(max(min(usq_all),0)))};

    % 2. reaction within limits
    ok = all(rad.R >= ri.R_limits(1)) && all(rad.R <= ri.R_limits(2));
    items(end+1,:) = {'Reaction within limits', ok, ...
        sprintf('R = %.3f ... %.3f (limits %.2f-%.2f)', min(rad.R), max(rad.R), ri.R_limits)};

    % 3. no singularities
    allv = [rad.st1.v, rad.st2.v, rad.st3.v, rad.R, rad.work];
    ok = all(isfinite(allv)) && all(rad.r > 0) && rad.b ~= 0 && min(abs(rad.st2.v - rad.st1.v)) > 0;
    items(end+1,:) = {'No singularities / division by zero', ok, ''};

    % 4. rotor work radially constant
    c.work_err = max(abs(rad.work - rad.dht))/rad.dht;
    items(end+1,:) = {'Rotor work radially constant', c.work_err < 1e-9, ...
        sprintf('max deviation = %.2e', c.work_err)};

    % 5. prescribed mean reaction recovered
    c.Rm_err = abs(rad.R(rad.imid) - rad.Rcm);
    items(end+1,:) = {'Mean-radius reaction recovered', c.Rm_err < 1e-9, ...
        sprintf('R(rm) = %.4f, design = %.4f', rad.R(rad.imid), rad.Rcm)};

    % analytical reaction vs numerical
    c.R_an_err = max(abs(rad.R - rad.R_an));
    items(end+1,:) = {'Analytical reaction = numerical', c.R_an_err < 1e-9, ...
        sprintf('max difference = %.2e', c.R_an_err)};

    % 6. mass flow conservation
    c.mass_err = abs(rad.mass.err);
    items(end+1,:) = {'Mass flow conserved (st 1, 2, 3)', all(c.mass_err < ri.mass_tol), ...
        sprintf('errors = %.1e / %.1e / %.1e', c.mass_err)};

    % 7. radial equilibrium at every station (central differences of the model)
    dr    = 1e-4*rad.rm;
    sides = [1 2 1];
    c.eq_res = zeros(1,3);
    for k = 1:3
        um2 = rad.um(k)^2;
        [up, vp] = evalStation(rad.M, (rad.r+dr)/rad.rm, rad.a, rad.b, um2, sides(k));
        [um_, vm] = evalStation(rad.M, (rad.r-dr)/rad.rm, rad.a, rad.b, um2, sides(k));
        [~,  v0] = evalStation(rad.M, rad.x,              rad.a, rad.b, um2, sides(k));
        dusq = (up - um_)/(2*dr);
        dv   = (vp - vm)/(2*dr);
        res  = 0.5*dusq + v0.*dv + v0.^2./rad.r;      % u du/dr + v dv/dr + v^2/r
        scl  = max(max(abs(v0.^2./rad.r), abs(v0.*dv)), abs(0.5*dusq));
        c.eq_res(k) = max(abs(res)./max(scl,1e-12));
    end
    items(end+1,:) = {'Radial equilibrium satisfied (st 1, 2, 3)', all(c.eq_res < ri.eq_tol), ...
        sprintf('residuals = %.1e / %.1e / %.1e', c.eq_res)};

    % 8. excessive variation flags
    c.dR = max(rad.R) - min(rad.R);
    du = zeros(1,3);  s = {rad.st1, rad.st2, rad.st3};
    for k = 1:3
        du(k) = (max(s{k}.u) - min(s{k}.u))/mean(s{k}.u);
    end
    c.du = du;
    items(end+1,:) = {'Reaction variation acceptable', c.dR <= ri.dR_max, ...
        sprintf('dR = %.3f (max %.2f)', c.dR, ri.dR_max)};
    items(end+1,:) = {'Axial-velocity variation acceptable', all(du <= ri.du_max), ...
        sprintf('du/u = %.2f / %.2f / %.2f (max %.2f)', du, ri.du_max)};
    DFmax = max([b3.DF_rotor, b3.DF_stator]);
    items(end+1,:) = {'Local diffusion factor acceptable', DFmax <= ri.DF_max, ...
        sprintf('max DF = %.3f (max %.2f)', DFmax, ri.DF_max)};

    c.items = items;
    c.pass  = all([items{:,2}]);
end

%% ------------------------------------------------------------
%  COMPARE THE THREE SWIRL MODELS
% -------------------------------------------------------------
