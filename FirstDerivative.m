function [out1, out2, out3, out4, out5, out6] = FirstDerivative(Xcal, Xpre)
% FirstDerivative 一阶导数预处理
% 作用：消除基线平移，分离重叠峰
% 接口设计：完全参照 Normalize.m 的输入输出格式

    % --- 1. 对 Xcal 求一阶导数 ---
    % diff(X, 1, 2) 对每一行求一阶差分
    % 结果列数会少1，需要补一列0以保持维度一致
    Xcal_d1 = diff(Xcal, 1, 2);
    Xcal_d1 = [zeros(size(Xcal,1), 1), Xcal_d1]; 

    % --- 2. 对 Xpre 求一阶导数 ---
    Xpre_d1 = diff(Xpre, 1, 2);
    Xpre_d1 = [zeros(size(Xpre,1), 1), Xpre_d1];

    % --- 3. 分配输出参数 ---
    out1 = Xcal_d1;
    out2 = Xpre_d1;
    out3 = Xcal_d1;
    out4 = Xpre_d1;
    out5 = Xcal_d1; % main.m 使用此输出
    out6 = Xpre_d1;

end
