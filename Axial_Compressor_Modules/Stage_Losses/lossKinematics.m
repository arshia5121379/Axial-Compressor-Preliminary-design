function K = lossKinematics(inp, stage, stator, rad, inlet, source)

    switch lower(source)
        case 'meanline'
            Cz = inp.inlet.Cz;
            K.U    = stage.Um;     K.rm = inlet.rm;     K.hB1 = inlet.h;
            K.cx   = [Cz Cz Cz];                        % axial velocity, stations 1-3
            K.cth  = [0 stage.Ctheta2 0];               % whirl, stations 1-3
            K.c    = [Cz stage.C2 Cz];                  % absolute velocity
            K.w1   = stage.W1;     K.w2 = stage.W2;
            K.beta1 = stage.beta1; K.beta2 = stage.beta2;
            K.alpha2 = stage.alpha2;  K.alpha3 = stator.alpha3;

        case 'midspan'
            i = rad.imid;
            K.U    = rad.U(i);     K.rm = rad.r(i);     K.hB1 = rad.rt - rad.rh;
            K.cx   = [rad.st1.u(i) rad.st2.u(i) rad.st3.u(i)];
            K.cth  = [rad.st1.v(i) rad.st2.v(i) rad.st3.v(i)];
            K.c    = [rad.st1.C(i) rad.st2.C(i) rad.st3.C(i)];
            K.w1   = rad.st1.W(i); K.w2 = rad.st2.W(i);
            K.beta1 = rad.st1.beta(i); K.beta2 = rad.st2.beta(i);
            K.alpha2 = rad.st2.alpha(i); K.alpha3 = rad.st3.alpha(i);

        otherwise
            error('inp.loss.source must be ''meanline'' or ''midspan''.');
    end
end

%% ------------------------------------------------------------
%  ONE CASCADE: all pressure-loss coefficients (Sect. 4.5.1 - 4.5.5)
%  g : geometry  (sigma, C, tc = tmax/C, hB1, tau [m], ks)
%  f : flow      (ang1, ang2 [deg], v1, v2 [m/s], cx1, hr = hB2/hB1)
%  S : REFPROP static state at the cascade inlet
% -------------------------------------------------------------
