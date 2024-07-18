
function paretoSolutions = nondominate(solutions)
    % 输入: solutions是一个NxM的矩阵，N是解的数量，M是目标的数量
    % 输出: paretoSolutions是一个PxM的矩阵，包含Pareto前沿上的解

    N = size(solutions, 1);  % 解的数量
    paretoSolutions = [];  % 用于存储Pareto解的矩阵

    for i = 1:N
        dominated = false;  % 假设解i没有被支配
        for j = 1:N
            if i ~= j
                % 检查解j是否支配解i
                if all(solutions(j, :) <= solutions(i, :)) && any(solutions(j, :) < solutions(i, :))
                    dominated = true;
                    break;
                end
            end
        end
        if ~dominated
            paretoSolutions = [paretoSolutions; solutions(i, :)];
        end
    end
end


