% simple hello world
function hello_world
parpool(2);
spmd
    if (labindex == 1)
        fprintf('Number of labs = %g\n',numlabs);
    end
    fprintf('Hello world from labindex %g\n',labindex);
end
delete(gcp);
return