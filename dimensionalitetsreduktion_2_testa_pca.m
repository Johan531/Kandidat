%% Using PCA to do 
% pos -> code -> pos_reconstruct
% pos -> code is encoding or dimensionality reduction
% code -> pos_reconstruct is decoding or unpacking of code

%% Do the PCA
KK = 3; % using 40 singular components
model = kalle_make_pca(pos,KK);

%% calculate dimensionality reduction for data

code = kalle_pca_encode(model,pos);

%% Reconstruct from code

pos_reconstruct = kalle_pca_decode(model,code);

%% Visualize standard deviation of each mode

figure(5);
plot(diag(model.s),'*');
xlabel('Mode nr');
ylabel('Standard deviation');

%% Visualize mean and mode images

figure(6);
subplot(4,4,1);
colormap(gray);
imagesc(reshape(model.data_mean,50,150));
for k = 1:min(KK,15);
    subplot(4,4,k+1);
    colormap(gray);
    imagesc(reshape(model.u(:,k),50,150));
end


%% Visualize code for each image

figure(7);
plot(code(:,1),code(:,2),'*');
text(code(:,1),code(:,2), string(index));
title('Using two dimensions');

figure(8);
hold off;
plot3(code(:,1),code(:,2),code(:,3),'b*');
text(code(:,1),code(:,2), code(:,3), string(index));
title('Using three dimensions');

%% Compare original with reconstruction

%for k = 1:size(pos,4);
for k = 50:50:500;
    figure(9);
    subplot(1,2,1);
    colormap(gray);
    imagesc(pos(:,:,:,k));
    title('Original');
    subplot(1,2,2);
    colormap(gray);
    imagesc(pos_reconstruct(:,:,:,k));
    title(['Reprojection using ' num2str(KK) ' compponents.']);
    pause(1);
end


