function v = pickStage(x, i, default)
    if isempty(x),            v = default;
    elseif isscalar(x),       v = x;
    elseif i <= numel(x),     v = x(i);
    else
        error('A per-stage vector in inp.multi has %d entries but stage %d was requested.', numel(x), i);
    end
end

%% ------------------------------------------------------------
%  MARCH THROUGH z STAGES AT FIXED (n, z)       [i = 1 ... z]
% -------------------------------------------------------------
