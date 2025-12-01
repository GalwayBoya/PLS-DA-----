% % MATLAB 环境测试脚本
% % 保存为 test_environment.m 文件后运行

% fprintf('=== MATLAB 环境测试 ===\n');

% % 1. 测试基本输出
% fprintf('1. 基本输出功能：正常\n');

% % 2. 测试基本计算
% a = 5;
% b = 3;
% result = a + b;
% fprintf('2. 基本计算测试：%d + %d = %d\n', a, b, result);

% % 3. 测试矩阵操作
% matrix = [1 2 3; 4 5 6; 7 8 9];
% fprintf('3. 矩阵操作测试：\n');
% disp('示例矩阵：');
% disp(matrix);

% % 4. 测试图形功能
% try
%     figure;
%     x = 0:0.1:2*pi;
%     y = sin(x);
%     plot(x, y);
%     title('MATLAB 图形功能测试 - 正弦波形');
%     xlabel('x');
%     ylabel('sin(x)');
%     grid on;
%     fprintf('4. 图形功能测试：正常（应该显示一个正弦波图形）\n');
% catch
%     fprintf('4. 图形功能测试：失败\n');
% end

% % 5. 显示系统信息
% fprintf('\n=== 系统信息 ===\n');
% fprintf('MATLAB 版本: %s\n', version);
% fprintf('安装路径: %s\n', matlabroot);
% fprintf('当前工作目录: %s\n', pwd);

% % 6. 测试文件读写
% try
%     test_data = [1 2 3 4 5];
%     save('test_file.mat', 'test_data');
%     load('test_file.mat');
%     delete('test_file.mat'); % 清理测试文件
%     fprintf('5. 文件读写测试：正常\n');
% catch
%     fprintf('5. 文件读写测试：失败\n');
% end

% fprintf('\n=== 测试完成 ===\n');
% fprintf('如果所有项目都显示"正常"，则 MATLAB 环境安装正确！\n');
clc;
clear;
a = [1,0,5];
b = {1,0,5};
c = [9,5,7];
a + c;
str_mes = 'Mes_zhangwenshuo';

