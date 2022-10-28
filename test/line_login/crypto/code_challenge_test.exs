defmodule LineLogin.Crypto.CodeChallengeTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias LineLogin.Crypto.CodeChallenge

  describe "given LineLogin.Crypto.CodeChallenge::generate_code_verifier/0" do
    test "it returns string of 64 characters length" do
      assert 64 = String.length(CodeChallenge.generate_code_verifier())
    end

    test "it contains only allowed characters" do
      result = CodeChallenge.generate_code_verifier()
      assert String.match?(result, ~r/[A-Za-z_-]/)
      refute String.match?(result, ~r/[=\+\/]/)
    end
  end

  describe "given LineLogin.Crypto.CodeChallenge::get_code_challenge/1" do
    setup do
      [
        fake_code: "ASDQWEZXC12345678"
      ]
    end

    test "it returns code_challenge_method as :S256 atom", %{fake_code: fake_code} do
      assert %{code_challenge_method: :S256} = CodeChallenge.get_code_challenge(fake_code)
    end

    test "it returns string of 64 characters length", %{fake_code: fake_code} do
      %{code_challenge: code_challenge} = CodeChallenge.get_code_challenge(fake_code)
      assert 43 = String.length(code_challenge)
    end

    test "it contains only allowed characters", %{fake_code: fake_code} do
      %{code_challenge: result} = CodeChallenge.get_code_challenge(fake_code)

      assert String.match?(result, ~r/[A-Za-z_-]/)
      refute String.match?(result, ~r/[=\+\/]/)
    end
  end
end
