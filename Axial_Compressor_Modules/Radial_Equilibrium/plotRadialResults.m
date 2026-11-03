function plotRadialResults(rad, b3)

    figure('Name', ['Radial distributions - ' rad.model], 'Color', 'w', 'Position', [60 60 1250 650]);
    r = rad.r;

    subplot(2,3,1); plot(r, rad.st1.u, 'b-', r, rad.st2.u, 'r-', r, rad.st3.u, 'g--', 'LineWidth', 1.5);
    grid on; xlabel('r (m)'); ylabel('Axial velocity (m/s)'); title('Axial velocity');
    legend('u_1', 'u_2', 'u_3', 'Location', 'best');

    subplot(2,3,2); plot(r, rad.st1.v, 'b-', r, rad.st2.v, 'r-', r, rad.st3.v, 'g--', 'LineWidth', 1.5);
    grid on; xlabel('r (m)'); ylabel('Whirl velocity (m/s)'); title('Tangential velocity');
    legend('v_1', 'v_2', 'v_3', 'Location', 'best');

    subplot(2,3,3); plot(r, rad.R, 'k-', r, rad.R_cu, 'm--', 'LineWidth', 1.5);
    grid on; xlabel('r (m)'); ylabel('R'); title('Degree of reaction');
    legend('variable u', 'constant u', 'Location', 'best');

    subplot(2,3,4); plot(r, rad.st1.alpha, 'b-', r, rad.st2.alpha, 'r-', r, rad.st3.alpha, 'g-', ...
                         r, rad.st1.beta, 'b--', r, rad.st2.beta, 'r--', 'LineWidth', 1.5);
    grid on; xlabel('r (m)'); ylabel('Angle (deg)'); title('Absolute (solid) / relative (dashed) angles');
    legend('\alpha_1', '\alpha_2', '\alpha_3', '\beta_1', '\beta_2', 'Location', 'best');

    subplot(2,3,5); plot(r, rad.work/1e3, 'k-', 'LineWidth', 1.5);
    grid on; xlabel('r (m)'); ylabel('Euler work (kJ/kg)'); title('Euler work');
    ylim([0.9 1.1]*rad.dht/1e3);

    subplot(2,3,6); plot(r, b3.kappa1, 'b-', r, b3.kappa2, 'r-', r, b3.stagger, 'k-', r, b3.camber, 'm--', 'LineWidth', 1.5);
    grid on; xlabel('r (m)'); ylabel('Angle (deg)'); title('Rotor blade metal angles');
    legend('\kappa_1', '\kappa_2', 'stagger', 'camber', 'Location', 'best');

    sgtitle(['Swirl model: ' strrep(rad.model, '_', ' ')]);
end

%% ------------------------------------------------------------
%  PLOTS: MODEL COMPARISON
% -------------------------------------------------------------
