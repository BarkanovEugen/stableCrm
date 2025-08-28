defmodule StableCrmWeb.PageController do
  use StableCrmWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
