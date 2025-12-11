function [out1, out2, out3, out4, out5, out6] = SNV(Xcal, Xpre)
% SNV 标准正态变量变换 (Standard Normal Variate)
% 作用：消除样本颗粒大小、表面散射不同引起的光谱差异
% 接口设计：完全参照 Normalize.m 的输入输出格式，以便直接替换使用
% main.m 调用方式：[~, ~,~,~,Xpreprocess,~]=Normalize(Xpreprocess,Xpreprocess);
% 因此，关键是将处理后的数据赋值给第5个输出参数

    % --- 1. 对 Xcal 进行 SNV 处理 ---
    % 计算每一行（每个样本）的平均值
    mean_cal = mean(Xcal, 2);
    % 计算每一行（每个样本）的标准差
    std_cal = std(Xcal, 0, 2);
    
    % 防止标准差为0导致除以0的错误（虽然在光谱中很少见）
    std_cal(std_cal == 0) = eps;
    
    % SNV公式：(原始光谱 - 平均值) / 标准差
    % 使用 bsxfun 或 MATLAB 新版广播机制进行矩阵运算
    Xcal_snv = (Xcal - mean_cal) ./ std_cal;


    % --- 2. 对 Xpre 进行 SNV 处理 ---
    mean_pre = mean(Xpre, 2);
    std_pre = std(Xpre, 0, 2);
    std_pre(std_pre == 0) = eps;
    Xpre_snv = (Xpre - mean_pre) ./ std_pre;


    % --- 3. 分配输出参数 ---
    % Normalize.m 定义了6个输出，main.m 中使用的是第5个
    % 为了保险起见，我们将所有对应的输出都赋值为 SNV 的结果
    
    out1 = Xcal_snv;
    out2 = Xpre_snv;
    out3 = Xcal_snv;
    out4 = Xpre_snv;
    out5 = Xcal_snv; % <--- main.m 实际使用的是这个
    out6 = Xpre_snv;

end
