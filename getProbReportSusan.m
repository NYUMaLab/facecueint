function p = getProbReportSusan(s, c, sig, b, model) 

    % morph level
    s_m = s(1);
    s_f = s(2);

    % sigma
    sig_m = sig(1);
    sig_f = sig(2);
    
    J_f = 1/(sig_f^2);
    J_m = 1/(sig_m^2);
    
    % 1 - optimal
    % 2 - best-cue
    % 3 - simple-average
    % 4 - incorrect-belief
    switch model
        case 1
            % single-cue: form-only
            if (sig_m == 0)
                val = ((1-c)^2*J_f*(s_f-b))/sqrt((1-c)^2*J_f);
            % single-cue: motion-only
            elseif (sig_f == 0)
                val = (J_m*(s_m-b))/sqrt(J_m);
            % combined cue
            else
                % Eq. 9 in SI of Dobs, Ma & Reddy, 2017
                val = (J_m*(s_m-b)+(1-c)^2*J_f*(s_f-b))/sqrt(J_m+(1-c)^2*J_f);
            end
        case 2
            % single-cue: form-only
            if (sig_m == 0)
                val = (0.6*c+(1-c)*s_f-b)/sig_f;
            % single-cue: motion-only
            elseif (sig_f == 0)
                val = (s_m-b)/sig_m;
            % combined cue
            else
                % Eq. 11 in SI of Dobs, Ma & Reddy, 2017
                if (sig_m < sig_f)
                    val = (s_m-b)/sig_m;
                else
                    val = (0.6*c+(1-c)*s_f-b)/sig_f;
                end
            end
        case 3
            % single-cue: form-only
            if (sig_m == 0)
                val = (0.6*c+(1-c)*s_f-b)/sig_f;
            % single-cue: motion-only
            elseif (sig_f == 0)
                val = (s_m-b)/sig_m;
            % combined cue
            else
                % Eq. 12 in SI of Dobs, Ma & Reddy, 2017
                val = (s_m+0.6*c+(1-c)*s_f-2*b)/sqrt(sig_m^2+sig_f^2);
            end
        otherwise
            % single-cue: form-only
            if (sig_m == 0)
                val = (0.6*c+(1-c)*s_f-b)/sig_f;
            % single-cue: motion-only
            elseif (sig_f == 0)
                val = (s_m-b)/sig_m;
            % combined cue
            else
                % see Eq. 10 in SI of Dobs, Ma & Reddy, 2017
                val = ((J_m*s_m+J_f*(0.6*c+(1-c)*s_f))/(J_m+J_f)-b)/sqrt(1/(J_m+J_f));
            end
    end
    
    % return the probability of responding "Susan"
    p = normcdf(val,0,1);

end