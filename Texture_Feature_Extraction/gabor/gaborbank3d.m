%3D GABOR FILTER BANK CREATION
%For varying the parameters associated with GABOR3DKERNS
%BANDWIDTH (4) = [0.1,0.4,0.7,1]
%WAVELENGTH (4) = [1.1,1.4,1.7,2]
%ORIENTATIONS (6 x 2 sets) = [0,pi/6,pi/3,pi/2,2pi/3,5pi/6]
%TOTAL 4*4*6*6 = 576
%Satish Viswanath, Jul 2008
%Updated Gabor params, Mar 2013
%Based off parameters from GABORBANK2D

g=0;
%for b = 0.1:.3:1.2
%b=0.5;
b=1;

    for l=[.8800,1.4818,2.0747,2.6676,3.2606]
    %l=1.5;
        for xy = (0:7)*pi/8
        %xy=0;
            for xz = (0:3)*pi/4
            %xz=0;
                g = g+1;
                [gb_c,gb_s, ws] = gabor3dkerns(xy,xz,l,b);
                gabor_data(g).cos = gb_c;
                gabor_data(g).sin = gb_s;
                gabor_data(g).title = sprintf('Gabor XY-%c=%.3f, XZ-%c=%.3f, %c=%.3f, BW=%.1d',952,xy,952,xz,955,l,b);
                gabor_data(g).ws = ws;
                gabor_data(g).params = [xy,xz,l,b];
                

            end
        end
    end

save P3_gaborbank3D.mat gabor_data -v7.3 %note: will be a huge file!
        