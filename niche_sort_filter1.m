function particle = niche_sort_filter1(niche_size, Particle_Number, particle, n_var, n_obj)
    s = Particle_Number;
    G = ceil(Particle_Number / niche_size);
    newparticle = []; % 创建新的粒子数组
    
    for i = 1:G
        if s > niche_size
            n = niche_size;
        else
            n = s;
        end
        
        particles = zeros(s, n_var + n_obj);
        for q = 1:s
            particles(q, 1:n_var) = particle(q).pos;
            particles(q, n_var + 1:n_var + n_obj) = particle(q).cost;
        end
        
        if size(particles, 1) > 1
            dist = squareform(pdist(particles(:, 1:n_var), 'euclidean'));
            NSSCD = non_domination_scd_sort(particles(:, 1:n_var + n_obj), n_obj, n_var);
            bestparticle = NSSCD(1, 1:n_var + n_obj);
            idx = find(ismember(particles, bestparticle, 'rows'));
            A = dist(:, idx);
            nonzero_idx = find(dist(:, idx) ~= 0);
%             [~, sorted_idx] = sort(A(nonzero_idx));
%             firstnichesizeidx = nonzero_idx(sorted_idx(1:n - 1));
%             one_nichesize_index = [idx; firstnichesizeidx];
                    % 选择最近的粒子，考虑剩余粒子数量
        num_nearest = min(length(nonzero_idx), 15); % 最近的粒子数量，最多10个
        [~, sorted_idx] = sort(A(nonzero_idx));
        nearest_idx = nonzero_idx(sorted_idx(1:num_nearest));
        
%         随机选择n-1个最近的粒子
        selected_nearest_idx = nearest_idx(randperm(num_nearest, n - 1));
        one_nichesize_index = [idx; selected_nearest_idx];
            leader_particle = particle(one_nichesize_index(1));
            for k = 1:n
                particle(one_nichesize_index(k)).Leader = leader_particle;
                newparticle = [newparticle; particle(one_nichesize_index(k))]; % 将粒子添加到新数组中
            end
            
            % 移除已分配到小生境的粒子
            particle(one_nichesize_index) = [];
            s = s - n;
        else
            particle(1).Leader = particle(1);
            newparticle = [newparticle; particle(1)]; % 将粒子添加到新数组中
        end
    end
    
    particle = newparticle; % 更新粒子数组
end
% function particle = niche_sort_filter1(niche_size, Particle_Number, particle, n_var, n_obj, emptyparticle)
%     s = Particle_Number;
%     G = ceil(Particle_Number / niche_size);
%     newparticle = []; % 创建新的粒子数组
%     
%     for i = 1:G
%         if s > niche_size
%             n = niche_size;
%         else
%             n = s;
%         end
%         
%         particles = zeros(s, n_var + n_obj);
%         for q = 1:s
%             particles(q, 1:n_var) = particle(q).pos;
%             particles(q, n_var + 1:n_var + n_obj) = particle(q).cost;
%         end
%         if size(particles, 1) > 1
%         NSSCD = non_domination_scd_sort(particles(:, 1:n_var + n_obj), n_obj, n_var);
%         bestparticle = NSSCD(1, 1:n_var + n_obj);
%         idx = find(ismember(particles, bestparticle, 'rows'));
%         
%         % 计算与最优粒子的距离
%         dist = squareform(pdist(particles(:, 1:n_var), 'euclidean'));
%         A = dist(:, idx);
%         nonzero_idx = find(dist(:, idx) ~= 0);
%         
%         % 选择最近的粒子，考虑剩余粒子数量
%         num_nearest = min(length(nonzero_idx), 10); % 最近的粒子数量，最多10个
%         [~, sorted_idx] = sort(A(nonzero_idx));
%         nearest_idx = nonzero_idx(sorted_idx(1:num_nearest));
%         
%         % 随机选择n-1个最近的粒子
%         selected_nearest_idx = nearest_idx(randperm(num_nearest, n - 1));
%         one_nichesize_index = [idx; selected_nearest_idx];
%         
%         leader_particle = particle(one_nichesize_index(1));
%         for k = 1:n
%             particle(one_nichesize_index(k)).Leader = leader_particle;
%             newparticle = [newparticle; particle(one_nichesize_index(k))]; % 将粒子添加到新数组中
%         end
%         
%         % 移除已分配到小生境的粒子
%         particle(one_nichesize_index) = [];
%         s = s - n;
%        end
%     end
%     particle = newparticle; % 更新粒子数组
% end
% function particle = niche_sort_filter1(niche_size, Particle_Number, particle, n_var, n_obj, emptyparticle)
%     s = Particle_Number;
%     G = ceil(Particle_Number / niche_size);
%     newparticle = []; % 创建新的粒子数组
%     
%     for i = 1:G
%         if s > niche_size
%             n = niche_size;
%         else
%             n = s;
%         end
%         
%         particles = zeros(s, n_var + n_obj);
%         for q = 1:s
%             particles(q, 1:n_var) = particle(q).pos;
%             particles(q, n_var + 1:n_var + n_obj) = particle(q).cost;
%         end
%         
%         if n == 1
%             % 当小生境大小为1时，直接将粒子添加到新数组中
%             newparticle = [newparticle; particle(1)];
%             particle(1) = [];
%         else
%             NSSCD = non_domination_scd_sort(particles(:, 1:n_var + n_obj), n_obj, n_var);
%             bestparticle = NSSCD(1, 1:n_var + n_obj);
%             idx = find(ismember(particles, bestparticle, 'rows'));
%             
%             % 计算与最优粒子的距离
%             dist = squareform(pdist(particles(:, 1:n_var), 'euclidean'));
%             A = dist(:, idx);
%             nonzero_idx = find(dist(:, idx) ~= 0);
%             
%             % 选择最远的粒子，考虑剩余粒子数量
%             num_farthest = min(length(nonzero_idx), n - 1); % 最远的粒子数量
%             [~, sorted_idx] = sort(A(nonzero_idx), 'descend'); % 按距离降序排序
%             farthest_idx = nonzero_idx(sorted_idx(1:num_farthest));
%             
%             one_nichesize_index = [idx; farthest_idx];
%             
%             leader_particle = particle(one_nichesize_index(1));
%             for k = 1:n
%                 particle(one_nichesize_index(k)).Leader = leader_particle;
%                 newparticle = [newparticle; particle(one_nichesize_index(k))]; % 将粒子添加到新数组中
%             end
%             
%             % 移除已分配到小生境的粒子
%             particle(one_nichesize_index) = [];
%         end
%         
%         s = s - n;
%     end
%     
%     particle = newparticle; % 更新粒子数组
% end
% 
