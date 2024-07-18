function newparticle = mutation(particle,X,Y,threshold,sortedReilfF)
       oldparticle=particle;
       currentpos=find(particle.pos>threshold);
      if numel(currentpos)==0
        needtoadd=sortedReilfF(1,1);
        particle.pos(needtoadd)=0.5 +0.3*rand;
      elseif numel(currentpos)==1

        need2deletevar=currentpos(ismember(currentpos,sortedReilfF(:,1))==0); %找到没出现的值（是数组）
        if isempty(need2deletevar)  %需要删除的为0
          % 增加特征
          idx=ismember(sortedReilfF(:,1),currentpos);
            sortedReilfF(idx,:)=[];
            needtoaddfeat=sortedReilfF(1,1);
            particle.pos(needtoaddfeat)= 0.5 +0.3*rand;
        elseif ~isempty(need2deletevar)  %这唯一的特征也是不好的特征，就删除，挑一个好的替换
          particle.pos(currentpos)=0.75*rand;
          selectedfeat=sortedReilfF(1,1);
          particle.pos(selectedfeat)= 0.5 +0.3*rand;
        end
      elseif numel(currentpos)>1
          need2deletevar=currentpos(ismember(currentpos,sortedReilfF(:,1))==0); %找到没出现的值（是数组）
          if isempty(need2deletevar)
                  %do nothing
          elseif ~isempty(need2deletevar)
          numValues = numel(need2deletevar);
          halfnum=round(numValues/2);
          idx = randperm(numValues, halfnum);
         for i = 1:halfnum
          particle.pos(need2deletevar(idx)) = 0.6* rand;  % 使用不同的随机值来修改粒子位置
         end
          %增加操作
          idx=ismember(sortedReilfF(:,1),currentpos);
            sortedReilfF(idx,:)=[];
            if isempty(sortedReilfF)
              %do nothing
            elseif size(sortedReilfF,1)==1
              need2addfeat=sortedReilfF(1,1);
              particle.pos(need2addfeat)=0.5+0.3*rand;
            elseif size(sortedReilfF,1)>1
              halfneedadd=round(size(sortedReilfF,1)/2);
              need2addfeat=sortedReilfF(1:halfneedadd,1);
              for i=1:halfneedadd
                particle.pos(need2addfeat(i)) = 0.5 +0.3*rand;
              end
            end
          end

  
      end
      particle.cost=fitness_niche(X,Y,particle.pos,threshold);
      if particle.cost(1)<oldparticle.cost(1)
          newparticle=particle;
      else
        newparticle=oldparticle;
      end
end


