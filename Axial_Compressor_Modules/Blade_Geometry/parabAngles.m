function [chi1, chi2, theta, b] = parabAngles(a, b, theta)
    if ~(a > 0.25 && a < 0.75), error('Parabolic camberline needs 0.25 < a/c < 0.75 (got %.3f).', a); end
    if isempty(b)
        T = tand(theta);
        b = (sqrt(1 + (4*T)^2*(a - a^2 - 3/16)) - 1)/(4*T);
    end
    chi1  = atand(4*b/(4*a - 1));
    chi2  = atand(4*b/(3 - 4*a));
    theta = chi1 + chi2;
end

%% ------------------------------------------------------------
%  Camberline (chord frame, cosine-spaced in x)
% -------------------------------------------------------------
