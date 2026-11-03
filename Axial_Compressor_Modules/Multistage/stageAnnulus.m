function A = stageAnnulus(op, Cz, Tt, pt, rt)

    g  = op.gamma;  cp = op.cp;  Rg = (g-1)*cp/g;
    A.T    = Tt - Cz^2/(2*cp);
    A.a    = sqrt((g-1)*cp*A.T);
    A.Mz   = Cz/A.a;
    A.P    = pt*(A.T/Tt)^(g/(g-1));
    A.rho  = A.P/(Rg*A.T);
    A.area = op.mdot/(A.rho*Cz);
    if rt^2 - A.area/pi <= 0
        error('Annulus collapses: A/pi = %.4g exceeds rt^2 = %.4g (Tt = %.1f K, pt = %.1f kPa).', ...
              A.area/pi, rt^2, Tt, pt/1e3);
    end
    A.rt = rt;
    A.rh = sqrt(rt^2 - A.area/pi);
    A.rm = (rt + A.rh)/2;
    A.h  = rt - A.rh;
end
