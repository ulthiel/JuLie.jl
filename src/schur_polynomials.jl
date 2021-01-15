################################################################################
# Schur Polynomials
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

import AbstractAlgebra: PolynomialRing, push_term!, MPolyBuildCtx, finish
import Nemo: ZZ, fmpz, fmpz_mpoly

export schur_polynomial


"""
    schur_polynomial(shp::Partition)

returns the Schur function ``s_{shp}`` as a Multivariate Polynomial.

```math
s_{shp}:=∑_{T} x_1^{m_1}…x_n^{m_n}
```

where the sum is taken over all **semistandard tableaux** ``T`` of shape ``shp``, and ``m_i`` gives the weight of ``i`` in ``T``.
"""
function schur_polynomial(shp::Partition{T}) where T<:Integer
  num_boxes = sum(shp)
  x = [string("x",string(i)) for i=1:num_boxes]
  R,x = PolynomialRing(ZZ, x)

  sf = MPolyBuildCtx(R)

  #version of the function semistandard_tableaux(shape::Array{T,1}, max_val=sum(shape)::Integer)
  len = length(shp)
  Tab = [(fill(i,shp[i])) for i = 1:len]
  m = len
  n = shp[m]

  count = zeros(Int, num_boxes)

  while true
    count .= 0
    for i = 1:len
      for j = 1:shp[i]
        count[Tab[i][j]] += 1
      end
    end
    push_term!(sf, ZZ(1), count)

    #raise one element by 1
    while !(Tab[m][n] < num_boxes &&
      (n==shp[m] || Tab[m][n]<Tab[m][n+1]) &&
      (m==len || shp[m+1]<n || Tab[m][n]+1<Tab[m+1][n]))
      if n > 1
        n -= 1
      elseif m > 1
        m -= 1
        n = shp[m]
      else
        return finish(sf)
      end
    end

    Tab[m][n] += 1

    #minimize trailing elements
    if n < shp[m]
      i = m
      j = n + 1
    else
      i = m + 1
      j = 1
    end
    while (i<=len && j<=shp[i])
      if i == 1
        Tab[1][j] = Tab[1][j-1]
      elseif j == 1
        Tab[i][1] = Tab[i-1][1] + 1
      else
        Tab[i][j] = max(Tab[i][j-1], Tab[i-1][j] + 1)
      end
      if j < shp[i]
        j += 1
      else
        j = 1
        i += 1
      end
    end
    m = len
    n = shp[len]
  end #while
end
