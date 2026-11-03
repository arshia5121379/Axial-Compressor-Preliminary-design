function M = getSwirlModel(name)

    switch lower(name)

        case 'free_vortex'          % n = -1 : v = (a -/+ b) rm/r
            M.n  = -1;
            M.v1 = @(x,a,b) (a-b)./x;
            M.v2 = @(x,a,b) (a+b)./x;
            M.I1 = @(x,a,b) zeros(size(x));
            M.I2 = @(x,a,b) zeros(size(x));
            M.R  = @(x,a,b,wrm) -(a/wrm)./x.^2;

        case 'exponential'          % n = 0 : v = a -/+ b rm/r
            M.n  = 0;
            M.v1 = @(x,a,b) a - b./x;
            M.v2 = @(x,a,b) a + b./x;
            M.I1 = @(x,a,b) a^2*log(x) + a*b*(1./x - 1);
            M.I2 = @(x,a,b) a^2*log(x) - a*b*(1./x - 1);
            M.R  = @(x,a,b,wrm) a/wrm - 2*(a/wrm)./x;

        case 'first_power'          % n = 1 : v = a r/rm -/+ b rm/r
            M.n  = 1;
            M.v1 = @(x,a,b) a*x - b./x;
            M.v2 = @(x,a,b) a*x + b./x;
            M.I1 = @(x,a,b) a^2*(x.^2 - 1) - 2*a*b*log(x);
            M.I2 = @(x,a,b) a^2*(x.^2 - 1) + 2*a*b*log(x);
            M.R  = @(x,a,b,wrm) 2*(a/wrm)*log(x) - a/wrm;

        otherwise
            error('Unknown swirl_model "%s". Use free_vortex, exponential or first_power.', name);
    end
    M.name = lower(name);
end

%% ------------------------------------------------------------
%  u^2 AND v AT ANY RADIUS  (side 1 = rotor inlet/stator exit, 2 = rotor exit)
% -------------------------------------------------------------
