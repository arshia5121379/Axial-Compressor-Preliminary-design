function gas = computeGasProperties(op)
    gas.R = (op.gamma-1)*op.cp/op.gamma;
end

%% ------------------------------------------------------------
%  INLET THERMODYNAMICS + ANNULUS GEOMETRY
% -------------------------------------------------------------
