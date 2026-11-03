function L = computeStageLosses(inp, geo, inlet, stage, stator, blade, rad)

    li = inp.loss;
    rp = struct('fluid', li.fluid, 'Pscale', li.Pscale);
    K  = lossKinematics(inp, stage, stator, rad, inlet, li.source);

    % ---------- Station 1 (rotor inlet) ----------
    S1t  = rpState(rp, 'T', inp.op.Tt1, 'P', inp.op.Pt1);
    h1t  = S1t.h;   s1 = S1t.s;   p1t = S1t.P;
    h1   = h1t - K.c(1)^2/2;
    S1   = rpState(rp, 'H', h1, 'S', s1);
    h1tr = h1 + K.w1^2/2;
    S1tr = rpState(rp, 'H', h1tr, 'S', s1);        % relative total (isentropic stagnation)
    p1tr = S1tr.P;

    % ---------- Euler work and station-2 enthalpies ----------
    wk   = K.U*(K.cth(2) - K.cth(1));              % J/kg  (U1 = U2)
    h2t  = h1t + wk;
    h2   = h2t - K.c(2)^2/2;
    h2tr = h1tr;                                   % constant radius -> h2tr = h1tr

    % ---------- Rotor geometry / flow ----------
    gR.sigma = inp.rotor.sigma;
    gR.C     = inp.rotor.chord;
    gR.tc    = blade.tc_mean;                      % tmax/C at mean line
    gR.hB1   = K.hB1;
    gR.tau   = li.tau_rotor*K.hB1;
    gR.ks    = li.ks;
    fR = struct('ang1', K.beta1, 'ang2', K.beta2, 'v1', K.w1, 'v2', K.w2, ...
                'cx1', K.cx(1), 'hr', 1);

    for it = 1:100
        YR   = cascadeLoss(gR, fR, S1, li.KE, li.KG);
        p2tr = p1tr - YR.tot*(p1tr - S1.P);
        S2tr = rpState(rp, 'P', p2tr, 'H', h2tr);
        s2   = S2tr.s;
        S2   = rpState(rp, 'H', h2, 'S', s2);
        hr_new = (S1.rho*K.cx(1))/(S2.rho*K.cx(2));
        if abs(hr_new - fR.hr) < 1e-9, break; end
        fR.hr = hr_new;
    end

    % ---------- Rotor efficiency ----------
    S2is = rpState(rp, 'P', S2.P, 'S', s1);
    etaR = (S2is.h - h1)/(h2 - h1);

    % ---------- Stator ----------
    S2t = rpState(rp, 'H', h2t, 'S', s2);
    p2t = S2t.P;

    gS.sigma = inp.stator.sigma;
    if ~isempty(geo.stator.sigma),  gS.sigma = geo.stator.sigma;  end
    gS.C = inp.rotor.chord;
    if ~isempty(geo.stator.chord),  gS.C = geo.stator.chord;      end
    gS.tc = blade.tc_mean;
    if ~isempty(geo.stator.tc) && isscalar(geo.stator.tc), gS.tc = geo.stator.tc; end
    gS.hB1 = K.hB1*fR.hr;                          % stator inlet height = rotor exit height
    gS.tau = li.tau_stator*gS.hB1;
    gS.ks  = li.ks;
    fS = struct('ang1', K.alpha2, 'ang2', K.alpha3, 'v1', K.c(2), 'v2', K.c(3), ...
                'cx1', K.cx(2), 'hr', 1);

    for it = 1:100
        YS  = cascadeLoss(gS, fS, S2, li.KE, li.KG);
        p3t = p2t - YS.tot*(p2t - S2.P);
        S3t = rpState(rp, 'P', p3t, 'H', h2t);     % h3t = h2t
        s3  = S3t.s;
        h3  = h2t - K.c(3)^2/2;
        S3  = rpState(rp, 'H', h3, 'S', s3);
        hr_new = (S2.rho*K.cx(2))/(S3.rho*K.cx(3));
        if abs(hr_new - fS.hr) < 1e-9, break; end
        fS.hr = hr_new;
    end

    % ---------- Efficiencies ----------
    S3tis = rpState(rp, 'P', p3t,  'S', s1);       % h3t,is
    S3is  = rpState(rp, 'P', S3.P, 'S', s1);       % h3,is
    h3t   = h2t;
    eta.R  = etaR;
    eta.TT = (S3tis.h - h1t)/(h3t - h1t);
    eta.is = (S3is.h  - h1 )/(h3   - h1 );
    eta.TS = (S3is.h  - h1t)/(h3t - h1t);

    % ---------- Pack ----------
    L.source = li.source;   L.fluid = li.fluid;
    L.work   = wk;          L.K = K;
    L.rotor  = YR;          L.stator = YS;
    L.eta    = eta;
    L.PR_tt  = p3t/p1t;
    L.PR_ts  = S3.P/p1t;
    % Actual total states used for the outer polytropic-efficiency update.
    L.total.Tt1 = S1t.T;
    L.total.Tt3 = S3t.T;
    L.total.gamma_bar = 0.5*(S1t.gamma + S3t.gamma);
    L.total.h1t = h1t;
    L.total.h3t = h3t;
    L.hB     = [K.hB1, K.hB1*fR.hr, K.hB1*fR.hr*fS.hr];
    L.st(1)  = packStation('1  inlet',      S1,  p1t);
    L.st(2)  = packStation('2  rotor exit', S2,  p2t);
    L.st(3)  = packStation('3  stator exit',S3,  p3t);
    L.p      = struct('p1t', p1t, 'p1tr', p1tr, 'p2tr', p2tr, 'p2t', p2t, 'p3t', p3t);
end
