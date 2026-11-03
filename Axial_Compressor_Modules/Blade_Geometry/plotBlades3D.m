function plotBlades3D(rows, geo)

    figure('Name', '3D rotor and stator', 'Color', 'w', 'Position', [100 100 620 520]);   % window size
    hold on;
    gap = 0.5*rows.rotor{1}.chord;                          % axial gap rotor -> stator

    [xr, h1] = drawBladeRow3D(rows.rotor, 0, [0.00 0.45 0.74], geo.blades_3d);
    [xs, h2] = drawBladeRow3D(rows.stator, xr + gap, [0.85 0.33 0.10], geo.blades_3d);

    rh = rows.rotor{1}.r;                                   % hub cylinder
    [cx, cy, cz] = cylinder(rh, 120);
    surf(cz*xs, cx, cy, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.6);

    grid on;  box on;  view(35, 20);
    axis equal;  axis vis3d;                                % same scale in x, y, z
    L = [xlim; ylim; zlim];                                 % cubic frame: x, y, z share the same span
    ctr = mean(L, 2);  hs = max(diff(L, [], 2))/2;
    xlim(ctr(1) + [-hs hs]);  ylim(ctr(2) + [-hs hs]);  zlim(ctr(3) + [-hs hs]);
    pbaspect([1 1 1]);  daspect([1 1 1]);
    xlabel('x axial (m)');  ylabel('y (m)');  zlabel('z (m)');
    title('Rotor (blue) and stator (orange)');
    legend([h1 h2], {'Rotor', 'Stator'}, 'Location', 'northeast');
    camlight('headlight');  lighting gouraud;  material dull;
end
