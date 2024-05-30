function mi = make_cond_entropy(t,array,len,partitions)

hi=0;
hii=0;
count=0;
hpi=0;
hpj=0;
pij=0;
cond_ent=0.0;


h2 = zeros(partitions,partitions);

for i = 1:1:partitions
    h1(i)=0;
    h11(i)=0;
end

for i=1:1:len
    if i > t
        hii = array(i);
        hi = array(i-t);
        h1(hi) = h1(hi)+1;
        h11(hii) = h11(hii)+1;
        h2(hi,hii) = h2(hi,hii)+1;
        count = count+1;
    end
end

norm=1.0/double(count);
cond_ent=0.0;

for i=1:1:partitions
    hpi = double(h1(i))*norm;
    if hpi > 0.0
        for j = 1:1:partitions
            hpj = double(h11(j))*norm;
            if hpj > 0.0
                pij = double(h2(i,j))*norm;
                if (pij > 0.0)
                    cond_ent = cond_ent + pij*log(pij/hpj/hpi);
                end
            end
        end
    end
end

mi = cond_ent;