% 归一化处理
function [Xcal_normalize_std, Xpre_normalize_std,Xcal_normalize_minmax,Xpre_normalize_minmax,Xcal_normalize_max,Xpre_normalize_max]=Normalize(Xcal,Xpre)

  
 [m,n]=size(Xcal);
 [mp,np]=size(Xpre);
 
 
 %standard normalization
 
 for i = 1:m
    Xcal_normalize_std(i,:)=Xcal(i,:)/norm(Xcal(i,:));
 end

 
 for i = 1:mp
    Xpre_normalize_std(i,:)=Xpre(i,:)/norm(Xpre(i,:));
 end
 
 
 %minmax normalization
 
 [Xcal_normalize_minmax,PScal] = mapminmax(Xcal);
 [Xpre_normalize_minmax,PSpre] = mapminmax(Xpre);
 
 
 
 %max normalization
 for i = 1:m
    Xcal_normalize_max(i,:)=Xcal(i,:)/max(Xcal(i,:));
 end

 
 for i = 1:mp
    Xpre_normalize_max(i,:)=Xpre(i,:)/max(Xpre(i,:));
 end
 
 
 
 
end