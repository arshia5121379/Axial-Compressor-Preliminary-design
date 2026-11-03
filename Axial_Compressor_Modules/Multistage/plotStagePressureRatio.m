function plotStagePressureRatio(ms)

    k = 1:ms.z;
    figure('Name', 'Stage pressure ratio', 'Color', 'w', 'Position', [80 80 760 480]);
    plot(k, ms.plan.PR_s, 'o-', 'LineWidth', 1.6, 'MarkerSize', 7); hold on;
    plot(k, [ms.stage.PR], 's--', 'LineWidth', 1.6, 'MarkerSize', 7);
    grid on; box on;
    xlabel('Stage number'); ylabel('Stage pressure ratio \pi_s');
    xlim([0.5 ms.z + 0.5]); xticks(k);
    legend('Planned: equal \DeltaT_t per stage', 'Stage-by-stage result (loss model)', 'Location', 'northeast');
    title(sprintf('Stage pressure ratio vs stage number  (z = %d, overall PR = %.2f)', ms.z, ms.overall.PR));
end

%% ------------------------------------------------------------
%  FIGURE: STAGE-BY-STAGE DISTRIBUTIONS
% -------------------------------------------------------------
