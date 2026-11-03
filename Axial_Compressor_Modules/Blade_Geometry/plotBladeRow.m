function plotBladeRow(S, name, nb, col)

    ns = numel(S);
    figure('Name', [name ' cascade'], 'Color', 'w', 'Position', [60 60 480*ns 620]);
    for k = 1:ns
        s = S{k};  subplot(1, ns, k);  hold on;
        jm = floor(nb/2);                                   % annotated blade (offset 0)
        for j = 0:nb-1
            off = (j - jm)*s.pitch;
            fill([s.up(1,:) fliplr(s.lo(1,:))], [s.up(2,:) fliplr(s.lo(2,:))] + off, col, ...
                 'FaceAlpha', 0.35, 'EdgeColor', col, 'LineWidth', 1.2);
            plot(s.cam(1,:), s.cam(2,:) + off, 'k--', 'LineWidth', 0.8);   % camberline
        end
        L = 0.6*s.chord;
        plot([0 s.TE(1)], [0 s.TE(2)], 'r-', 'LineWidth', 1.3);            % chord
        plot([0 0.5*s.chord], [0 0], 'k:');                                % axial reference
        plot([0 0], [0 s.pitch], 'b-o', 'LineWidth', 1.3);                 % pitch
        quiver(-L*cosd(s.flow_in), -L*sind(s.flow_in), L*cosd(s.flow_in), L*sind(s.flow_in), 0, ...
               'Color', [0 0.55 0], 'LineWidth', 1.5, 'MaxHeadSize', 0.7); % inlet direction
        quiver(s.TE(1), s.TE(2), L*cosd(s.flow_out), L*sind(s.flow_out), 0, ...
               'Color', [0 0.55 0], 'LineWidth', 1.5, 'MaxHeadSize', 0.7); % outlet direction
        plot(0, 0, 'ko', s.TE(1), s.TE(2), 'ks', 'MarkerFaceColor', 'k');  % LE / TE
        text(0.25*s.chord, -0.05*s.chord, sprintf('\\gamma = %.1f°', s.stagger));
        text(0.02*s.chord, 0.5*s.pitch, sprintf('s = %.3f m', s.pitch), 'Color', 'b');
        text(0.5*s.TE(1), 0.5*s.TE(2) - 0.04*s.chord, sprintf('c = %.3f m', s.chord), 'Color', 'r');
        axis equal;  grid on;  box on;
        xlabel('x axial (m)');  ylabel('y tangential (m)');
        title(sprintf('%s, span %.2f (r = %.3f m)', s.profile, s.span, s.r));
    end
    sgtitle([name ' cascade  (red: chord, blue: pitch, dashed: camberline, green: flow; angles + toward +y)']);
end

%% ------------------------------------------------------------
%  3D SOLID VIEW: rotor + stator in one window
%  Sections are interpolated along the span (PCHIP) and wrapped onto cylinders (phi = y/r).
% -------------------------------------------------------------
