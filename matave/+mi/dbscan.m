function [assignments,C] = dbscan(X,minpts,EPS)
  C = 0;
  assignments = zeros(size(X)(1),1);
  clustered = zeros(size(X)(1),1);
  for i=1: size(X)(1)
    if(clustered(i)==1)
      continue;
    endif
    clustered(i)=1;
    isneighbour = [];
    neighbourcount = 0;
    for j=1: size(X)(1)
      dist = sqrt(sum((X(i,:)-X(j,:)).^2));
      if(dist<EPS)
        neighbourcount++;
        isneighbour = [isneighbour j];
      endif
    endfor
    if(neighbourcount<minpts)
      continue;
    else
      C++;
      assignments(i) = C;
      for k=isneighbour
        if(clustered(k)==0)
          clustered(k) = 1;
          _isneighbour = [];
          _neighbourcount = 0;
          for j=1: size(X)(1)
            dist = sqrt(sum((X(k,:)-X(j,:)).^2));
            if(dist<EPS)
              _neighbourcount++;
              _isneighbour = [_isneighbour j];
            endif
          endfor
          if(_neighbourcount>=minpts)
            isneighbour = [isneighbour _isneighbour];
          endif
        endif
        assignments(k) = C;
      endfor
    endif
  endfor
