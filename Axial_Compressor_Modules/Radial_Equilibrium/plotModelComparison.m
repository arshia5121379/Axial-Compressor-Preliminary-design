function plotModelComparison(radAll)

    figure('Name', 'Swirl model comparison', 'Color', 'w', 'Position', [100 100 1250 650]);
    fields = {'R', 'u1', 'u2', 'v1', 'v2', 'beta1'};
    titles = {'Degree of reaction', 'Axial velocity u_1 (m/s)', 'Axial velocity u_2 (m/s)', ...
              'Whirl v_1 (m/s)', 'Whirl v_2 (m/s)', 'Relative inflow angle \beta_1 (deg)'};
    for p = 1:6
        subplot(2,3,p); hold on;
        for k = 1:numel(radAll)
            q = radAll{k};
            switch fields{p}
                case 'R',     y = q.R;
                case 'u1',    y = q.st1.u;
                case 'u2',    y = q.st2.u;
                case 'v1',    y = q.st1.v;
                case 'v2',    y = q.st2.v;
                case 'beta1', y = q.st1.beta;
            end
            plot(q.r, y, 'LineWidth', 1.5, 'DisplayName', strrep(q.model, '_', ' '));
        end
        grid on; xlabel('r (m)'); title(titles{p});
        if p == 1, legend('Location', 'best'); end
    end
    sgtitle('Swirl-model comparison');
end

%% ############################################################
%                 BLADE GEOMETRY MODULE
%  Flow (x axial, y tangential), angles measured from axial.
%  Chord frame: x along chord (LE at 0), y normal, camber bulges to +y.
%  kappa1 = gamma + chi1 ,  kappa2 = gamma - chi2 ,  theta = chi1 + chi2.
% ############################################################

%% ------------------------------------------------------------
%  All sections of rotor and stator from the radial-equilibrium results
% -------------------------------------------------------------
