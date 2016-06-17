function [ cp_vivo, cp_vitro, stack_vivo, stack_vitro ] = loadimreg(fname)
% load reg file
load(fname);

% convert control points to original axes
cp_vivo = zeros(4,3);
cp_vitro = zeros(4,3);
% convert for the in vivo points
for ind = 1:4
    cp_vivo(ind,:)=findorignlcoor([pts{2,ind}(2); pts{2,ind}(1); pts{2,ind}(3)],stack_vivo_green,Tform1)';
    cp_vitro(ind,:)=findorignlcoor([pts{4,ind}(2); pts{4,ind}(1); pts{4,ind}(3)],stack_vitro_green,Tform2)';    
end

stack_vivo = cat(3,permute(stack_vivo_green,[1 2 4 3]),...
    permute(stack_vivo_red,[1 2 4 3]));
stack_vitro = cat(3,permute(stack_vitro_green,[1 2 4 3]),...
    permute(stack_vitro_red,[1 2 4 3]));
end

function [orignl_coor]=findorignlcoor(new_coor,stack,TformM)

%get the dimensions of the stack
[l,w,h]=size(stack);
lh=l/2;
wh=w/2;
hh=h/2;

%find and create an array with the minimal size needed for holding rotated 
%stack
dia=zeros(3,1);
vertex=zeros(3,4);
vertex(:,1)=abs(TformM*[lh;wh;hh]);
vertex(:,2)=abs(TformM*[lh;-wh;hh]);
vertex(:,3)=abs(TformM*[lh;wh;-hh]);
vertex(:,4)=abs(TformM*[lh;-wh;-hh]);
for i=1:3
    dia(i)=ceil(2*max((vertex(i,:))));
end;

orignl_coor=TformM^-1*(new_coor-dia/2)+[lh;wh;hh];

end