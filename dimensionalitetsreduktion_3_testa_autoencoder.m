%% Using deep learning autoencoders to do 
% pos -> code -> pos_reconstruct
% pos -> code is encoding or dimensionality reduction
% code -> pos_reconstruct is decoding or unpacking of code


%% Define deep learning architecture
% here layers 2-8 are the encoding and layers 9-13 are the decoding

layers = [
    imageInputLayer([50 150 1])
    convolution2dLayer([3 3],10,'Padding',0)
    reluLayer
    maxPooling2dLayer(3,'Stride',2)
    convolution2dLayer([3 3],10,'Padding',0)
    reluLayer
    maxPooling2dLayer(3,'Stride',2)
    convolution2dLayer([10 35],3,'Padding',0)
    transposedConv2dLayer([10 35],10,'Stride',1,'Cropping',0)
    reluLayer
    transposedConv2dLayer([6 6],40,'Stride',2,'Cropping',0)
    reluLayer
    transposedConv2dLayer([4 4],1,'Stride',2,'Cropping',0)
    regressionLayer];

%% Set optimization (training) parameters

miniBatchSize = 400;
max_epochs = 2000;
learning_rate = 0.01;
options = trainingOptions( 'adam',...
    'MaxEpochs',max_epochs,...
    'MiniBatchSize', miniBatchSize,...
    'InitialLearnRate',learning_rate, ...
    'Plots', 'training-progress', ...
    'ValidationData',{pos,pos});

if 0, 
    %Tr�na denna g�ng och spara n�t
    net = trainNetwork(pos_smooth, pos_smooth, layers, options);
    save trained_auto_net00004
else
    %Tr�na inte denna g�ng utan anv�nd ett n�t som �r sparat
    load trained_auto_net00003
end,

%% Cut up the trained net into the encoder and decoder parts

% encoder
tmp = saveobj(net);
tmp.Layers = tmp.Layers([1:8 14]);
encoder = SeriesNetwork.loadobj(tmp)
blubb = predict(encoder,pos(:,:,:,1))

% decoder
tmp = saveobj(net);
tmp.Layers = [imageInputLayer([1 1 3],'Normalization','none');tmp.Layers([9:14])];
decoder = SeriesNetwork.loadobj(tmp)
blubb2 = predict(decoder,reshape(blubb(1,:),[1 1 3]))

%%

code = predict(encoder,pos);

pos_reconstruct = predict(decoder,reshape(code',1,1,3,size(code,1)));


%% Visualize code for each image

figure(7);
plot(code(:,1),code(:,2),'*');
title('Using two dimensions');

figure(8);
hold off;
plot3(code(:,1),code(:,2),code(:,3),'b*');
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
    pause(0.5);
end


%%
mm = mean(code);
ss = std(code);
ee = eye(3);
figure(11);
for k = 1:3;
    subplot(1,2,1);
    colormap(gray);
    meanimage = predict(decoder,reshape(mm,[1 1 3]));
    imagesc(meanimage);
    for th = linspace(0,2*pi,100);
        subplot(1,2,2);
        colormap(gray);
        meanimage = predict(decoder,reshape(mm+cos(th)*ss.*ee(k,:),[1 1 3]));
        imagesc(meanimage);
        title(['Mode: ' num2str(k) ' of ' num2str(3)]);
        pause(0.05);
    end;
    pause(1);
end;
