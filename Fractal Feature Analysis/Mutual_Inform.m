function [outputArg1,outputArg2] = Mutual_Inform(x)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here


    n = size(x,1);
    tmax = floor(min(100,n/4)); % maximum tau allowed
    T = zeros(n-tmax,tmax-1); % matrix will store data segments from x
     
    % construct T-matrix consisting of translated x vectors
    for t = 2:tmax+1
        T(:,t-1) = x(t:t+n-tmax-1);
    end
    x = x(1:1+n-tmax-1);
    
    % calculate entropy of each column in the system
    % if "nbin" = 0, "get_entropy" will estimate best bin size
%     [E,P,bin] = get_entropy([x,T],nbin);
    d=[x,T];
    bin=5;
        ncol = size(d,2);
    nrow = size(d,1);
    
    % estimate bin size from entropy-vector derivative if bin == 0 or []
    if isempty(bin) || bin == 0
        fprintf('\nEstimating best entropy...\n')
        maxbin = floor(min(200,0.5*nrow)); % maximum bin size for loop
        if mod(maxbin,2) == 1
            maxbin = maxbin + 1;
        end
        Emat = zeros(maxbin/2,ncol); % since we are incrementing by 2 in the loop
        count = zeros(maxbin/2,1); % for getting bin count
        for b = 1:maxbin/2 % increment by 2...assuming 1-extra bin won't add much
            if mod(b,8)==0
                fprintf('%s ',' . ');
            end
            clear P
            [P,~] = hist(d,2*b);
            P = bsxfun(@rdivide,P,sum(P)); % sum(c) = 1
            Emat(b,:) = -sum(P .* log(P+eps)); % entropy...use nansum to avoid summing log(0)
            count(b) = 2*b; % store bin size
        end
        clear P;
        
        % get normalized difference of E w/ respect to max(diff(E))
        % and find first point where this is <= 5% (i.e. when rate of
        % change slows down to 5% of its max)
        z = bsxfun(@rdivide,diff(Emat),max(diff(Emat)));
        [ind,~] = find(z<=0.05,ncol,'first'); % gets first index for each column
        
        % now get final PDFs and entropy measurements at
        % the mean of the optimized bin indices
        binsize = round(mean(ind)) * 2;
        [P,~] = hist(d,binsize);
        P = bsxfun(@rdivide,P,sum(P));
        E = -sum(P .* log(P+eps));
        
    else % if bin is provided by the user
        [P,bins] = hist(d,bin);
        P = bsxfun(@rdivide,P,sum(P));
        E = -sum(P .* log(P+eps));
        binsize = bin;
    end
    % now get mutual information, assuming E(1) and P(:,1)
    % represent time-delay = 0;
    fprintf('\nEstimating tau...');
    M = mutual_info(E,P);
    coef = (1/7) * ones(1,7); % 7-point moving average coefficients
    Ms = filter(coef,1,M); % helps avoid peak detection of noise
    
    % get first local minimum index in mutual information
    [~,ix] = findpeaks(-Ms,'minpeakdistance',10); % arbitrarily set to 10...helps ensure true local minimum
    if isempty(ix)
        ix = 1;
    end
    
    % now extract tau, and min MI value 
    tau = ix(1); % first local minimum
    mi = M(tau);
   
outputArg1 =tau;
outputArg2 = mi;
end

