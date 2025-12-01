% 训练PLS-DA模型并预测
function [result,result_ud,model,matrix_num_delet,matrix_ypred_pre]=C_get_pls_da_model_all_APP(X,y,Xt,yt,error_specific)

% 得到主成分最大为20个的PLS模型，并用得到的模型对校正集(X,y)和预测集(Xt,yt)的建模和预测
% 其中，X和Xt为光谱数据，y和yt为对应的标签
% 标签格式：水浸果为7，正常果为1，中间值为4
% 模型预测大于4的为水浸果，小于4为正常果
% error_specific为误差阈值，预测值和实际标签之差的绝对值大于该阈值的样本为异常样本，需要进行剔除

[Mx,Nx]=size(X);
[Mxt Nxt]=size(Xt);

%+++ check effectiveness of A.
A=20;

%+++ data pretreatment
[Xs,xpara1,xpara2]=pretreat(X,'center');
[ys,ypara1,ypara2]=pretreat(y,'center');

%+++ Use the pretreated data to build a PLS model
[B,Wstar,T,P,Q,W]=pls_nipals(Xs,ys,A); % notice that here, B is the regression coefficients linking Xs and ys.

%+++ get regression coefficients that link X and y (original data) ************
coef=zeros(Nx+1,A);
for j=1:A
    Bj=Wstar(:,1:j)*Q(1:j);
    C=ypara2*Bj./xpara2';
     
   coef(:,j)=[C;ypara1-xpara1*C;];
end

%+++ ********************************************
x_expand=[X ones(Mx,1)];
xt_expand=[Xt ones(Mxt,1)];

model=coef;
matrix_num_delet = zeros(Mxt,A);

y_model_da = zeros(Mx,1);% 用于存PLS-DA的校正集标签
yt_model_da = zeros(Mxt,1);% 用于存PLS-DA的预测集标签

% 得到模型预测值
for i=1:20
y_model=x_expand*coef(:,i); % 校正集模型预测值
yt_model=xt_expand*coef(:,i); % 预测集模型预测值

y_model_da(find(y_model>=4))=7;
y_model_da(find(y_model<4))=1;
 
yt_model_da(find(yt_model>=4))=7;
yt_model_da(find(yt_model<4))=1;
  
matrix_ypred_pre(:,i) = yt_model;

% 校正集结果
calibration_accuracy_healthy(1,i)=1-length(find((y_model_da-y)==6))/length(find(y==1));  % 健康果（标签1）的正确率    
calibration_accuracy_bruised(1,i)=1-length(find((y_model_da-y)==-6))/length(find(y==7)); % 伤病果（标签7）的正确率   
calibration_accuracy(1,i)=length(find((y_model_da-y)==0))/length(y);                     % 总正确率

% 预测集结果
prediction_accuracy_healthy(1,i)=1-length(find((yt_model_da-yt)==6))/length(find(yt==1)); % 健康果（标签1）的正确率
prediction_accuracy_bruised(1,i)=1-length(find((yt_model_da-yt)==-6))/length(find(yt==7));% 伤病果（标签7）的正确率 
prediction_accuracy(1,i)=length(find((yt_model_da-yt)==0))/length(yt);                    % 总正确率

% 对预测集 预测误差大于error_specific的进行剔除
error = [];
error = yt - yt_model;
% 将pls预测值和真实值之差的绝对值大于error_specific的去掉
num_delet = find ( (error <-(3+error_specific) & yt ==1) | (error >(3+error_specific) & yt ==7)  );  
matrix_num_delet(num_delet,i) = 1;  % 记录下剔除的样本，置为1
size_num_delet(1,i) = length(num_delet); 

yt_model_da_ud = yt_model_da;
yt_ud = yt;

yt_model_da_ud(num_delet) = [];
yt_ud(num_delet) = [];

yt_model_da_ud(find(yt_model_da_ud>=4))=7;
yt_model_da_ud(find(yt_model_da_ud<4))=1;
 
% 删除异常点后的新结果
prediction_accuracy_healthy_ud(1,i)=1-length(find((yt_model_da_ud-yt_ud)==6))/length(find(yt_ud==1));
prediction_accuracy_bruised_ud(1,i)=1-length(find((yt_model_da_ud-yt_ud)==-6))/length(find(yt_ud==7));
prediction_accuracy_ud(1,i)=length(find((yt_model_da_ud-yt_ud)==0))/length(yt_ud);

end

% 校正集结果
% calibration_accuracy_healthy --- 灵敏度（健康果的识别率）
% calibration_accuracy_bruised --- 特异度（伤病果的识别率）
% calibration_accuracy         --- 准确率（健康果和伤病果被正确识别占总数的比例）
% 预测集结果
% prediction_accuracy_healthy --- 灵敏度（健康果的识别率）
% prediction_accuracy_bruised --- 特异度（伤病果的识别率）
% prediction_accuracy         --- 准确率（健康果和伤病果被正确识别占总数的比例）
result=[calibration_accuracy_healthy;calibration_accuracy_bruised;calibration_accuracy;prediction_accuracy_healthy;prediction_accuracy_bruised;prediction_accuracy];

% 剔除异常点后的结果
result_ud = [size_num_delet;prediction_accuracy_healthy_ud;prediction_accuracy_bruised_ud;prediction_accuracy_ud];


