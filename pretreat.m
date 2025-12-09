% 预处理数据矩阵X(所有数据减去均值)
function [X,para1,para2]=pretreat(X,method,para1,para2)
% X:原始数据矩阵、method:预处理方法、para1,para2:预处理参数
%+++   data pretreatment
%+++ HD Li, Central South University


% 根据输入参数个数选择不同的预处理方式
% 2个参数时，依据method进行预处理，并计算para1,para2
% 4个参数时，依据para1,para2进行预处理
if nargin==2
  [Mx,Nx]=size(X);
   if strcmp(method,'autoscaling') % 自标度化
    para1=mean(X); % 均值
    para2=std(X); % 标准差
   elseif strcmp(method,'center') % 均值中心化
    para1=mean(X); % 均值
    para2=ones(1,Nx); % 标准差为1
   elseif strcmp(method,'minmax') % 最小-最大归一化
    para1=min(X); % 最小值
    maxv=max(X); % 最大值
    para2=maxv-para1;  % 极差
   elseif strcmp(method,'pareto'); % Pareto缩放
    para1=mean(X); % 均值
    para2=sqrt(std(X)); % 标准差的平方根
   else
    display('Wrong data pretreat method!');
   end
   
   % 减去均值，除以标准差
   for i=1:Nx
     X(:,i)=(X(:,i)-para1(i))/para2(i);
   end
   
elseif nargin==4
   [Mx,Nx]=size(X);
   for i=1:Nx     
     X(:,i)=(X(:,i)-para1(i))/para2(i);
   end
end



