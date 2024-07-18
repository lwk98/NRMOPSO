 addpath 'C:\Users\ll\Desktop\程序代码\minepy-master\minepy-master\matlab'
% 初始化MIC值存储的向量
load colon.mat;
X=data(:,2:end);
Y=data(:,1);
MIC_values = zeros(1, size(X, 2)); % 20个特征

% 循环计算每个特征与类别标签Y的MIC值
for i = 1:size(X, 2) % 对于每一个特征
    % 计算第i个特征与类别标签的MIC
    result = mine(X(:, i)', Y');
    % 存储MIC值
    MIC_values(i) = result.mic;
end

% 输出MIC值
disp(MIC_values);
% 找到MIC值最高的三个特征的索引

[sorted_MIC, sorted_index] = sort(MIC_values, 'descend');
top_features_index = sorted_index(1:5);

% 选择MIC值最高的三个特征
X_top_features = X(:, top_features_index);

% 分割数据集为训练集和测试集
cv = cvpartition(size(X,1),'HoldOut',0.4);
idx = cv.test;
% 训练集
X_train = X_top_features(~idx,:);
Y_train = Y(~idx);
% 测试集
X_test = X_top_features(idx,:);
Y_test = Y(idx);

% 使用训练集训练KNN分类器
% 默认的KNN分类器使用的是1个最近邻
Mdl = fitcknn(X_train, Y_train, 'NumNeighbors', 5);

% 在测试集上进行预测
Y_pred = predict(Mdl, X_test);

% 计算分类的正确率
accuracy = sum(Y_pred == Y_test) / numel(Y_test);
fprintf('The classification accuracy using the top 3 features is: %.2f%%\n', accuracy * 100);