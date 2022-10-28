defmodule LineLogin.Crypto.StringGeneratorTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias LineLogin.Crypto.StringGenerator

  describe "given LineLogin.Crypto.StringGenerator::generate_string/1" do
    test "it returns string with requested length" do
      assert 42 = String.length(StringGenerator.generate_string(42))
      assert 1 = String.length(StringGenerator.generate_string(1))
    end

    test "it contains only allowed characters" do
      result = StringGenerator.generate_string(128)
      assert String.match?(result, ~r/[A-Za-z_-]/)
      refute String.match?(result, ~r/[=\+]/)
    end
  end
end
