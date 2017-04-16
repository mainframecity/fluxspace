defmodule Fluxspace.Determiners do
  @moduledoc """
  Adds in a generic determiner to a noun.
  """

  @vowels 'aeiouAEIOU'

  def determine(<<vowel>> <> _ = word) when vowel in @vowels do
    "an #{word}"
  end

  def determine(word) do
    "a #{word}"
  end
end
