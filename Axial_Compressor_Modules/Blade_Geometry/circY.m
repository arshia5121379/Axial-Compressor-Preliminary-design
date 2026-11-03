function y = circY(x, c, theta)                       % Section 3, x in [0,c]
    if theta < 1e-8, y = zeros(size(x)); return; end
    R  = c/(2*sind(theta/2));
    yC = -R*cosd(theta/2);
    y  = yC + sqrt(R^2 - (x - c/2).^2);
end
