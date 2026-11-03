function [xmax, h] = drawBladeRow3D(S, x0, col, nmax)

    ns = numel(S);
    if ns < 2, error('3D view needs at least 2 radial sections (geo.span_stations).'); end
    M  = size(S{1}.up, 2) + size(S{1}.lo, 2) + 1;
    Xs = zeros(M, ns);  Ts = Xs;  rs = zeros(1, ns);
    for k = 1:ns
        P = [S{k}.up, fliplr(S{k}.lo), S{k}.up(:,1)];       % closed contour LE->TE->LE
        Xs(:,k) = P(1,:).';  Ts(:,k) = P(2,:).';  rs(k) = S{k}.r;
    end
    rq  = linspace(rs(1), rs(end), 25);
    Xq  = interp1(rs, Xs.', rq, 'pchip').';
    Tq  = interp1(rs, Ts.', rq, 'pchip').';
    Rq  = repmat(rq, M, 1);
    Phi = Tq./Rq;

    mid = ceil(ns/2);
    N   = round(2*pi*S{mid}.r/S{mid}.pitch);                % blades in the wheel
    nb  = min(N, nmax);
    for j = 0:nb-1
        ph = Phi + 2*pi*j/N;
        X = Xq + x0;  Y = Rq.*cos(ph);  Z = Rq.*sin(ph);
        hs = surf(X, Y, Z, 'FaceColor', col, 'EdgeColor', 'none');
        fill3(X(:,1),   Y(:,1),   Z(:,1),   col, 'EdgeColor', 'none');   % hub cap
        fill3(X(:,end), Y(:,end), Z(:,end), col, 'EdgeColor', 'none');   % tip cap
        if j == 0, h = hs; end
    end
    xmax = x0 + max(Xq(:));
end

%% ------------------------------------------------------------
%  Rotor + stator sections at arbitrary span percentages
% -------------------------------------------------------------
