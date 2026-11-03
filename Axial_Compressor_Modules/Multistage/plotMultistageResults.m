function plotMultistageResults(ms)

    S = ms.stage;  k = [S.i];
    figure('Name', 'Multistage results', 'Color', 'w', 'Position', [100 100 1250 650]);

    subplot(2,3,1); bar(k, [S.dTt]); grid on;
    xlabel('Stage'); ylabel('\DeltaT_t (K)'); title('Total temperature rise per stage');

    subplot(2,3,2); plot(k, [S.eta_p], 'o-', k, [S.eta_TT], 's--', 'LineWidth', 1.4); grid on;
    xlabel('Stage'); ylabel('Efficiency'); title('Stage efficiency');
    legend('\eta_p (stage)', '\eta_{TT} (stage)', 'Location', 'best');

    subplot(2,3,3); plot(k, [S.rt], 'b-o', k, [S.rm], 'k-o', k, [S.rh], 'r-o', 'LineWidth', 1.4); grid on;
    xlabel('Stage'); ylabel('Radius (m)'); title('Annulus at stage inlet');
    legend('tip', 'mean', 'hub', 'Location', 'best');

    subplot(2,3,4); plot(k, [S.phi], 'o-', k, [S.psi], 's-', k, [S.R], '^-', 'LineWidth', 1.4); grid on;
    xlabel('Stage'); ylabel('-'); title('Stage parameters'); legend('\phi', '\psi', 'R', 'Location', 'best');

    subplot(2,3,5);
    semilogy(k, [S.pt_in]/S(1).pt_in, 'o-', 'LineWidth', 1.4); hold on;
    plot(k, [S.Tt_in]/S(1).Tt_in, 's-', 'LineWidth', 1.4); grid on;
    xlabel('Stage'); ylabel('Ratio to compressor inlet'); title('Stage-inlet p_t and T_t');
    legend('p_t/p_{t1}', 'T_t/T_{t1}', 'Location', 'northwest');

    subplot(2,3,6); plot(k, [S.DF_rotor], 'o-', k, [S.DF_stator], 's-', k, [S.DH_rotor], '^-', 'LineWidth', 1.4); grid on;
    xlabel('Stage'); ylabel('-'); title('Diffusion factors / De Haller');
    legend('D rotor', 'D stator', 'W_2/W_1', 'Location', 'best');

    sgtitle(sprintf('Multistage compressor: z = %d, n = %.0f rpm, PR = %.2f', ms.z, ms.overall.rpm, ms.overall.PR));
end


%% ============================================================
%              EXPORT ALL RESULTS: PNG + TXT
% =============================================================
