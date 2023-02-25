clear all 
close all

myDir = uigetdir; %gets directory
myFiles = dir(fullfile(myDir,'*.tif')); 


for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myFiles(k).folder, baseFileName);
   
  A = imread(fullFileName) ;
    B = imbinarize(A); % binarize image A, resulting in image B
    C = watershed(B); % perform watershedding
    D = imclearborder(C); % remove objects at the edge
    %E = label2rgb (D, 'hsv', 'k', 'ma'); %label the identified objects in bright colours
    F = bwlabel(D) ;
    figure
    imagesc(F); %display the segmented image
    imwrite(F,[fullFileName 'segment.tif'])
    
    %find cell centroids
    
    close all

cent = regionprops(F,'centroid'); 
centroids = cat(1, cent.Centroid);


%label cell centroids with corresponding object numbers
figure
imshow(F)

hold on

    for k = 1:numel(cent) 
        c = cent(k).Centroid ;
        text(c(1), c(2), sprintf('%d', k), ... 
            'HorizontalAlignment', 'center', ... 
            'VerticalAlignment', 'middle') ;
        end

saveas(gcf,[fullFileName 'cell_number.png'])
hold off

close all

%%calculate cell geometric properties, write a table with calculated
%%properties 'geometrymeasurements.csv'

orient = regionprops(F,'Orientation');
or = cat(1,orient.Orientation);
majoraxis = regionprops(F,'MajorAxisLength');
ma = cat(1,majoraxis.MajorAxisLength);
minoraxis = regionprops(F,'MinorAxisLength');
mi = cat(1,minoraxis.MinorAxisLength);
aspectratio = ((mi)./(ma)); %calculate geometry measurements of the cells
Y = or.*(pi/180); %very important change angle values to radians
Circularity = regionprops(F,"Circularity");


stats = regionprops('table',F,'Centroid','Area','MajorAxisLength','MinorAxisLength','Orientation','Eccentricity','Perimeter','Circularity');

writetable(stats,[fullFileName 'stats.csv'])
    
end
