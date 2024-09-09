function pos = drawSamplesUniformlyCirc(posCenter,radius,N)
pos = zeros(2,N);
phi = 2*pi*rand(1,N);
r = sqrt(rand(1,N));

pos(1,:) = (radius*r).*cos(phi)+ posCenter(1);
pos(2,:) =(radius*r).*sin(phi)+ posCenter(2);

end