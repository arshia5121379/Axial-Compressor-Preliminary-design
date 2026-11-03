function [xu, yu, xl, yl, xc, yc, tmax, xtm] = dcaProfile(c, theta, tb, r0, n)

    th = theta*pi/180;
    y0 = (c/2)*tan(th/4);                    % mid-chord camber ordinate
    dx = c/2 - r0*cos(th/2);                 % nose-circle centre, x offset
    ny = r0*sin(th/2);                       % nose-circle centre, y
    d  = y0 + tb/2 - ny;                     % upper
    dL = tb/2 - y0 + ny;                     % lower (signed convention: centre above the lower surface)

    if abs(d - r0) < 1e-12 || abs(dL - r0) < 1e-12
        error('DCA: d = r0 (singular). Change thickness, camber or edge radius.');
    end
    RU = (d^2  - r0^2 + dx^2)/(2*(d  - r0));
    RL = (dL^2 - r0^2 + dx^2)/(2*(dL - r0));          % computed independently of RU
    if RU <= r0 || RL <= r0
        error('DCA: invalid radii (R_U = %.4g m, R_L = %.4g m). Increase thickness or reduce camber.', RU, RL);
    end
    sU = dx/(RU - r0);  sL = dx/(RL - r0);
    if abs(sU) > 1 || abs(sL) > 1, error('DCA: |dx/(R-r0)| > 1, arc angle undefined.'); end
    aU = asin(sU);  aL = asin(sL);                    % theta_U/2 , theta_L/2

    m  = max(8, round(n/10));
    pU = linspace(-aU, aU, n);  cU = y0 + tb/2 - RU;  % upper arc centre (0, cU)
    pL = linspace(-aL, aL, n);  cL = y0 - tb/2 + RL;  % lower arc centre (0, cL)
    NL = [-dx; ny];  NT = [dx; ny];                   % LE / TE nose-circle centres
    ring = @(N, psi) [N(1) + r0*cos(psi); N(2) + r0*sin(psi)];

    up = [ring(NL, linspace(pi, pi/2 + aU, m)), [RU*sin(pU); cU + RU*cos(pU)], ring(NT, linspace(pi/2 - aU, 0, m))];
    lo = [ring(NL, linspace(pi, 3*pi/2 - aL, m)), [RL*sin(pL); cL - RL*cos(pL)], ring(NT, linspace(-pi/2 + aL, 0, m))];

    xu = up(1,:) + c/2;  yu = up(2,:);
    xl = lo(1,:) + c/2;  yl = lo(2,:);
    xc = c*(1 - cos(pi*linspace(0,1,n)))/2;
    yc = circY(xc, c, theta);
    tmax = tb;  xtm = 0.5;
end

%% ------------------------------------------------------------
%  Table 4-1 (percent of chord).  NaN = em dash (not available).
% -------------------------------------------------------------
