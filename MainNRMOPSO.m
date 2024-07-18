clc;
clear ;
% 将 "MATLAB:divideByZero" 警告的显示设置为 "off"
addpath('..\utils');
addpath('..\data');
warning('off')
DataSets = {'wdbc','musk1','ionosphere'};
Algorithms={'NRMOPSO'};
for datasetIndex=1:length(DataSets)
  DataSet = DataSets{datasetIndex};
  Algorithm = Algorithms{1};
  diary(['log' Algorithm '.txt']);
  result_file_prefix = {'train_acc', 'test_acc', 'numfeature','time','tainhv','testhv'};
  final_mean_prefix = {'ave_trainacc','ave_testacc','ave_featuresize','std_testacc','ave_trainhv','ave_testhv','std_trainacc','meantime(s)','std_trainhv','std_testhv'};
  timeStr = datestr(now,'yyyy-mm-dd_HH-MM-SS');
  result_file = [Algorithm '_result_members_' DataSet '_' timeStr '.xls'];
  final_mean_std_output =[Algorithm '_final_' DataSet '_' timeStr '.xls'];
  MultimodalSet = [Algorithm '_multimodal' DataSet '_' timeStr '.txt'];
  traincost_testcost_output = [Algorithm '_rep&testcost_' DataSet '_' timeStr '.xls'];  %训练集和测试集的pareto前沿图数值数据
  writecell(result_file_prefix,result_file);
  writecell(final_mean_prefix,final_mean_std_output);
  Maxgeneration=50;
  n_pop=50;
  threshold=0.5;
  fprintf('Maxgeneration:%d,ParticleNumber=%d',Maxgeneration,n_pop);
  n_obj=2; %errorrate和 featurerate
  load(['../data/', DataSet,'.mat']);
  X=data(:,2:end);
  Y=data(:,1);
  n_var=size(X,2);
   xl=zeros(1,size(X,2));
   xu=ones(1,size(X,2));
  [Rank, Score] = relieff(X, Y,20);
 Rank=Rank((Score>0));
 Score=Score(Score>0);
 Score = (Score- min(Score)) / (max(Score) - min(Score));
 midScore=median(Score);
 ReilfF=[Rank ;Score]';
 sortedReilfF=sortrows(ReilfF,2,'descend');
  num_feature = size(X, 2);
  num_samples = size(X,1);
  X_norm = (X - repmat(min(X), size(X, 1), 1)) ./ repmat(max(X) - min(X), size(X, 1), 1);  %标准化
  round=5;
  result_members_all = [];
  member.train_acc = 0; member.test_acc = 0; member.n_feature = 0;member.Algorithmtime = 0; member.trainhv = 0;%存放一折的正确率特征数和时间
  member.testhv=0;
  Final.mean_train_acc = 0;Final.mean_test_acc = 0;Final.mean_feature_size = 0;Final.std_test_acc = 0;Final.mean_trainhv = 0;
  Final.mean_testhv = 0;Final.std_train_acc =0;Final.std_test_acc =0; Final.meantime = 0;
  result_members = repmat(member, round, 1);

  %% main loop
  for i=1:round
     [train_indices,valInd,test_indices] = dividerand(num_samples,0.7,0,0.3);
    X_train=X_norm(train_indices,:);Y_train=Y(train_indices);X_test=X_norm(test_indices,:);Y_test=Y(test_indices);
    start_time = clock; %一折的时间
    [ps,pf]= NRMOPSO1(X_train, Y_train,xl,xu,n_obj,n_var,n_pop,threshold,Maxgeneration,sortedReilfF);
    end_time = clock;
    pop=sortpop(ps,pf,num_feature,n_obj,threshold);
    [MultimodalArchive] = improve_findmultimodal(pop);  %一个结构体archives返回多模态解
    if size(MultimodalArchive,1)>0
      writecell(struct2cell(MultimodalArchive)',MultimodalSet,'WriteMode','append');
    end
    unique_pop=unique(pop,'rows','stable');
    testcost = Cal_TestSet_Cost(unique_pop,X_test,Y_test,threshold);%不是结构体，是numrep行2列的矩阵测试集的pf
    traincost = unique(cat(1,unique_pop(:,end-1:end)),'rows','stable');
    train_error = sum(unique_pop(:,end-1))/size(unique_pop,1);
    FeatNumRate = sum(unique_pop(:,end))/size(unique_pop,1);
    test_error = sum(testcost(:,1))/size(testcost,1);
    writematrix(traincost',traincost_testcost_output,'WriteMode','append');
    writematrix(testcost',traincost_testcost_output,'Sheet',2,'WriteMode','append');
    trainpf = cat(1,pf);
    train_hv = Hypervolume_calculation(trainpf, [1,1]);%hv计算    选择最差点，就是满的错误率和特征率都是1，hv越大越好
    test_hv = Hypervolume_calculation(testcost,[1,1]);
    result_members(i).train_acc = 1-train_error;
    result_members(i).test_acc =  1-test_error;
    result_members(i).n_feature = FeatNumRate*num_feature;
    result_members(i).Algorithmtime = etime(end_time,start_time);
    result_members(i).trainhv = train_hv;   %训练集的HV
    result_members(i).testhv = test_hv;
    % 记录格式
    prefix = strcat('round', num2str(i), '/',num2str(round));
    logger([prefix, ' time:', num2str(result_members(i).Algorithmtime), 's',...
      ' train_acc:', num2str(result_members(i).train_acc), ...
      ' test_acc:', num2str(result_members(i).test_acc), ...
      ' featuresize:', num2str(result_members(i).n_feature),...
      'TrainHV:',num2str(result_members(i).trainhv),...
      'TestHV:',num2str(result_members(i).testhv)
      ]);
  end
  writematrix(cell2mat(struct2cell(result_members))',result_file,'WriteMode','append');
  result_members_all = [result_members_all; result_members];
  Final.meantime = mean([result_members_all.Algorithmtime]);
  Final.mean_train_acc = mean([result_members_all.train_acc]);
  Final.std_train_acc = std([result_members_all.train_acc]);
  Final.mean_test_acc = mean([result_members_all.test_acc]);
  Final.std_test_acc = std([result_members_all.test_acc]);
  Final.mean_feature_size = mean([result_members_all.n_feature]);
  Final.mean_trainhv = mean([result_members_all.trainhv]);
  Final.std_trainhv = std([result_members_all.trainhv]);
  Final.mean_testhv = mean([result_members_all.testhv]);
  Final.std_testhv = std([result_members_all.testhv]);
  logger(['Dataset:',DataSet]);
  logger(['average training accuracy = ', num2str(Final.mean_train_acc) '±' num2str(Final.std_train_acc)]);
  logger(['average testing accuracy = ', num2str(Final.mean_test_acc) '±' num2str(Final.std_test_acc)]);
  logger(['std testing accuracy = ', num2str(Final.std_test_acc)]);
  logger(['average feature size = ', num2str(Final.mean_feature_size)]);
  logger(['average trainhv = ', num2str(Final.mean_trainhv) '±' num2str(Final.std_trainhv)]);
  logger(['average testhv = ', num2str(Final.mean_testhv) '±' num2str(Final.std_trainhv)]);
  writematrix(cell2mat(struct2cell(Final))',final_mean_std_output,'WriteMode','append');
  diary off;

end
