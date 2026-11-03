function rows = buildBladeRows(inp, geo, blade, rad)

    tab = profileTables();
    sp  = geo.span_stations(:).';
    at  = @(f) interp1(rad.span, f, sp, 'pchip');
    r   = at(rad.r);

    fin  = {at(rad.st1.beta),  at(rad.st2.alpha)};   % rotor: beta1   | stator: alpha2
    fout = {at(rad.st2.beta),  at(rad.st3.alpha)};   % rotor: beta2   | stator: alpha3

    def.rotor  = struct('chord', inp.rotor.chord, 'sigma', inp.rotor.sigma, 'nblades', blade.N, ...
                        'incidence', inp.rotor.incidence, 'deviation', inp.rotor.deviation, ...
                        'tc', inp.rotor.tc_hub + (inp.rotor.tc_tip - inp.rotor.tc_hub)*sp);
    def.stator = struct('chord', inp.rotor.chord, 'sigma', inp.stator.sigma);

    names = {'rotor', 'stator'};
    for q = 1:2
        g = fillDefaults(geo.(names{q}), def.(names{q}));
        tc = g.tc;
        if isscalar(tc), tc = tc*ones(size(sp)); end
        if numel(tc) ~= numel(sp), error('%s.tc must be [], a scalar, or one value per section.', names{q}); end
        for k = 1:numel(sp)
            rows.(names{q}){k} = makeSection(g, fin{q}(k), fout{q}(k), r(k), sp(k), tc(k), tab);
        end
    end
end
