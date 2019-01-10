function str = hrBytes(i)
%% Converts a number of bytes into a better human-readable string
% Vadim Bulitko
% Oct 3, 2016

if (i < 1024)
    str = sprintf('%d bytes',i);
elseif (i < 1024^2)
    str = sprintf('%0.1f Kbytes',i/1024);
elseif (i < 1024^3)
    str = sprintf('%0.1f Mbytes',i/(1024^2));
elseif (i < 1024^4)
    str = sprintf('%0.1f Gbytes',i/(1024^3));
else
    str = sprintf('%0.1f Tbytes',i/(1024^4));
end

return
