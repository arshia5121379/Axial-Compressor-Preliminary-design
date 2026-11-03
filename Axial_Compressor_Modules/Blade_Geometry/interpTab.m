function v = interpTab(x, y, xq)                      % PCHIP over the available points, no extrapolation
    ok = ~isnan(y);
    xq = min(max(xq, min(x(ok))), max(x(ok)));        % only clips round-off
    v  = pchip(x(ok), y(ok), xq);
end

%% ------------------------------------------------------------
%  PRINT BLADE GEOMETRY
% -------------------------------------------------------------
