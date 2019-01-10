expanse = [8200736  22008619 21978832 1396826 1470992]

subopt = [26.6088  26.9731 23 37 34]
plot(expanse,subopt,'g*')
xlabel('Expanded states')
ylabel('Suboptimality')
drawnow

zx = 10000*[0.0012 0.0037 0.0038  0.0012   0.0016         0.0037        0.0022    0.0034  0.0016];

zy =[20222286    20134486    19954516    20397531       21978832       22009647      1488818     1470992     1759694];

plot(zy,zx,'g*')
xlabel('Expanded states')
ylabel('Suboptimality')
drawnow