function eta_p = polytropicEfficiencyFromLoss(L)

    PRtt = L.PR_tt;
    Tt1 = L.total.Tt1;
    Tt3 = L.total.Tt3;
    gamma_bar = L.total.gamma_bar;

    if PRtt <= 1 || Tt3 <= Tt1 || gamma_bar <= 1
        error('Invalid total conditions for polytropic-efficiency update: PR_tt=%.6g, Tt1=%.3f K, Tt3=%.3f K, gamma=%.4f.', ...
              PRtt, Tt1, Tt3, gamma_bar);
    end

    eta_p = ((gamma_bar - 1)/gamma_bar)*log(PRtt)/log(Tt3/Tt1);
end

%% ------------------------------------------------------------
%  PRINT OUTER EFFICIENCY ITERATION HISTORY
% -------------------------------------------------------------
