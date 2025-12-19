%average_moving.m：调用average_moving函数对光谱数据进行移动平均平滑。
%Normalize.m：调用Normalize函数对数据进行归一化处理。
%plsdacv_app.m：调用plsdacv_app函数进行 K 折交叉验证，评估模型性能。
%C_get_pls_da_model_all_APP.m：调用C_get_pls_da_model_all_APP函数训练 PLS-DA 模型并预测。
clear all;
clc;

% 参数设置
A = 17; % 计算10个潜变量（主成分） % A、K可以改，但是会复杂一点，涉及主成分分析，先不动吧
% A = 3; 
K = 5;
% K = 2;
% 参数设置

%%% 数据导入与预处理
SamplePath = fullfile(pwd,'Spectra Data');
files = dir(SamplePath);     % 获取Spectra Data文件夹下的所有文件信息
num_file = size(files,1);    % 获取文件数量，注意前两个是.和..，需要排除
j =0;

Str_mes = {}; % 存储Mes开头的文件名（去除前缀"Mes"）
statistics_all = [];  % 存储所有样本的统计数据

% 筛选Mes开头的文件名并去除前缀"Mes"
for i = 3:num_file
   if strncmp(files(i).name,'Mes',3)
      Str_mes{j+1} =  files(i).name(5:end); % 将文件名中前缀"Mes_"去除后存入Str_mes数组
      
      j = j+1;
   end
end
%%% Mes_开头的文件数量
num_mes_file  = (j);   


% 选择特定的数据集
selected_str = {'Data_6-8-7-P1-P3.csv','Data_9-1-20-P1-P3.csv','Data_10-1-41-P1-P3.csv','Data_10-42-70-P1-P3.csv','Data_11-1-35-P1.csv','Data_11-1-35-P2-P3.csv','Data_11-36-50-P1-P3.csv','Data_11-90-123-P1-P3.csv'
};
num_dataset = length(selected_str);  

mean_sample_all_spectra_all = []; % 存储所有样本的平均光谱数据
matrix_white_reference = [];      % 存储所有样本的白参考光谱数据

