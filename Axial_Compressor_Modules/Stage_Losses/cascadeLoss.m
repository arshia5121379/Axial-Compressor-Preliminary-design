function Y = cascadeLoss(g, f, S, KE, KG)

    K1 = 0.2445;  K2 = 0.4458;  K3 = 0.7688;  K4 = 0.6024;

    sg = g.sigma;  C = g.C;  tc = g.tc;
    a1 = f.ang1;   a2 = f.ang2;  hr = f.hr;
    hB = g.hB1*(1 + hr)/2;                         % mean blade height of the row

    Ma1  = f.v1/S.a;                               % inlet Mach (relative for rotor)
    Max1 = f.cx1/S.a;                              % meridional Mach
    Re1  = S.rho*f.v1*C/S.mu;                      % chord Reynolds number

    % --- circulation, mean angle, lift
    Gam  = (tand(a1) - tand(a2))*cosd(a1)/sg;
    tanM = (tand(a1) + tand(a2))/2;
    cosM = 1/sqrt(1 + tanM^2);
    cL   = 2/sg*cosM*(tand(a1) - tand(a2));

    % --- equivalent diffusion ratio (Koch-Smith)
    Athr_A1 = 1 - (1 - hr)/3;                      % A_throat/A1, constant mean radius -> A2/A1 = hB2/hB1
    Astar   = (1 - K2*sg*tc)/cosd((a1 + a2)/2)*Athr_A1;
    rho_r   = 1 - Max1^2/(1 - Max1^2)*(1 - Astar - K1*sg*Gam*tand(a1)/cosd(a1));
    DFeq    = f.v1/f.v2*(1 + K3*tc + K4*Gam) ...
              *sqrt((sind(a1) - K1*sg*Gam)^2 + (cosd(a1)/(Astar*rho_r))^2);
    if DFeq >= 2.6
        warning('cascadeLoss:DFeq', 'DF_eq = %.2f >= 2.6: theta/C correlation singular, loss invalid.', DFeq);
    end

    % --- base boundary-layer values
    th0 = 2.644e-3*DFeq - 1.519e-4 + 6.713e-3/(2.60 - DFeq);
    if DFeq <= 2
        H0 = (0.91 + 0.35*DFeq)*(1 + 0.48*(DFeq - 1)^4 + 0.21*(DFeq - 1)^6);
    else
        H0 = 2.7209;
    end

    % --- correction factors
    n   = 2.853 + DFeq*(-0.97747 + 0.19477*DFeq);
    zM  = 1 + (0.11757 - 0.16983*DFeq)*Ma1^n;
    zH  = 0.53/hr + 0.47;                          % hB1/hB2 = 1/hr
    Recr   = 100*C/g.ks;
    Re_eff = min(Re1, Recr);                       % Re1 <= Recr -> Re1 ; Re1 > Recr -> Recr
    if Re_eff >= 2e5
        zRe = (1e6/Re_eff)^0.166;
    else
        zRe = 1.30626*(2e5/Re_eff)^0.5;
    end
    xM  = 1 + (1.0725 + DFeq*(-0.8671 + 0.18043*DFeq))*Ma1^1.8;
    xH  = 1 + (1/hr - 1)*(0.0026*DFeq^8 - 0.024);
    xRe = (1e6/Re_eff)^0.06;

    thC = th0*zM*zH*zRe;                           % theta2/C
    HTE = H0*xM*xH*xRe;

    % --- profile loss (Lieblein)
    Yp = 2*thC*sg/cosd(a2)*(cosd(a1)/cosd(a2))^2*(2*HTE/(3*HTE - 1)) ...
         *(1 - thC*sg*HTE/cosd(a2))^(-3);

    % --- secondary (Howell), end wall (Aungier)
    Ys  = 0.018*sg*cosd(a1)^2/cosM^3*cL^2;
    Yew = 0.0146*(C/hB)*(cosd(a1)/cosd(a2))^2;

    % --- shock
    if Ma1 >= 1
        Ysh = 0.32*Ma1^2 - 0.62*Ma1 + 0.30;
    else
        Ysh = 0;
    end

    % --- tip clearance (Yaras-Sjolander)
    Ytip = 1.4*KE*sg*(g.tau/hB)*cosd(a1)^2/cosM^3*cL^1.5;
    Ygap = 0.0049*KG*sg*(C/hB)*sqrt(cL)/cosM;
    Ytc  = Ytip + Ygap;

    Y.p = Yp;  Y.s = Ys;  Y.ew = Yew;  Y.shock = Ysh;  Y.tc = Ytc;
    Y.tot = Yp + Ys + Yew + Ysh + Ytc;
    Y.DFeq = DFeq;  Y.Gam = Gam;  Y.cL = cL;  Y.Astar = Astar;
    Y.thC = thC;    Y.HTE = HTE;  Y.Ma1 = Ma1;  Y.Re1 = Re1;  Y.Recr = Recr;
    Y.hr = hr;      Y.hB = hB;
end

%% ------------------------------------------------------------
%  STAGE THERMODYNAMICS + LOSSES + EFFICIENCIES  (Sect. 4.5.6)
%  The losses fix the entropy rise; the Euler work fixes the enthalpy.
%  Blade-height ratios hB2/hB1, hB3/hB2 come from continuity at constant
%  mean radius and depend on the loss-based densities -> fixed-point loop.
% -------------------------------------------------------------
