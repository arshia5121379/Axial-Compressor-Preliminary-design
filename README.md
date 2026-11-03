# Axial Compressor Design V5 — MATLAB

A free, modular MATLAB source code for the preliminary design and analysis of axial compressors.

The project combines mean-line and stage calculations, radial-equilibrium analysis, blade-row geometry generation, aerodynamic loss estimation, and an optional multistage design workflow. It also provides automatic visualization and export of calculation results.

## Main Features

- **Stage design:** Thermodynamic calculations, velocity triangles, rotor and stator parameters.
- **Efficiency estimation:** Iterative polytropic-efficiency calculation using a Lozza-based initial estimate and loss-based correction.
- **Radial equilibrium:** Radial flow-property distributions and comparison of alternative swirl models.
- **Aerodynamic losses:** Rotor and stator cascade loss estimation.
- **Blade geometry:** Generation and visualization of rotor and stator blade sections.
- **Blade profiles:** NACA65, DCA, A4K6, and C4 profile options.
- **Multistage design:** Optional stage-stacking algorithm for distributing the required overall pressure ratio.
- **Automatic export:** PNG figures and TXT files containing calculation results.

## Current Limitations

The current version uses a **constant-tip-radius annulus configuration**.

The following annulus-area configurations have not yet been implemented:

1. Constant mid-span radius.
2. Constant tip radius (currently implemented).
3. Variable hub and tip radii.

Additionally, the current version does not include an Inlet Guide Vane (IGV) model.

Consequently, the code is currently more suitable for preliminary design and investigation of **subsonic axial compressors**.

## Project Structure

```text
Axial_Compressor_Design_V5_Modular_Project/
├── Axial_Compressor_Design_V5_Modular.m
├── Original_Monolithic_Version.m
└── Axial_Compressor_Modules/
    ├── Core_Design/
    ├── Radial_Equilibrium/
    ├── Blade_Geometry/
    ├── Stage_Losses/
    ├── Multistage/
    ├── Export/
    └── README_MODULES.txt
```

The modular version contains 66 separate function files, organized according to their responsibilities.

## Requirements

- MATLAB R2016b or newer is recommended.
- Keep the original folder structure intact.

## How to Run

1. Download or clone the repository.
2. Extract the project while preserving its folder structure.
3. Open MATLAB.
4. Set the Current Folder to the project directory.
5. Run:

```matlab
Axial_Compressor_Design_V5_Modular
```

The main script automatically adds the module folders and their subfolders to the MATLAB path.

## Configuration

The main design inputs are defined in:

```text
Axial_Compressor_Modules/Core_Design/defineInputs.m
```

Blade geometry and visualization settings can be adjusted near the beginning of the main script.

## Generated Results

Each execution creates a timestamped output folder containing:

- `console_output.txt` — command-window output.
- `all_design_output_data.txt` — exported input and calculation data.
- `Figure_*.png` — generated visualization figures.

## Future Development and Contributions

This project is shared as a free MATLAB source code, and contributions are very welcome.

Some important directions for future development include:

- Implementing different annulus-area configurations.
- Adding Inlet Guide Vane (IGV) consideration.
- Improving the aerodynamic and thermodynamic models.
- Adding validation cases and comparisons with published references.
- Improving blade geometry and visualization capabilities.

I would be happy to see contributors create new branches, implement these upgrades, test new models, and help develop this project into a more comprehensive axial-compressor design tool.

Feel free to open an issue or submit a pull request.

## Validation Notice

The project has been modularized, but it has not yet been independently validated through a complete MATLAB/Octave execution in this release. Please verify the results against suitable reference cases before using them for engineering decisions.

## License

A formal open-source license has not yet been assigned. Please check the repository license before redistribution or reuse.
