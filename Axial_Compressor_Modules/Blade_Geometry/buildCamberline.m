function [x, y] = buildCamberline(prof, g, c, theta, b_c, Cl0, tab)
    x  = c*(1 - cos(pi*linspace(0,1,g.npts)))/2;
    xp = 100*x/c;
    switch prof
        case 'NACA65', y = Cl0*c*interpTab(tab.x, tab.y65, xp)/100;
        case 'A4K6',   y = Cl0*c*interpTab(tab.x, tab.yA4, xp)/100;
        otherwise      % C4
            if strcmpi(g.camberline,'parabolic'), y = parabolaY(x, c, g.a_c*c, b_c*c);
            else,                                 y = circY(x, c, theta); end
    end
end
