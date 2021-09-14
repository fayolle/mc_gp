clc;
clear variables;
clear global;
close all;

rng(1);

% contour plots of the exact solution and the MC solution
x = linspace(-0.5, 0.5);
y = linspace(-0.5, 0.5);
[X, Y] = meshgrid(x, y);

V = zeros(size(X));
G = zeros(size(X));

for i=1:size(X,1)
   for j=1:size(X,2)
       p = [X(i,j) Y(i,j)];
       V(i,j) = solveHarmonic(p, @(x) distToSquare(x), @(x) g(x), 256, 0);
       G(i,j) = g(p);
   end
end

figure();
contourf(X,Y,V,50,'LineColor','none');
title('MC solution');
figure();
contourf(X,Y,G,50,'LineColor','none');
title('Exact solution');

% relative error
E = V - G;
re = norm(E(:))/norm(G(:));
disp(re);


% relative error wrt the number of paths used
npaths = [8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536];
rel_errors = zeros(size(npaths));
p = [0.25 0.0];
gp = g(p); % reference value
for i=1:length(npaths)
    sp = solveHarmonic(p, @(x) distToSquare(x), @(x) g(x), npaths(i), 0);
    rel_errors(i) = abs(gp - sp)/abs(gp);
end
figure();
plot(rel_errors);
title('Relative error wrt number of paths');
xticks(1:2:length(npaths));
xticklabels(npaths(1:2:length(npaths)));


% show trajectory of paths
sp = solveHarmonic(p, @(x) distToSquare(x), @(x) g(x), 16, 1);


function d = distToSquare(p)
% dist function to unit length square centered at (0,0)
d1 = abs(p(1)-0.5);
d2 = abs(p(1)+0.5);
d3 = abs(p(2)-0.5);
d4 = abs(p(2)+0.5);
d = min(d1, min(d2, min(d3, d4)));
end

function v = g(p)
% example of harmonic function
v = p(1)^2-p(2)^2;
end

function p = randCircle()
% random point on unit circle
t = 2.0*pi*rand();
p = [cos(t) sin(t)];
end

function p = randCircle2()
% random point on unit circle
% very slow compared to randCircle() above
% (because of normrnd)
p = normrnd(0.0,1.0,[1 2]);
l = sqrt(p(1)*p(1) + p(2)*p(2));
p = p./l;
end

function s = solveHarmonic(p0, dist, g, n, show_paths)
% p0: point at which to evaluate
% dist: dist function defining the boundary
% g: boundary condition
% n: number of paths
% show_paths: 0 (no display) / 1 (display)

neps = 1e-3; % numerical tolerance
max_steps = 128; % max number of steps on a path
s = 0.0;

if show_paths == 1
    figure;
end

for i=1:n
    p = p0;
    
    if show_paths == 1
        ps = [p];
    end
    
    steps = 0;
    for j=1:max_steps
        r = dist(p); % ball radius
        if r<neps
            break;
        end
        p = p + r.*randCircle();
        
        if show_paths == 1
            ps = [ps; p];
        end
        
        steps = steps + 1;
    end
    
    if show_paths == 1
        hold on;
        plot(ps(:,1),ps(:,2), '-');
        hold off;
    end
    
    s = s + g(p);
end

s = s / n;

if show_paths == 1
    title('Trajectories of paths');
end

end

