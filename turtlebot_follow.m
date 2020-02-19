rosshutdown;
ipaddress = "192.168.84.130";
rosinit(ipaddress,'NodeHost','192.168.254.1')
r = rospublisher('/mobile_base/commands/velocity');
vel = rosmessage(r);
dist = 1;
count = 0;
n = 1;
u = 1;
t = zeros(1,500);
m = zeros(1,500);
e = 0;
start = tic;
while e<98
    try
        loop = tic;
        imsub = rossubscriber('/camera/rgb/image_raw');
        img = receive(imsub);
        image = readImage(img);
        frame_x = 320;
        frame_y = 240;
        peopleDetector = vision.PeopleDetector;
        [bboxes, scores] = peopleDetector(image);
        %score = 1-scores;
        vel.Linear.X = 0.6;
        points = bbox2points(bboxes);
        centre_x = (points(1) + points(2))/2;
        centre_y = (points(1,2) + points(3,2))/2;
        imshow(image);
        hold on;
        rectangle('Position', bboxes);
        plot(centre_x, centre_y, 'ro', 'MarkerSize', 15);
        plot(frame_x, frame_y,'ro', 'MarkerSize', 15);
        dist = centre_x-frame_x;
        angle = -((dist/8)*3.14159265359)/180;
        vel.Angular.Z = angle;
        send(r,vel);
        t(n) = toc(loop);
        n = n+1;
    catch
        miss = tic;
        count = count + 1;
        %im = rossubscriber('/camera/rgb/image_raw');
        %img = receive(im);
        %imag = readImage(img);
        %imshow(imag)
        vel.Angular.Z = 0.2;
        vel.Linear.X = 0.0;
        send(r,vel);
        m(u) = toc(miss);
        u=u+1;
    end
    s = sum(t);
    d = s*0.6;
    e = toc(start);
end
disp(sum(m));
%c = {d, count, sum(m)};
%writecell(c, 'C:\Users\HP\Desktop\matlab.xlsx', 'Range', 'E53:G53');