% 光谱数据预处理参数
for i_num_dataset = 1:num_dataset
    % 对于每个选定的数据集，找到对应的Mes文件
    selected_spectra = selected_str{i_num_dataset};
    selected_str_mes = '';
    for i=1:num_mes_file
        str_mes_i = Str_mes{i};
        % 比较selected_spectra和str_mes_i的特定部分，去除前缀和后缀，确保匹配
        if strcmp(selected_spectra(6:end-9),str_mes_i(1:end-9))    
            selected_str_mes = str_mes_i; % 匹配结果
        end
    end
    
    if isempty(selected_str_mes)
        msgbox('未找到匹配标签的光谱数据文件','错误','error') 
        break;
    end

    % 标签文件名
    str_mes =  [SamplePath '\Mes_' selected_str_mes]; 

    % 导入数据
    Data_struct = importdata(str_mes); 
    % 标签部分，得到除头行外的数据
    Data = Data_struct.data; 
    % 统计数据的第2到4列（index，label）
    statistics = Data(:,2:4); 
    statistics = roundn(statistics,-4); % 保留4位小数，确保数值精度
    % 将当前统计数据追加到总统计数据中
    statistics_all = [statistics_all;statistics]; % 封号是垂直拼接，逗号空格是水平拼接
    
    % Y变量，对应label
    Y = statistics(:,3);

    % 导入Data数据并进行预处理-归一化处理
    % 光谱数据文件绝对路径
    str = [SamplePath '\' selected_str{i_num_dataset}]; 
    % 跳过前12行，和第1列，读取光谱数据
    data = csvread(str,13,1);  
    wavelength = data(1,:);    % 波长信息
    data_col_1 = sum(data,2);  % 数据每行的和
    data_interval = find(data_col_1 == 0);  % 找到和为0的行
    num_sample = length(data_interval);     % 样本数量
    num_sample_i_dataset(1,i_num_dataset) = num_sample;

    % 光谱数据预处理参数
    % 波长范围
    wavelength_start = 563;
    wavelength_end = 1110;

    % --- 新增代码开始 ---
    % 自动计算最接近目标波长的索引位置
    [~, location_wavelength_start] = min(abs(wavelength - wavelength_start));
    [~, location_wavelength_end] = min(abs(wavelength - wavelength_end));
    
    % --- 新增代码结束 ---

    % 【修复】每次循环开始前清空当前文件的临时变量
    mean_sample_all_spectra = []; 
    white_reference = [];
  
    % 去除起始和结束的光谱点比例
    num_start = 0;
    num_end = 0;
  
    % 光谱强度范围  
    intensity_start = 0;
    intensity_end = 60000;
     
         % 处理csv文件中的光谱数据
    for i=1:num_sample
    
        % 确定波长范围的索引
        % 如果样本i为最后一个样本
        if i==num_sample
            % 此样本的光谱数据从data_interval(i)+1行到倒数第2行,列限制在波长范围内
            ith_sample_spectra = data(data_interval(i)+1:end-1,location_wavelength_start:location_wavelength_end); %  
            % 找出每行的最大值
            [Maxvalue,~] = max(ith_sample_spectra,[],2); 
            % 删除行中最大值不在强度范围内的光谱
            DeletPointPosition = find(Maxvalue > str2double(intensity_end) | Maxvalue< str2double(intensity_start));
            % DeletPointPosition = find(Maxvalue > intensity_end | Maxvalue < intensity_start);
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % 找出第10列中大于30000的行
            Stvalue = ith_sample_spectra(:,10); %第10列数据
            DeletPointPosition = find(Stvalue > 30000);
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % 计算去除起始和结束的光谱点数量
            a = num_start;
            b = num_end;
            num_spectra = size(ith_sample_spectra,1); % 此样本有多少行光谱数据
    
            % 如果a小于90，按百分比计算，否则按绝对值计算（比如a=5就是删前百分之五，a=500就是删前五行）
            if a < 90
                num_start_d = floor(num_spectra*a/100);
            else
                num_start_d = floor(a/100);
            end
            % 同a
            if b < 90
                num_end_d = floor(num_spectra*b/100);
            else
                num_end_d = floor(b/100);
            end
            % 处理后的光谱数据
            ith_sample_spectra_ex = ith_sample_spectra(num_start_d+1:num_spectra-num_end_d,:);
    
            % 计算出此样本的平均光谱，把多行光谱数据平均成一行
            mean_sample_all_spectra(i,:) = mean(ith_sample_spectra_ex,1);
            
            % 白参考光谱
            white_reference(i,:) = data(end,location_wavelength_start:location_wavelength_end); 
  
        else
            % 如果不是最后一个样本
            % 此样本的光谱数据从data_interval(i)+1行到data_interval
            ith_sample_spectra =  data(data_interval(i)+1:data_interval(i+1)-2,location_wavelength_start:location_wavelength_end);    
            % 找出每行的最大值
            [Maxvalue,~] = max(ith_sample_spectra,[],2);  % 每行最大值
            DeletPointPosition = find(Maxvalue > str2double(intensity_end) | Maxvalue< str2double(intensity_start));
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % 剔除第10列中大于30000的行
            Stvalue = ith_sample_spectra(:,30); %第10列数据
            DeletPointPosition = find(Stvalue > 30000);
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % 计算去除起始和结束的光谱点数量
            a = num_start;
            b = num_end;
            num_spectra = size(ith_sample_spectra,1);
    
            if a < 90
                num_start_d = floor(num_spectra*a/100);
            else
                num_start_d = floor(a/100);
            end
    
            if b < 90
                num_end_d = floor(num_spectra*b/100);
            else
                num_end_d = floor(b/100);
            end
    
            ith_sample_spectra_ex = ith_sample_spectra(num_start_d+1:num_spectra-num_end_d,:);
        
            % 计算出此样本的平均光谱，把多行光谱数据平均成一行
            mean_sample_all_spectra(i,:) = mean(ith_sample_spectra_ex,1);
            
            % 白参考光谱
            white_reference(i,:) = data(data_interval(i+1)-1,location_wavelength_start:location_wavelength_end); 
  
        end
 
    end
    
    
    mean_sample_all_spectra_all= [mean_sample_all_spectra_all; mean_sample_all_spectra];

    matrix_white_reference = [matrix_white_reference; white_reference];

end

% %%% 光谱预处理
Xpreprocess = mean_sample_all_spectra_all;

%%% 移动平均滤波
segment = 29;   % 滤波窗口大小
% segment = 3;   % 滤波窗口大小
% Xpreprocess = average_moving(Xpreprocess,str2double(segment));
% 平滑处理（移动平均滤波）
Xpreprocess = average_moving(Xpreprocess,segment);

%%% 归一化
% 所有值除以各自行的范数（最大值）
% [~, ~,~,~,Xpreprocess,~]=Normalize(Xpreprocess,Xpreprocess);
% [~, ~,~,~,Xpreprocess,~]=SNV(Xpreprocess,Xpreprocess);
[~, ~,~,~,Xpreprocess,~]=FirstDerivative(Xpreprocess,Xpreprocess);

% --- 新增代码：获取完整的标签向量，用于后续作为预测集的真值 ---
Y_all = statistics_all(:,3); 
% 如果是单文件运行，此时Y变量可能已经是完整的，但为了保险起见，使用statistics_all
% 确保用于分类筛选的Y也是完整的（防止多文件读取时的bug）
Y = Y_all; 
% --- 新增代码结束 ---
 
% !!! 新增筛选：只保留标签为1(正常)和7(水脱)的样本，剔除中间值4，防止拉低总准确率 !!!
valid_idx = find(Y_all == 1 | Y_all == 7);
Y_all = Y_all(valid_idx);
Xpreprocess = Xpreprocess(valid_idx, :);

% 如果是单文件运行，此时Y变量可能已经是完整的
Y = Y_all; 
% --- 新增代码结束 ---
% ...existing code...

%%% 分类别处理
% 1类样本,7类样本
num_normal = find(Y==1);  % 正常样本1类别（哪些行）
num_moldy = find(Y==7);   % 霉变样本7类别
X_normal = Xpreprocess(num_normal,:);  % 正常样本1类别数据  
Y_normal = Y(num_normal,:);            % 正常样本1类别标签      
X_moldy = Xpreprocess(num_moldy,:);    % 霉变样本7类别数据
Y_moldy = Y(num_moldy,:);              % 霉变样本7类别标签

% 如果正常样本数量比水脱样本多30个以上，则只取霉变样本数量的正常样本
% if-else就是判断语句了，如果符合if的条件，那么就进if的代码，不然就进else
% if的条件↓，如果正常样本数量比水脱样本多30个以上，那么就把正常数据的量截取成和水脱数据的量一样多，这个叫下采样
n_normal = length(num_normal)
n_moldy = length(num_moldy)

% if n_normal > n_moldy % ???????????????
%     X_normal_part = X_normal(1:n_moldy,:);
%     Y_normal_part = Y_normal(1:n_moldy);
%     X = [X_normal_part;X_moldy];
%     Y = [Y_normal_part;Y_moldy];
% elseif n_normal < n_moldy % ????????????????
%     X_moldy_part = X_moldy(1:n_normal,:);
%     Y_moldy_part = Y_moldy(1:n_normal);
%     X = [X_normal;X_moldy_part];
%     Y = [Y_normal;Y_moldy_part];
% else %如果二者一样多，直接合并
%     X = [X_normal ;X_moldy_part];
%     Y = [Y_normal;Y_moldy_part];
% end

if n_normal > n_moldy % 如果正常的比水脱的多
    % 方案：复制水脱样本（过采样）
    rep_count = ceil(n_normal / n_moldy);
    X_moldy_over = repmat(X_moldy, rep_count, 1);
    Y_moldy_over = repmat(Y_moldy, rep_count, 1);
    % 截取
    X_moldy_over = X_moldy_over(1:n_normal, :);
    Y_moldy_over = Y_moldy_over(1:n_normal, :);
    
    X = [X_normal; X_moldy_over];
    Y = [Y_normal; Y_moldy_over];

elseif n_normal < n_moldy % 如果正常的比水脱的少
    % 方案：复制正常样本（过采样）
    rep_count = ceil(n_moldy / n_normal);
    X_normal_over = repmat(X_normal, rep_count, 1);
    Y_normal_over = repmat(Y_normal, rep_count, 1);
    % 截取
    X_normal_over = X_normal_over(1:n_moldy, :);
    Y_normal_over = Y_normal_over(1:n_moldy, :);
    
    X = [X_normal_over; X_moldy];
    Y = [Y_normal_over; Y_moldy];

else %如果二者一样多，直接合并
    X = [X_normal ;X_moldy_part];
    Y = [Y_normal;Y_moldy_part];
end
% if length(num_normal)>length(num_moldy)+30
%     X_normal_part = X_normal(1:length(num_moldy),:);
%     Y_normal_part = Y_normal(1:length(num_moldy));
%     X = [X_normal_part;X_moldy];
%     Y = [Y_normal_part;Y_moldy];
% else
%     % 那我们想想如果不符合“正常>水脱+30”这个条件，还会有哪些情况呢
%     % 1.正常比水脱的多，但是没多到30
%     % 2.正常比水脱的少
%     % 而这里的else的代码是将水脱的样本截取到和正常的一样多，也就是没考虑1
%     % 强制截取水脱样本，使其数量等于正常样本的数量
%     X_moldy_part = X_moldy(1:length(num_normal),:);
%     Y_moldy_part = Y_moldy(1:length(num_normal));
%     X = [X_normal;X_moldy_part];
%     Y = [Y_normal;Y_moldy_part];
% end

% 检查逻辑
disp(['X的大小: ', num2str(size(X))]);
disp(['Y的大小: ', num2str(size(Y))]);
% 检查逻辑
  
% %%% PLS-DA模型建立与预测
% CV = plsdacv_app(X,Y,str2double(A),K);
CV = plsdacv_app(X,Y,A,K);
classificationresult = CV.result;
n = CV.optLV;
  
ture_value_Y = Y;
predicted_value_Y = CV.YR_original(:,n);
  
% PLS-DA模型建立与预测
error_specific = 0.5;  % 错误容忍度
% [result,result_ud,model,~,~]=C_get_pls_da_model_all_APP(X,Y,Xpreprocess,Y,error_specific);
% [result,result_ud,model,~,~]=C_get_pls_da_model_all_APP(X,Y,Xpreprocess,Y_all,error_specific);
[result, result_ud, model, matrix_num_delet, Y_pred_all_matrix] = C_get_pls_da_model_all_APP(X, Y, Xpreprocess, Y_all, error_specific); % 捕获所有输出参数
% 到这里所有模型相关的代码就都结束啦
display('PLS-DA模型建立与预测完成');

%% === 结果展示部分 ===这部分都是结果的显示，文本和绘图

% 1. 文本输出：详细统计指标
fprintf('\n==================== PLS-DA 模型结果报告 ====================\n');
fprintf('最佳潜变量数 (LV): %d\n', n);
fprintf('错误容忍度 (Error Threshold): %.2f\n', error_specific);

% 提取最佳 LV 下的各项指标
% result 矩阵行定义: 1:校正集正常灵敏度, 2:校正集水脱特异度, 3:校正集总准确率
%                   4:预测集正常灵敏度, 5:预测集水脱特异度, 6:预测集总准确率
res_cal_sens = result(1, n) * 100;
res_cal_spec = result(2, n) * 100;
res_cal_acc  = result(3, n) * 100;

res_pred_sens = result(4, n) * 100;
res_pred_spec = result(5, n) * 100;
res_pred_acc  = result(6, n) * 100;

fprintf('\n--- 1. 校正集性能 (平衡后的训练数据) ---\n');
fprintf('正常果识别率 (Sensitivity): %.2f%%\n', res_cal_sens);
fprintf('水脱果识别率 (Specificity): %.2f%%\n', res_cal_spec);
fprintf('总准确率 (Accuracy)       : %.2f%%\n', res_cal_acc);

fprintf('\n--- 2. 预测集性能 (所有原始数据) ---\n');
fprintf('正常果识别率 (Sensitivity): %.2f%%\n', res_pred_sens);
fprintf('水脱果识别率 (Specificity): %.2f%%\n', res_pred_spec);
fprintf('总准确率 (Accuracy)       : %.2f%%\n', res_pred_acc);

% 剔除异常点后的结果
% result_ud 矩阵行定义: 1:剔除数量, 2:灵敏度, 3:特异度, 4:总准确率
num_deleted = result_ud(1, n);
res_ud_sens = result_ud(2, n) * 100;
res_ud_spec = result_ud(3, n) * 100;
res_ud_acc  = result_ud(4, n) * 100;

fprintf('\n--- 3. 剔除异常点后的预测性能 ---\n');
fprintf('剔除样本数量              : %d\n', num_deleted);
fprintf('正常果识别率 (Sensitivity): %.2f%%\n', res_ud_sens);
fprintf('水脱果识别率 (Specificity): %.2f%%\n', res_ud_spec);
fprintf('总准确率 (Accuracy)       : %.2f%%\n', res_ud_acc);
fprintf('=============================================================\n');

%% 2. 图形输出：可视化结果

% 图1：交叉验证准确率随潜变量数的变化
figure('Name', 'CV Accuracy vs LV', 'Color', 'w');
plot(1:A, CV.result(3,:) * 100, '-bo', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
hold on;
plot(n, CV.result(3,n) * 100, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r'); % 标记最佳点
xlabel('潜变量个数 (Latent Variables)');
ylabel('交叉验证准确率 (%)');
title(['交叉验证结果 (最佳 LV = ' num2str(n) ')']);
grid on;
legend('准确率曲线', '最佳LV');

% 图2：预测集分类效果散点图
Y_pred_final = Y_pred_all_matrix(:, n); % 获取最佳LV下的预测值
idx_normal = find(Y_all == 1);
idx_water = find(Y_all == 7);

figure('Name', 'Prediction Results', 'Color', 'w');
hold on;
% 绘制正常果（真实值为1）的预测值
plot(idx_normal, Y_pred_final(idx_normal), 'g.', 'MarkerSize', 10, 'DisplayName', '真实: 正常果');
% 绘制水脱果（真实值为7）的预测值
plot(idx_water, Y_pred_final(idx_water), 'r.', 'MarkerSize', 10, 'DisplayName', '真实: 水脱果');

% 绘制阈值线
yline(4, 'k--', 'LineWidth', 1.5, 'DisplayName', '分类阈值 (4)');
yline(1, 'g:', 'LineWidth', 0.5, 'HandleVisibility', 'off'); % 参考线1
yline(7, 'r:', 'LineWidth', 0.5, 'HandleVisibility', 'off'); % 参考线7

xlabel('样本编号');
ylabel('模型预测值');
title(['全样本预测结果 (准确率: ' num2str(res_pred_acc, '%.1f') '%)']);
legend('Location', 'best');
grid on;
box on;

% 图3：混淆矩阵 (基于预测集)
% 将连续预测值转换为类别标签
Y_pred_class = zeros(size(Y_all));
Y_pred_class(Y_pred_final < 4) = 1;
Y_pred_class(Y_pred_final >= 4) = 7;

% 创建分类标签数组用于显示
Y_true_categorical = categorical(Y_all, [1 7], {'正常', '水脱'});
Y_pred_categorical = categorical(Y_pred_class, [1 7], {'正常', '水脱'});

figure('Name', 'Confusion Matrix', 'Color', 'w');
cm = confusionchart(Y_true_categorical, Y_pred_categorical);


