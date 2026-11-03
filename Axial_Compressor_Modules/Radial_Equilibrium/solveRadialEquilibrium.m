function rad = solveRadialEquilibrium(inp, gas, inlet, stage, stator, model)

    op = inp.op;
    ri = inp.radial;
    M  = getSwirlModel(model);

    % --- Radial grid (odd N -> r_m is a grid node)
    N  = 2*floor(ri.N/2) + 1;
    rm = inlet.rm;  rh = inlet.rh;  rt = inlet.rt;
    r  = linspace(rh, rt, N);
    x  = r/rm;
    im = (N+1)/2;
    om = stage.omega;
    wrm = om*rm;
    U  = om*r;
    Cz = inp.inlet.Cz;

    % --- Mean-line reference: work, reaction, swirl parameter b
    dht = op.cp*(stator.Tt2 - op.Tt1);          % stage work (J/kg), g_c = 1
    b   = dht/(2*wrm);
    Rcm = stage.Reaction;                       % mean-radius reaction from mean-line

    % --- Total conditions per station (radially constant, losses radially constant)
    g   = op.gamma;
    Pt2 = op.Pt1*(stator.Tt2/op.Tt1)^(op.eta_p*g/(g-1));
    Tt  = [op.Tt1; stator.Tt2; stator.Tt2];
    Pt  = [op.Pt1; Pt2;        Pt2];

    % --- Mean-line mass flux on the stage annulus (reference for mass check)
    Cm    = [Cz; stage.C2; Cz];
    A     = pi*(rt^2 - rh^2);
    mref  = zeros(3,1);
    for k = 1:3
        mref(k) = isentropicDensity(gas, op, Pt(k), Tt(k), Cm(k)^2)*Cz*A;
    end

    % --- Iterate mean-radius axial velocities (mass conservation)
    um = [Cz Cz Cz];
    for it = 1:60
        um_used = um;
        a = wrm*(1 - Rcm) + (um(1)^2 - um(2)^2)/(4*b);   % mean-radius reaction equation

        [usq1, v1] = evalStation(M, x, a, b, um(1)^2, 1);
        [usq2, v2] = evalStation(M, x, a, b, um(2)^2, 2);
        [usq3, v3] = evalStation(M, x, a, b, um(3)^2, 1); % repeating stage v3 = v1

        usq = {usq1, usq2, usq3};
        v   = {v1, v2, v3};
        m   = zeros(3,1);
        for k = 1:3
            s    = buildStation(gas, op, Pt(k), Tt(k), usq{k}, v{k}, U);
            m(k) = 2*pi*trapz(r, s.rho.*s.u.*r);
        end

        scale = mref./m;
        if ~ri.mass_correction || max(abs(scale-1)) < 1e-12
            break;
        end
        um = um.*scale.';
    end

    st1 = buildStation(gas, op, Pt(1), Tt(1), usq1, v1, U);
    st2 = buildStation(gas, op, Pt(2), Tt(2), usq2, v2, U);
    st3 = buildStation(gas, op, Pt(3), Tt(3), usq3, v3, U);

    % --- Degree of reaction
    R_cu = 1 - (v1 + v2)./(2*U);                                     % constant axial velocity
    R    = 1 + (usq1 - usq2)./(2*U.*(v2 - v1)) - (v1 + v2)./(2*U);   % variable axial velocity
    R_an = 1 + (um_used(1)^2 - um_used(2)^2)/(4*b*wrm) + M.R(x,a,b,wrm);  % analytical

    % --- Pack
    rad.model = M.name;   rad.M = M;   rad.n = M.n;
    rad.a = a;  rad.b = b;  rad.Rcm = Rcm;  rad.dht = dht;
    rad.omega = om;  rad.rm = rm;  rad.rh = rh;  rad.rt = rt;
    rad.r = r;  rad.x = x;  rad.span = (r-rh)/(rt-rh);  rad.imid = im;  rad.U = U;
    rad.um_ref = Cz;  rad.um = um_used;
    rad.st1 = st1;  rad.st2 = st2;  rad.st3 = st3;
    rad.R = R;  rad.R_cu = R_cu;  rad.R_an = R_an;
    rad.work = U.*(v2 - v1);                      % Euler work (J/kg)
    rad.mass.m = m;  rad.mass.ref = mref;  rad.mass.err = m./mref - 1;
end

%% ------------------------------------------------------------
%  3D BLADE GEOMETRY + LOCAL DIFFUSION
% -------------------------------------------------------------
