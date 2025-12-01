%average_moving.m：调用average_moving函数对光谱数据进行移动平均平滑。
%Normalize.m：调用Normalize函数对数据进行归一化处理。
%plsdacv_app.m：调用plsdacv_app函数进行 K 折交叉验证，评估模型性能。
%C_get_pls_da_model_all_APP.m：调用C_get_pls_da_model_all_APP函数训练 PLS-DA 模型并预测。
clear all;
clc;

% 参数设置
A = 10;
K = 5;
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
      Str_mes{j+1} =  files(i).name(5:end); % 将文件名中前缀"Mes"去除后存入Str_mes数组
      
      j = j+1;
   end
end
%%% Mes开头的文件数量
num_mes_file  = (j);   


% 选择特定的数据集
selected_str = {'Data_fuji apple_2021_12_24_13_16_32.csv'};
num_dataset = length(selected_str);  

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
    data = csvread(str,12,1);  
    wavelength = data(1,:);    % 波长信息
    data_col_1 = sum(data,2);  % 数据每行的和
    data_interval = find(data_col_1 == 0);  % 找到和为0的行
    num_sample = length(data_interval);     % 样本数量
    num_sample_i_dataset(1,i_num_dataset) = num_sample;

    % 光谱数据预处理参数
    % 波长范围
    wavelength_start = 563;
    wavelength_end = 1110;
  
    % 去除起始和结束的光谱点比例
    num_start = 0;
    num_end = 0;
  
    % 光谱强度范围  
    intensity_start = 0;
    intensity_end = 60000;
     
         % 处理csv文件中的光谱数据
    for i=1:num_sample
    
        % 确定波长范围的索引
        if i==num_sample
            % 此处减1是因为最后一行是白参考光谱
            ith_sample_spectra = data(data_interval(i)+1:end-1,location_wavelength_start:location_wavelength_end);    
            % ??????
            [Maxvalue,~] = max(ith_sample_spectra,[],2); %??????е?????
            DeletPointPosition = find(Maxvalue > str2double(intensity_end) | Maxvalue< str2double(intensity_start));
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % ???????
            Stvalue = ith_sample_spectra(:,10); %?????е??10?????????
            DeletPointPosition = find(Stvalue > 10000);
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % ?????????
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
    
            % ?????
            mean_sample_all_spectra(i,:) = mean(ith_sample_spectra_ex,1);
            
            % ???ο?
            white_reference(i,:) = data(end,location_wavelength_start:location_wavelength_end); 
  
        else
            % ???????????????β?ο?
            ith_sample_spectra =  data(data_interval(i)+1:data_interval(i+1)-2,location_wavelength_start:location_wavelength_end);    
            % ??????
            [Maxvalue,~] = max(ith_sample_spectra,[],2); %??????е?????
            DeletPointPosition = find(Maxvalue > str2double(intensity_end) | Maxvalue< str2double(intensity_start));
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % ???????
            Stvalue = ith_sample_spectra(:,10); %?????е??10?????????
            DeletPointPosition = find(Stvalue > 10000);
            ith_sample_spectra(DeletPointPosition,:) = [];
            DeletPointPosition = [];
    
            % ?????????
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
        
            % ?????
            mean_sample_all_spectra(i,:) = mean(ith_sample_spectra_ex,1);
            
            % ???ο?
            white_reference(i,:) = data(data_interval(i+1)-1,location_wavelength_start:location_wavelength_end); 
  
        end
 
    end
    
    
    mean_sample_all_spectra_all= [mean_sample_all_spectra_all; mean_sample_all_spectra];
    mean_sample_all_spectra = [];
    matrix_white_reference = [ matrix_white_reference; white_reference];
    white_reference = [];
end

% ???????????
Xpreprocess = mean_sample_all_spectra;

%%% ??????????
segment = 29;   % ???????????
Xpreprocess = average_moving(Xpreprocess,str2double(segment));
     
%%% ?????????
[~, ~,~,~,Xpreprocess,~]=Normalize(Xpreprocess,Xpreprocess);
     
%%% ??????????????????
% 1?????????,7???ù????
num_normal = find(Y==1);  % ???????1??????????
num_moldy = find(Y==7);   % ???????7??????????
X_normal = Xpreprocess(num_normal,:);  % ???????1?????????  
Y_normal = Y(num_normal,:);            % ???????1????????      
X_moldy = Xpreprocess(num_moldy,:);    % ???????7?????????
Y_moldy = Y(num_moldy,:);              % ???????7????????

% ??????????????ù??????30?????????????????????????  
if length(num_normal)>length(num_moldy)+30
    X_normal_part = X_normal(1:length(num_moldy),:);
    Y_normal_part = Y_normal(1:length(num_moldy));
    X = [X_normal_part;X_moldy];
    Y = [Y_normal_part;Y_moldy];
else
    X_moldy_part = X_moldy(1:length(num_normal),:);
    Y_moldy_part = Y_moldy(1:length(num_normal));
    X = [X_normal;X_moldy_part];
    Y = [Y_normal;Y_moldy_part];
end
  
% PLSDA???????
CV = plsdacv_app(X,Y,str2double(A),K);
classificationresult = CV.result;
n = CV.optLV;
  
ture_value_Y = Y;
predicted_value_Y = CV.YR_original(:,n);
  
% PLS-DA??????????
error_specific = 0.5;  % ???÷??????
[result,result_ud,model,~,~]=C_get_pls_da_model_all_APP(X,Y,Xpreprocess,Y,error_specific);
