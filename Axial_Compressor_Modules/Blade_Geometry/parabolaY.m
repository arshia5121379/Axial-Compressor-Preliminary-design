function y = parabolaY(x, c, a, b)                    % Section 4, implicit conic solved in closed form
    if b < 1e-12, y = zeros(size(x)); return; end
    A = (c-2*a)^2/(4*b^2);  B = (c-2*a)/b;  C = (c^2 - 4*a*c)/(4*b);
    p = B*x - C;  q = x.^2 - c*x;                     % A*y^2 + p*y + q = 0
    sg = sign(p);  sg(sg == 0) = 1;
    y = -2*q./(p + sg.*sqrt(p.^2 - 4*A*q));           % small root; no singularity at a/c = 0.5 (A = 0)
end

%% ------------------------------------------------------------
%  Thickness mapped on the camberline by normalised arc length, offset along the normal
% -------------------------------------------------------------
