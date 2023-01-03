defmodule CanonicalLogs.Support.TestSchema do
  use Absinthe.Schema

  object :user do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
    field(:email, non_null(:string))
  end

  input_object :signup_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
    field(:password_confirmation, non_null(:string))
  end

  query do
    field :create_user, :user do
      arg(:name, non_null(:string))
      arg(:signup_input, non_null(:signup_input))

      resolve(fn args, _ ->
        {:ok, %{id: 1, name: args.name, email: args.signup_input.email}}
      end)
    end
  end

  def middleware(middleware, _, _) do
    if Enum.member?(middleware, CanonicalLogs.AbsintheMiddleware) do
      middleware
    else
      middleware ++ [CanonicalLogs.AbsintheMiddleware]
    end
  end
end
