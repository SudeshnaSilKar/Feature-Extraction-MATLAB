function MI = mutual_info(E,P)
    % calculate joint entropy between probability P1 and Pm
    % by assuming first column in E,P represents probability to test
    % against remaining columns. Returns MI, with each number i 
    % representing mutual info between first and remaining columns
    
    ncol = numel(E)-1;
    
    % concatenate and get entropy and PDF for each column
    p1 = P(:,1); % probability of v
    pm = P(:,2:end); % probability of columns in m
    
    % make joint probability distribution for E_1 and E_m columns
    % and calculate joint entropy. Store into JE variable
    JE = zeros(1,ncol);
    for i = 1:ncol
        pj = p1 * pm(:,1)'; % joint probability 
        JE(i) = -sum(sum(pj .* log(pj+eps)));
    end
    
    % now calculate mutual information as:
    %   E_v + E_m - JE
    MI = E(1) + E(2:end) - JE;
end