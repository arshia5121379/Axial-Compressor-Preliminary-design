function ms = marchStages(inp, geo, plan, rt)

    cfg = inp.multi;
    z   = plan.z;
    Cz  = inp.inlet.Cz;
    rp  = struct('fluid', inp.loss.fluid, 'Pscale', inp.loss.Pscale);

    Tt_in = inp.op.Tt1;
    pt_in = inp.op.Pt1;

    for i = 1:z

        % ---- i-stage p/T :  p_in,i , T_in,i , p_out,i
        si = inp;
        si.stage_run = true;                     % Lozza uses this stage's own dh_is
        si.op.Tt1 = Tt_in;
        si.op.Pt1 = pt_in;
        si.op.PR  = plan.PR_s(i);                % stage target  -> p_out,i = p_in,i*pi_s,i
        p_out_target = pt_in*plan.PR_s(i);

        % ---- stage annulus (continuity, constant Cz and r_tip)
        ann = stageAnnulus(inp.op, Cz, Tt_in, pt_in, rt);
        si.inlet.Mz1   = ann.Mz;
        si.inlet.rh_rt = ann.rh/rt;

        % ---- i-stage input parameters (phi, psi, R follow from Cz, U, De Haller)
        si.rotor.DH_target = pickStage(cfg.DH_target, i, inp.rotor.DH_target);

        % ---- other i-stage assumptions (AR_i, sigma_i)
        si.rotor.sigma  = pickStage(cfg.sigma_rotor,  i, inp.rotor.sigma);
        si.stator.sigma = pickStage(cfg.sigma_stator, i, inp.stator.sigma);
        AR_i = pickStage(cfg.AR, i, []);
        if ~isempty(AR_i), si.rotor.chord = ann.h/AR_i; end

        % ---- i-stage calculation (Fig. 4.15 block: eta loop, kinematics,
        %      thermodynamics, geometry, losses)
        try
            [si, q, h] = iterateStageEfficiency(si, geo);
        catch ME
            error('Multistage:StageFailed', 'Stage %d failed: %s', i, ME.message);
        end
        if ~h.converged
            warning('Multistage:EtaNoConv', 'Stage %d: eta_p loop did not converge.', i);
        end

        L = q.loss;
        rec.i          = i;
        rec.Tt_in      = Tt_in;
        rec.pt_in      = pt_in;
        rec.Tt_out     = L.total.Tt3;
        rec.pt_out     = L.p.p3t;
        rec.p_out_target = p_out_target;
        rec.PR_plan    = plan.PR_s(i);
        rec.PR         = L.p.p3t/pt_in;
        rec.dTt        = L.total.Tt3 - Tt_in;
        rec.eta_p      = h.eta_final;
        rec.eta_TT     = L.eta.TT;
        rec.eta_start  = h.eta_initial;
        rec.n_iter     = numel(h.iteration);
        rec.converged  = h.converged;
        rec.rt         = q.inlet.rt;
        rec.rh         = q.inlet.rh;
        rec.rm         = q.inlet.rm;
        rec.h          = q.inlet.h;
        rec.Um         = q.stage.Um;
        rec.phi        = q.extra.phi;
        rec.psi        = q.stage.psi;
        rec.R          = q.stage.Reaction;
        rec.Mr1        = q.stage.Mr1;
        rec.DH_rotor   = q.diffu.DH_rotor;
        rec.DF_rotor   = q.diffu.Dr;
        rec.DF_stator  = q.diffu.Ds;
        rec.chord      = si.rotor.chord;
        rec.AR         = q.extra.AR;
        rec.sigma_rotor  = si.rotor.sigma;
        rec.sigma_stator = si.stator.sigma;
        rec.Nrotor     = q.blade.N;
        rec.work       = L.work;
        rec.gamma_bar  = L.total.gamma_bar;
        rec.Re1        = L.rotor.Re1;
        rec.rpm        = q.stage.RPM;
        % Retain the stage-specific blade geometry for the complete-machine views.
        ms.stage(i)    = rec;

        % ---- next stage inlet = this stage outlet
        Tt_in = rec.Tt_out;
        pt_in = rec.pt_out;
    end

    % ---------- overall compressor data ----------
    S1t = rpState(rp, 'T', inp.op.Tt1, 'P', inp.op.Pt1);
    Sx  = rpState(rp, 'T', Tt_in,      'P', pt_in);
    Sis = rpState(rp, 'P', pt_in,      'S', S1t.s);

    O.PR      = pt_in/inp.op.Pt1;
    O.TR      = Tt_in/inp.op.Tt1;
    O.Tt_out  = Tt_in;
    O.pt_out  = pt_in;
    O.dTt     = Tt_in - inp.op.Tt1;
    O.gamma_bar = mean([ms.stage.gamma_bar]);
    O.eta_p   = ((O.gamma_bar-1)/O.gamma_bar)*log(O.PR)/log(O.TR);
    O.eta_is  = (Sis.h - S1t.h)/(Sx.h - S1t.h);
    O.w       = Sx.h - S1t.h;                        % total specific work (J/kg)
    O.power   = inp.op.mdot*O.w;                     % W
    O.work_euler = sum([ms.stage.work]);
    O.exit    = stageAnnulus(inp.op, Cz, Tt_in, pt_in, rt);
    O.Nrotor_total = sum([ms.stage.Nrotor]);
    O.rpm     = ms.stage(1).rpm;
    O.Utip    = inp.rotor.Utip;
    O.Uh_max  = max(2*pi*O.rpm/60*[ms.stage.rh]);    % highest hub speed (m/s)

    ms.overall = O;
    ms.plan    = plan;
    ms.z       = z;
    ms.Utip    = inp.rotor.Utip;
    ms.rt      = rt;
end

%% ------------------------------------------------------------
%  OUTER LOOP:  "New values n and/or z ?"
%  n = shaft speed (tip speed at fixed r_tip), z = number of stages.
% -------------------------------------------------------------
