function plotStageBB(rowsBB, geo)

    n  = numel(rowsBB.rotor);
    nb = geo.n_blades_plot;
    cR = [0.00 0.45 0.74];  cS = [0.85 0.33 0.10];  cG = [0 0.55 0];  cA = [0.5 0 0.6];
    figure('Name', 'Stage blade-to-blade', 'Color', 'w', 'Position', [60 60 620*n 620]);

    for k = 1:n
        R = rowsBB.rotor{k};  S = rowsBB.stator{k};
        subplot(1, n, k);  hold on;
        jm  = floor(nb/2);
        xs0 = max([R.up(1,:) R.lo(1,:)]) + 0.5*R.chord;          % stator LE axial position
        ys0 = R.TE(2) + (xs0 - R.TE(1))*tand(-S.flow_in);        % on the absolute streamline from the rotor TE

        for j = 0:nb-1
            offR = (j - jm)*R.pitch;
            fill([R.up(1,:) fliplr(R.lo(1,:))], [R.up(2,:) fliplr(R.lo(2,:))] + offR, cR, ...
                 'FaceAlpha', 0.35, 'EdgeColor', cR, 'LineWidth', 1.2);
            plot(R.cam(1,:), R.cam(2,:) + offR, 'k--', 'LineWidth', 0.8);

            offS = ys0 + (j - jm)*S.pitch;
            fill(xs0 + [S.up(1,:) fliplr(S.lo(1,:))], -[S.up(2,:) fliplr(S.lo(2,:))] + offS, cS, ...
                 'FaceAlpha', 0.35, 'EdgeColor', cS, 'LineWidth', 1.2);
            plot(xs0 + S.cam(1,:), -S.cam(2,:) + offS, 'k--', 'LineWidth', 0.8);
        end

        L  = 0.6*R.chord;
        TS = [xs0 + S.TE(1), ys0 - S.TE(2)];                     % stator TE
        quiver(-L*cosd(R.flow_in), -L*sind(R.flow_in), L*cosd(R.flow_in), L*sind(R.flow_in), 0, ...
               'Color', cG, 'LineWidth', 1.5, 'MaxHeadSize', 0.7);               % rotor inlet (relative, beta1)
        quiver(R.TE(1), R.TE(2), L*cosd(R.flow_out), L*sind(R.flow_out), 0, ...
               'Color', cG, 'LineWidth', 1.5, 'MaxHeadSize', 0.7);               % rotor outlet (relative, beta2)
        quiver(R.TE(1), R.TE(2), L*cosd(S.flow_in), -L*sind(S.flow_in), 0, ...
               'Color', cA, 'LineWidth', 1.5, 'MaxHeadSize', 0.7);               % absolute flow leaving rotor (alpha2)
        quiver(TS(1), TS(2), L*cosd(S.flow_out), -L*sind(S.flow_out), 0, ...
               'Color', cA, 'LineWidth', 1.5, 'MaxHeadSize', 0.7);               % stator outlet (absolute, alpha3)
        quiver(-0.9*R.chord, 0.2*R.pitch, 0, -0.6*R.pitch, 0, 'k', 'LineWidth', 1.5, 'MaxHeadSize', 0.7);
        text(-0.85*R.chord, -0.1*R.pitch, 'U', 'FontWeight', 'bold');            % blade motion
        plot(0, 0, 'ko', R.TE(1), R.TE(2), 'ks', xs0, ys0, 'ko', TS(1), TS(2), 'ks', 'MarkerFaceColor', 'k');

        axis equal;  grid on;  box on;
        xlabel('x axial (m)');  ylabel('y tangential (m)');
        title(sprintf('Span %.0f %%  (r = %.3f m)   rotor: %s | stator: %s', ...
              100*R.span, R.r, R.profile, S.profile));
    end
    sgtitle('Stage blade-to-blade: blue rotor, orange stator  (green: relative flow, purple: absolute flow, U: blade motion)');
end

%% ############################################################
%            STAGE LOSS + EFFICIENCY MODULE (REFPROP)
% ############################################################

%% ------------------------------------------------------------
%  REFPROP WRAPPER  (the ONLY place refpropm is called)
%  Inputs in SI (Pa, J/kg, K); k1/k2 in {'T','P','H','S','D'}.
%  refpropm convention: SI, mass basis, pressure in kPa -> rp.Pscale converts.
%  To use another REFPROP interface, edit only this function.
% -------------------------------------------------------------
