function [ps,pf]=NRMOPSO(X,Y,VRmin,VRmax,n_obj,n_var,Particle_Number,threshold,Maxgeneration,sortedReilfF)
n_PBA=50;
%% 粒子初始化
emptyparticle.pos=[];
emptyparticle.cost=[];
emptyparticle.velocity=[];
emptyparticle.isdominate=0;
emptyparticle.Leader = [];
particle=repmat(emptyparticle,Particle_Number,1);
    mv=0.5*(VRmax-VRmin);
    VRmin=repmat(VRmin,Particle_Number,1);
    VRmax=repmat(VRmax,Particle_Number,1);
    Vmin=repmat(-mv,Particle_Number,1);
    Vmax=-Vmin;
   %   pos=popinit(X,Y,Particle_Number) ;      %initialize the positions of the particles
         pos=VRmin+(VRmax-VRmin).*rand(Particle_Number,n_var);
    vel=Vmin+2.*Vmax.*rand(Particle_Number,n_var);        %initialize the velocities of the particles   
for i=1:Particle_Number     
    particle(i).pos=pos(i,:);
    particle(i).cost=fitness_niche(X,Y,particle(i).pos,threshold);  %f1=错误率，f2=特征选择率
    particle(i).velocity=vel(i,:); %初始化速度
end
for q=1:Particle_Number
      particles(q,1:n_var)=particle(q).pos;
      particles(q,n_var+1:n_var+n_obj)=particle(q).cost;
end
 row_of_cell=ones(1,Particle_Number); 
 col_of_cell=size(particles,2);       
 PBA=mat2cell(particles,row_of_cell,col_of_cell);
%  MuArchiveSet=[];
%% nichenum G niche size N=5 Swarm size n_pop
 %% leader selection

%   niche_size = randi([3, 8]);
  niche_size=5;
  niches=niche_sort_filter(niche_size,Particle_Number,particle,n_var,n_obj,emptyparticle);
%   niches=determineleader(niches,niche_size,it,n_var,n_obj) ;
  %% main loop
for it=1:Maxgeneration
   particle=[];
  for n=1:ceil(Particle_Number/niche_size)
  particle=[particle;niches(n).particle];
  end
  w=(rand()+exprnd(0.5))/2;
  c1=2*(1-log(it)/log(Maxgeneration));
  c2=2*(log(it)/log(Maxgeneration));
 for i=1:Particle_Number 
      PBA_i=PBA{i,1};
      pbest=PBA_i(1,:);
      particle(i).velocity = w*particle(i).velocity ...
            +c1*rand(1,n_var).*(PBA_i(1,n_var)-particle(i).pos) ...
            +c2*rand(1,n_var).*(particle(i).Leader.pos-particle(i).pos);    %速度更新公式，rand(1,nvar)代表粒子速度的每个维度都需要一个随机值
        % ，60个特征，所以需要1行60列的随机值
       particle(i).pos = particle(i).pos + particle(i).velocity;  %位置更新公式
       particle(i).velocity=(particle(i).velocity>mv).*mv+(particle(i).velocity<=mv).*particle(i).velocity; 
       particle(i).velocity=(particle(i).velocity<(-mv)).*(-mv)+(particle(i).velocity>=(-mv)).*particle(i).velocity;
            particle(i).pos=((particle(i).pos>=VRmin(1,:))&(particle(i).pos<=VRmax(1,:))).*particle(i).pos...
                +(particle(i).pos<VRmin(1,:)).*(VRmin(1,:)+0.25.*(VRmax(1,:)-VRmin(1,:)).*rand(1,n_var))+(particle(i).pos>VRmax(1,:)).*(VRmax(1,:)-0.25.*(VRmax(1,:)-VRmin(1,:)).*rand(1,n_var));
       %位置边界的约束，lb和ub代表各个特征维度的边界
       particle(i).cost = fitness_niche(X,Y,particle(i).pos,threshold);   
          newparticle=[particle(i).pos,particle(i).cost];
       %计算cost
%         mutationparticle=mutation(particle(i),X,Y,threshold,sortedReilfF);
%         muat=[mutationparticle.pos,mutationparticle.cost];
%          MuArchiveSet = [MuArchiveSet;muat];  
%         if ~isequal(newparticle,mutationparticle)
%           MuArchiveSet = [MuArchiveSet;muat];  
%           newparticle=muat;
        PBA_i=[PBA_i(:,1:n_var+n_obj);newparticle];          
        PBA_i = non_domination_scd_sort(PBA_i(:,1:n_var+n_obj), n_obj, n_var);
              if size(PBA_i,1)>n_PBA
                 PBA{i,1}=PBA_i(1:n_PBA,:);
             else
                 PBA{i,1}=PBA_i;
              end
  end
%  niche_size=calculateHoodSize(it);
 niches=niche_sort_filter(niche_size,Particle_Number,particle,n_var,n_obj,emptyparticle);
 end

 
    tempEXA=cell2mat(PBA); 
    tempEXA=non_domination_scd_sort(tempEXA(:,1:n_var+n_obj), n_obj, n_var);
     if size(tempEXA,1)>Particle_Number
         EXA=tempEXA(1:Particle_Number,:);
     else
        EXA=tempEXA;
     end
   tempindex=find(EXA(:,n_var+n_obj+1)==1);
   ps=EXA(tempindex,1:n_var);
   pf=EXA(tempindex,n_var+1:n_var+n_obj);
end


