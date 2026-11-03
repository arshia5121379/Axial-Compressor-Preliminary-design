function exportDesignResults(outputDir, inp, geo, calc, etaIter, radAll, rows, rowsBB, ms)

    % Save every figure that is still open, including figures created by
    % the radial, blade-cascade, 3-D, blade-to-blade and multistage routines.
    figs = findall(0, 'Type', 'figure');
    if isempty(figs)
        fprintf('No figures were generated in this run.\n');
    else
        for k = 1:numel(figs)
            fig = figs(k);
            figName = get(fig, 'Name');
            if isempty(figName)
                figName = sprintf('Figure_%02d', k);
            end
            safeName = regexprep(char(figName), '[^a-zA-Z0-9_-]', '_');
            if isempty(safeName)
                safeName = sprintf('Figure_%02d', k);
            end
            pngPath = fullfile(outputDir, sprintf('%02d_%s.png', k, safeName));
            try
                set(fig, 'Color', 'w');
                set(fig, 'InvertHardcopy', 'off');
                print(fig, pngPath, '-dpng', '-r200');
                fprintf('Saved PNG: %s\n', pngPath);
            catch ME
                warning('Export:FigureFailed', 'Could not save figure "%s": %s', figName, ME.message);
            end
        end
    end

    % Write all primary numerical outputs to one human-readable TXT file.
    txtPath = fullfile(outputDir, 'all_design_output_data.txt');
    fid = fopen(txtPath, 'w');
    if fid < 0
        error('Export:FileOpen', 'Cannot create output TXT file: %s', txtPath);
    end
    fileCleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>

    fprintf(fid, '============================================================\n');
    fprintf(fid, ' AXIAL COMPRESSOR DESIGN - COMPLETE NUMERICAL OUTPUT\n');
    fprintf(fid, ' Generated: %s\n', datestr(now, 31));
    fprintf(fid, '============================================================\n\n');
    fprintf(fid, 'The console_output.txt file contains the formatted command-window report.\n');
    fprintf(fid, 'This file contains recursively exported input, calculation, geometry,\n');
    fprintf(fid, 'radial-equilibrium, convergence, loss and multistage data.\n\n');

    writeValueToTxt(fid, 'INPUTS_inp', inp, 0);
    writeValueToTxt(fid, 'GEOMETRY_SETTINGS_geo', geo, 0);
    writeValueToTxt(fid, 'CALCULATION_RESULTS_calc', calc, 0);
    writeValueToTxt(fid, 'EFFICIENCY_ITERATION_etaIter', etaIter, 0);
    writeValueToTxt(fid, 'ALTERNATIVE_SWIRL_MODELS_radAll', radAll, 0);
    writeValueToTxt(fid, 'BLADE_ROWS_rows', rows, 0);
    writeValueToTxt(fid, 'BLADE_TO_BLADE_SECTIONS_rowsBB', rowsBB, 0);
    writeValueToTxt(fid, 'MULTISTAGE_RESULTS_ms', ms, 0);

    fprintf(fid, '\n============================================================\n');
    fprintf(fid, ' END OF COMPLETE NUMERICAL OUTPUT\n');
    fprintf(fid, '============================================================\n');
    fprintf('Saved TXT data: %s\n', txtPath);
end
