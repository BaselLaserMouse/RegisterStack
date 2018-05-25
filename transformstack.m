function transformed = transformstack(sourcestack, targetstack, tform)
% transformed = transformstack(sourcestack, targetstack, tform)
%
% reslice sourcestack in the planes of targetstack using transformation
% matrix tform


% load zstack into RAM
[ nx, ny, ~, nz ] = size(targetstack);
[ maxx, maxy, nc, maxz ] = size(sourcestack);

% preallocate ram
transformed = zeros(nx,ny,nc,nz);
% coordinate matrix in regavg space
v = ones(nx*ny,4);
for indY=1:ny
    v((indY-1)*nx+[1:nx],1) = 1:nx;
    v((indY-1)*nx+[1:nx],2) = indY;
end

% loop through planes
for indZ = 1:nz
    fprintf('Make plane %d...\n',indZ);
    v(:,3) = indZ;
    % transform in zstack coords
    m = v * tform;
    im = zeros(nx,ny,nc);
    % fetch nearest neighbour values
    for indX=1:nx
        for indY=1:ny
            x = round(m((indY-1)*nx+indX,1));
            y = round(m((indY-1)*nx+indX,2));
            z = round(m((indY-1)*nx+indX,3));
            if x>=1 && x<=maxx && y>=1 && y<=maxy && z>=1 && z<=maxz
                im(indX,indY,:) = sourcestack(x,y,:,z);
            end
        end
    end
    % save result
    transformed(:,:,:,indZ) = im;
end


