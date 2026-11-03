function st = computeStator(inp, gas, stage) %#ok<INUSL>

    op = inp.op;

    st.Tt2    = op.Tt1 + stage.Um*stage.Ctheta2/op.cp;
    st.T2     = st.Tt2 - stage.C2^2/(2*op.cp);
    st.a2     = sqrt((op.gamma-1)*op.cp*st.T2);
    st.M2     = stage.C2/st.a2;
    st.alpha3 = 0;
end

%% ------------------------------------------------------------
%  REYNOLDS NUMBER
% -------------------------------------------------------------
