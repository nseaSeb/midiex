defmodule MidiexWeb.UserLoginLive do
  use MidiexWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm bg-white p-8">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore" >
        <.field field={@form[:email]} type="email" label="Email" required />
        <.field field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.field field={@form[:remember_me]} type="checkbox" label="Resté connecté" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Mot de passe oublié ?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     socket
     |> assign(:active_tab, :login)
     |> assign(form: form), temporary_assigns: [form: form]}
  end
end
