function pcluster = permtest(Fstat, Fstatperm, F_thresh)

Fall = [Fstat; Fstatperm]; % stack real over permutation

% loop over real and permutations
for k = 1:size(Fall, 1)
    Fsum = [];
    % find all supra-threshold clusters and define sum F-value
    L = bwlabeln(Fall(k,:) > F_thresh);
    for c = 1:max(unique(L))
        Fsum(c) = sum(Fall(k,L == c));
    end;
    [Fsum, clusterindx] = sort(Fsum(:), 1, 'descend');
    % on pass 1, store all values
    if k == 1
        Fcluster = Fsum;
        Fselect = L;
        Findx = clusterindx;
    else
        if ~isempty(Fsum)
            Fclustermax(k-1) = Fsum(1);
        else
            Fclustermax(k-1) = 0;
        end
    end;
end
% at the end, assess cluster-level significance
% -1: below inclusion threshold, > 0: exact value
pcluster = -0 * ones(size(Fstat));
for c = 1:max(unique(Fselect))
    pcluster(Fselect == Findx(c)) = (sum(Fcluster(c) > Fclustermax)/numel(Fclustermax));
end