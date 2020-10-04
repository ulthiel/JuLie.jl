################################################################################
# Tableaux
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export Tableau, shape

struct Tableau{T} <: AbstractArray{AbstractArray{T,1},1}
   t::Array{Array{T,1},1}
end

function Base.show(io::IO, ::MIME"text/plain", Tab::Tableau)
  print(io, Tab.t)
end

function Base.size(Tab::Tableau)
  return size(Tab.t)
end

function Base.length(Tab::Tableau)
  return length(Tab.t)
end

function Base.getindex(Tab::Tableau, i::Int)
  return getindex(Tab.t,i)
end

function Base.getindex(Tab::Tableau, I::Vararg{Int, 2})
  return getindex(getindex(Tab.t,I[1]), I[2])
end

function shape(Tab::Tableau{T}) where T
  return Partition{T}([ length(Tab[i]) for i=1:length(Tab) ])
end
