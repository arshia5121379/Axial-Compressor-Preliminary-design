function Cl0 = Cl0FromTheta(prof, theta, g)
    if strcmp(prof,'A4K6')
        if strcmpi(g.a4k6_relation,'approx')
            Cl0 = tand(theta/4)*0.375/0.05515;
        else
            T = tand(theta);  k = 5.83^2;
            Cl0 = (-291.5 + sqrt(291.5^2 + 4*k*468.75*T^2))/(2*k*T);
        end
    else
        Cl0 = tand(theta/4)/0.1103;
    end
end

%% ------------------------------------------------------------
%  Parabolic arc: end angles from (a/c, theta) or (a/c, b/c)
% -------------------------------------------------------------
