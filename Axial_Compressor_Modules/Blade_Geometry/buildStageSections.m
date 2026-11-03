function rowsBB = buildStageSections(inp, geo, blade, rad)
    pct = geo.bb_span_pct(:).';
    if any(pct < 0 | pct > 100), error('geo.bb_span_pct must lie between 0 and 100.'); end
    g2 = geo;  g2.span_stations = pct/100;
    for nm = {'rotor', 'stator'}
        tc = g2.(nm{1}).tc;
        if numel(tc) > 1                                   % per-section t/c -> re-sample on the new spans
            g2.(nm{1}).tc = interp1(geo.span_stations, tc, g2.span_stations, 'pchip', 'extrap');
        end
    end
    rowsBB = buildBladeRows(inp, g2, blade, rad);
end

%% ------------------------------------------------------------
%  STAGE BLADE-TO-BLADE VIEW (rotor + stator in one axes per span)
%  Common frame: +y = direction of positive beta (opposite to rotation), so the
%  stator, whose alpha is positive in the rotation direction, is mirrored in y.
% -------------------------------------------------------------
