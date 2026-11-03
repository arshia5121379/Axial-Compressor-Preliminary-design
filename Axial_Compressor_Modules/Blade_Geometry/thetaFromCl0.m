function theta = thetaFromCl0(prof, Cl0, g)
    if strcmp(prof,'A4K6')
        if strcmpi(g.a4k6_relation,'approx'), theta = 4*atand(0.05515*Cl0/0.375);
        else,                                 theta = atand(291.5*Cl0/(468.75-(5.83*Cl0)^2)); end
    else
        theta = 4*atand(0.1103*Cl0);                  % equivalent circular arc
    end
end
