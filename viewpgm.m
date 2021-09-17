im = im2double(imread('./test.pgm'));
figure,imshow(im),title('WoS');

% denoise the image a bit
net = denoisingNetwork('DnCNN');
im2 = denoiseImage(im, net);
figure,imshow(im2),title('Denoised WoS');