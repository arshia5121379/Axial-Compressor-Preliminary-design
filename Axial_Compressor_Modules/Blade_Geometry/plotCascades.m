function plotCascades(rows, geo)
    plotBladeRow(rows.rotor,  'Rotor',  geo.n_blades_plot, [0.00 0.45 0.74]);
    plotBladeRow(rows.stator, 'Stator', geo.n_blades_plot, [0.85 0.33 0.10]);
end
