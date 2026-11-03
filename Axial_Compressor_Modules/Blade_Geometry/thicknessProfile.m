function [xu, yu, xl, yl, t] = thicknessProfile(prof, c, tb, x, y, tab)
    dydx = gradient(y, x);
    ds   = sqrt(1 + dydx.^2);
    sarc = cumtrapz(x, ds);
    xi   = sarc/sarc(end);
    switch prof
        case 'NACA65', col = tab.t65;  tbase = tab.tbase.NACA65;
        case 'A4K6',   col = tab.tA4;  tbase = tab.tbase.A4K6;
        case 'C4',     col = tab.tC4;  tbase = tab.tbase.C4;
    end
    t  = interpTab(tab.x, col, 100*xi)/100 * (tb/(tbase*c)) * c;   % t_new = t_base*tmax_new/tmax_base
    nx = -dydx./ds;  ny = 1./ds;                                    % unit normal
    xu = x + 0.5*t.*nx;  yu = y + 0.5*t.*ny;
    xl = x - 0.5*t.*nx;  yl = y - 0.5*t.*ny;
end

%% ------------------------------------------------------------
%  Double-circular-arc profile (Section 5)
% -------------------------------------------------------------
