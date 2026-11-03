function s = makeSection(g, fin, fout, r, span, tc, tab)

    prof = upper(g.profile);
    if ~ismember(prof, {'DCA','NACA65','A4K6','C4'}), error('Unknown profile "%s".', g.profile); end
    para = strcmp(prof,'C4') && strcmpi(g.camberline,'parabolic');
    mode = lower(g.camber_mode);

    % --- chord, pitch, thickness
    c = g.chord;
    switch lower(g.spacing_mode)
        case 'blades'
            if isempty(g.nblades), error('spacing_mode ''blades'' needs nblades.'); end
            pitch = 2*pi*r/g.nblades;
        case 'sigma', pitch = c/g.sigma;
        case 'pitch', pitch = g.pitch;
        otherwise,    error('spacing_mode must be blades | sigma | pitch.');
    end
    if ~(c > 0 && pitch > 0), error('Chord and pitch must be positive.'); end
    tb = tc*c;
    if ~(tb > 0 && tb < 0.5*c), error('t_b/c = %.3f is not physical.', tc); end

    % --- 1) camber angle theta
    switch mode
        case 'flow',  theta = (fin - g.incidence) - (fout - g.deviation);
        case 'theta', theta = g.theta;
        case 'cl0',   theta = thetaFromCl0(prof, g.Cl0, g);
        case 'bc',    theta = NaN;
        otherwise,    error('camber_mode must be flow | theta | cl0 | bc.');
    end
    if strcmp(mode,'bc') && ~para, error('camber_mode ''bc'' needs C4 + parabolic camberline.'); end
    if ~strcmp(mode,'bc') && ~(theta > 0), error('Camber angle = %.2f deg (must be > 0).', theta); end

    % --- 2) camberline end angles chi1, chi2
    b_c = NaN;
    if para
        if strcmp(mode,'bc'), [chi1,chi2,theta,b_c] = parabAngles(g.a_c, g.b_c, []);
        else,                 [chi1,chi2,theta,b_c] = parabAngles(g.a_c, [], theta); end
    elseif strcmp(prof,'A4K6')
        [chi1,chi2,~,b_c] = parabAngles(0.375, [], theta);   % equivalent parabolic arc
    else
        chi1 = theta/2;  chi2 = theta/2;                      % circular arc (or equivalent)
    end
    if strcmp(mode,'cl0'), Cl0 = g.Cl0; else, Cl0 = Cl0FromTheta(prof, theta, g); end

    % --- 3) stagger and metal angles
    if strcmpi(g.stagger_mode,'user'), gam = g.stagger;  k1 = gam + chi1;
    else,                              k1 = fin - g.incidence;  gam = k1 - chi1; end
    k2 = k1 - theta;

    % --- 4) profile in chord frame
    if strcmp(prof,'DCA')
        [xu,yu,xl,yl,x,y,tmax,xtm] = dcaProfile(c, theta, tb, g.r0_tb*tb, g.npts);
        cl = 'circular';
    else
        [x,y]          = buildCamberline(prof, g, c, theta, b_c, Cl0, tab);
        [xu,yu,xl,yl,t] = thicknessProfile(prof, c, tb, x, y, tab);
        [tmax,im] = max(t);  xtm = x(im)/c;
        if any(strcmp(prof,{'NACA65','A4K6'})), cl = 'tabulated'; else, cl = lower(g.camberline); end
    end

    % --- 5) rotate by stagger into the cascade frame (LE at origin)
    Rg = [cosd(gam) -sind(gam); sind(gam) cosd(gam)];
    s.up = Rg*[xu; yu];   s.lo = Rg*[xl; yl];   s.cam = Rg*[x; y];
    s.LE = [0; 0];        s.TE = Rg*[c; 0];

    s.profile = prof;  s.camberline = cl;  s.span = span;  s.r = r;
    s.flow_in = fin;   s.flow_out = fout;
    s.chord = c;  s.pitch = pitch;  s.sigma = c/pitch;
    s.theta = theta;  s.chi1 = chi1;  s.chi2 = chi2;  s.stagger = gam;
    s.kappa1 = k1;    s.kappa2 = k2;
    s.incidence = fin - k1;  s.deviation = fout - k2;
    s.Cl0 = Cl0;  s.b_c = b_c;
    s.tmax = tmax;  s.xtmax_c = xtm;
    s.Rc = c/(2*sind(theta/2));                       % equivalent circular-arc radius
    s.theta_A4K6 = [NaN NaN];
    if strcmp(prof,'A4K6')                            % exact vs approximate relation
        s.theta_A4K6 = [atand(291.5*Cl0/(468.75-(5.83*Cl0)^2)), 4*atand(0.05515*Cl0/0.375)];
    end
end

%% ------------------------------------------------------------
%  Cl0 <-> equivalent camber angle
% -------------------------------------------------------------
