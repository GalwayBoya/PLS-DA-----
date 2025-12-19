% check_files.m - 用于检查光谱文件和标签文件样本数量是否一致
clear all; clc;

% 设置路径
SamplePath = fullfile(pwd,'Spectra Data');
files = dir(SamplePath);
num_file = size(files,1);
j = 0;
Str_mes = {};

% 获取所有 Mes_ 开头的文件
for i = 3:num_file
   if strncmp(files(i).name,'Mes',3)
      Str_mes{j+1} =  files(i).name(5:end);
      j = j+1;
   end
end
num_mes_file = j;

% 你在 main.m 中选择的数据集列表
selected_str = {'Data_6-8-7-P1-P3.csv','Data_9-1-20-P1-P3.csv','Data_10-1-41-P1-P3.csv','Data_10-42-70-P1-P3.csv','Data_11-1-35-P1.csv','Data_11-1-35-P2-P3.csv','Data_11-36-50-P1-P3.csv','Data_11-90-123-P1-P3.csv'};
num_dataset = length(selected_str);

fprintf('\n==================== 文件对齐检查报告 ====================\n');
fprintf('%-25s | %-25s | %-8s | %-8s | %-6s\n', '光谱文件名', '标签文件名', '光谱数', '标签数', '状态');
fprintf('------------------------------------------------------------------------------------------\n');

total_spectra = 0;
total_labels = 0;

for i_num_dataset = 1:num_dataset
    selected_spectra = selected_str{i_num_dataset};
    selected_str_mes = '';
    
    % 查找匹配的 Mes 文件
    for i=1:num_mes_file
        str_mes_i = Str_mes{i};
        % 匹配逻辑与 main.m 保持一致
        if strcmp(selected_spectra(6:end-9),str_mes_i(1:end-9))    
            selected_str_mes = str_mes_i;
        end
    end
    
    if isempty(selected_str_mes)
        fprintf('%-25s | %-25s | %-8s | %-8s | %-6s\n', selected_spectra, '未找到匹配', 'N/A', 'N/A', 'ERROR');
        continue;
    end

    % 1. 检查标签文件样本数
    str_mes_full = fullfile(SamplePath, ['Mes_' selected_str_mes]);
    try
        Data_struct = importdata(str_mes_full);
        if isstruct(Data_struct)
            Data = Data_struct.data;
        else
            Data = Data_struct; 
        end
        num_labels = size(Data, 1);
    catch
        num_labels = -1; % 读取错误
    end

    % 2. 检查光谱文件样本数 (使用 main.m 中的逻辑)
    str_spectra_full = fullfile(SamplePath, selected_spectra);
    try
        % 跳过前12行，和第1列
        data = csvread(str_spectra_full, 13, 1);
        data_col_1 = sum(data, 2);
        data_interval = find(data_col_1 == 0); % 找到分隔行
        num_spectra = length(data_interval);
    catch
        num_spectra = -1; % 读取错误
    end
    
    % 3. 比较并输出
    status = 'OK';
    if num_spectra ~= num_labels
        status = 'Mismatch'; % 不匹配
    end
    
    % 打印结果
    % 截断过长的文件名以便显示
    disp_spectra = selected_spectra;
    if length(disp_spectra) > 25, disp_spectra = [disp_spectra(1:22) '...']; end
    
    disp_mes = ['Mes_' selected_str_mes];
    if length(disp_mes) > 25, disp_mes = [disp_mes(1:22) '...']; end
    
    fprintf('%-25s | %-25s | %-8d | %-8d | %s\n', disp_spectra, disp_mes, num_spectra, num_labels, status);
    
    if num_spectra > 0, total_spectra = total_spectra + num_spectra; end
    if num_labels > 0, total_labels = total_labels + num_labels; end
end

fprintf('------------------------------------------------------------------------------------------\n');
fprintf('总计: 光谱样本总数 = %d, 标签样本总数 = %d\n', total_spectra, total_labels);
fprintf('差值: %d\n', total_labels - total_spectra);