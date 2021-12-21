clc
clear all
close all

%% Taking the Video File As Input

tic
addpath(genpath(pwd))
tic
vid=uigetfile('.avi','select an video');
Video=VideoReader(vid);
get(Video);

%% Finding the Background

frame1 = (read(Video,297));
frame2 = (read(Video,1));
image= 255-(frame2- frame1);
background =255- (image - frame1);

frame = (read(Video,300));

%% Reading the video files frame by frame

nframes = Video.NumFrames;
I = read(Video, 1);
videoWriterObject = zeros([size(I,1) size(I,2) 3 nframes], class(I));

%% Worm Segmentation and Tracking Process

for k =1:nframes
    k
singleFrame = read(Video, k);
image=(background)-singleFrame;

%% Removing Noise

I = im2gray(image);
I=medfilt2(I,[5,5]);

%% Image processing

BW=imbinarize(I);
conn=bwareaopen(BW,3000);

%% Binary Morphology Operaion

se1 = strel('disk',5);
dial = imdilate(conn, se1);
dial2=imfill(dial,'holes');

%% Tracking the worm in red color

obj=bwareafilt(dial, 1, 'largest');
obj1=imfill(obj,'holes');
st = regionprops(obj1, 'BoundingBox' ); 
BB = st(1).BoundingBox; 
rectangle('Position', [BB(1),BB(2),BB(3),BB(4)], 'EdgeColor','r','LineWidth',2 );
rect=[BB(1) BB(2) BB(3) BB(4)]; 
ex= imcrop(dial2,rect);
ikk(k)=bwconncomp(ex,8);
g=ikk(k).NumObjects;

%% Flagging frames 

if (g==1)
    
    [labeledImage, numBlobs] = bwlabel(obj1);
    coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); 
    final= coloredLabels+singleFrame;
    figure(1);
    imshow(final);
    
    videoWriterObject(:,:,:,k)=final;

else
    
    o=obj1+(~obj1);
    [labeledImage, numBlobs] = bwlabel(o);
    coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle');
    final= coloredLabels+singleFrame;
    figure(1);
    imshow(final);
    
    videoWriterObject(:,:,:,k)=final;
end
end
toc
%% Saving the video to the Disk
tic
VidObj = VideoWriter(strcat(num2str(numel(uigetdir(vid))+1),'_processed_',vid));%; %set your file name and video compression
VidObj.FrameRate = 5; %set your frame rate
open(VidObj);
writeVideo(VidObj, videoWriterObject);
close(VidObj);
toc
