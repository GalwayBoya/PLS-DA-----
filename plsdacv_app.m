% K折交叉验证，评估模型性能
function CV=plsdacv_app(X,y,A,K)
%+++ K-fold Cross-validation for PLS-DA
%+++ Input:  X: m x n  (Sample matrix)
%            y: m x 1  (measured property)
%            A: The maximal number of latent variables for cross-validation
%            K: fold. when K=m, it is leave-one-out CV
%      
% 新版本要求，将水浸果的标签设置为7，正常果为1，中间值为4

[y,indexyy]=sort(y);
X=X(indexyy,:);


[Mx,Nx]=size(X);
A=min([size(X) A]);
yytest=nan(Mx,1);
YR=nan(Mx,A);
YR_original = nan(Mx,A);

groups = 1+rem(0:Mx-1,K);
for group=1:K
    
    calk = find(groups~=group);
    testk = find(groups==group);  
    
    Xcal=X(calk,:);
    ycal=y(calk);
    
    Xtest=X(testk,:);
    ytest=y(testk);
    
    %   data pretreatment
    [Xs,xpara1,xpara2]=pretreat(Xcal,'center');
 
     [ys,ypara1,ypara2]=pretreat(ycal,'center');   
    % ys=ycal;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [B,Wstar,T,P,Q]=pls_nipals(Xs,ys,A);   
 
    yp=[];
    yp_original = [];
    
    for j=1:A
        B=Wstar(:,1:j)*Q(1:j);
        %+++ calculate the coefficient linking Xcal and ycal.
        C=ypara2*B./xpara2';
     
        coef=[C;ypara1-xpara1*C;];
      
        %+++ predict
        Xteste=[Xtest ones(size(Xtest,1),1)];
        ypred=Xteste*coef;
        yp_original = [yp_original ypred];
        ypred(ypred>=4)=7;
        ypred(ypred<4)=1;
        yp=[yp ypred];
    end
    
    YR(testk,:)=[yp];
    YR_original(testk,:)=[yp_original]; 
    yytest(testk,:)=ytest;
   
end

%+++ return the original order
YR(indexyy,:)=YR;
y(indexyy)=y;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error=YR-repmat(y,1,A);   % 预测值减去真值
 
  for i=1:A 
%   recall(1,i)=1-length(find(error(:,i)==-6))/length(find(y==7)); %1-misclassification accuracy  伤病果正确率   水浸果（7）的识别正确率     
%   specificity(1,i)=1-length(find(error(:,i)==6))/length(find(y==1)); %1-misclassification accuracy  健康果正确率   正常果（1）的识别正确率
%   accuracy_all(1,i) = length(find(error(:,i)==0))/Mx;
  recall(1,i)=1-length(find(error(:,i)==6))/length(find(y==1)); %Recall = TP?/(TP+FN) = (TP+FN-FN)/(TP+FN) = 1-FN/(TP+FN)     
  specificity(1,i)=1-length(find(error(:,i)==-6))/length(find(y==7)); %Specificity = TN/(TN+FP) = (TN+FP-FP)/(TN+FP) = 1-FP/(TN+FP)
  accuracy_all(1,i) = length(find(error(:,i)==0))/Mx;
  end
  
  [accuracy_max,index] = max(accuracy_all);
%   PRESS=sum(error.^2);
%   cv= roundn(sqrt(PRESS/Mx),-3);  % 对RMSECV保留3位小数，四舍五入
%   [RMSEP,index]=min(cv);index=index(1);
%    r_cv=corrcoef(YR(:,index),y);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%+++ output  %%%%%%%%%%%%%%%%
  CV.Ypred=YR;
  CV.result=[recall;specificity;accuracy_all];  %recall 健康果（1）的识别正确率  specificity 伤病果（7）的识别正确率  
  CV.optimal = [index accuracy_max];
  CV.YR_original = YR_original;
%   CV.RMSECV_min=RMSEP;
%   CV.optLV=index;
%   CV.r=r_cv(1,2);
end
