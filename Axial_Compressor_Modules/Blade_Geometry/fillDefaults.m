function g = fillDefaults(g, d)
    for f = fieldnames(d).'
        if ~isfield(g, f{1}) || isempty(g.(f{1})), g.(f{1}) = d.(f{1}); end
    end
end

%% ------------------------------------------------------------
%  ONE BLADE SECTION: angles -> camber -> profile -> cascade frame
% -------------------------------------------------------------
