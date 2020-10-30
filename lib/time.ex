defmodule Namy.Time do
  def now do
    {h, m, s} = :erlang.time()
    h * 3600 + m * 60 + s
  end

  def inf do
    :inf
  end

  def add(s, t) do
    s + t
  end

  def valid?(c, t) do
    c > t
  end
end
