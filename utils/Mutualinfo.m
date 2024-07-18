
function MI = Mutualinfo(X, y, numBins)
    MI = zeros(size(X, 2), 1);
    for i = 1:size(X, 2)
        jointHist = histcounts2(X(:,i), y, numBins);
        MI(i) = mutualInfo(jointHist);
    end
end

function I = mutualInfo(jointHist)
    jointProb = jointHist / sum(jointHist(:));
    marginalProbX = sum(jointProb, 2);
    marginalProbY = sum(jointProb, 1);
    [X, Y] = meshgrid(marginalProbY, marginalProbX);
    I = sum(jointProb .* log2(jointProb ./ (X .* Y)), 'all', 'omitnan');
end

