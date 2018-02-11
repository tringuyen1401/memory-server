defmodule MemoryWeb.Game do
  @moduledoc """
  Memory keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def new() do
    %{
      cards: new_cards(),
      flip: %{},
      first: nil,
      done: 0,
      clicked: 0,
      reset: false
    }
  end

  def client_view(game) do
    cards = game.cards
    %{
      cards: cards,
      clicked: game.clicked,
      done: game.done,
      reset: game.reset
    }
  end

  def handle_click(game, id) do
    cards = game.cards
    flip = game.flip
    first = game.first
    done = game.done
    clicked = game.clicked
    len = Kernel.map_size(flip)
    cond do
      len < 1 ->
        fl = %{a: cards[id]}
        newCard = %{cards[id] | flipped: true}

        new_cards = update_card(cards, id, newCard)
        %{game | cards: new_cards, flip: fl, first: id, done: done, clicked: clicked + 1, reset: false}
      len == 1 && !(cards[id] |> Map.get(:flipped)) ->
        firstCard = flip |> Map.get(:a) |> Map.get(:value)
        new_card = cards[id]
        fl = Map.put(flip, :b, cards[id])
        if (firstCard == (new_card |> Map.get(:value))) do
          new_first_card = %{cards[first] | flipped: true, matched: true}
          new_card = %{new_card | matched: true}
          done = done + 2
          cards = update_card(cards, first, new_first_card)
        end 
        new_card = %{new_card | flipped: true}
        
        cards = update_card(cards, id, new_card)
        %{game | cards: cards, flip: fl, first: nil, done: done, clicked: clicked + 1, reset: false}      
      true ->
        game 
    end
  end

  def handle_timeout(game) do
    cards = game.cards
    if (Kernel.map_size(game.flip) == 2) do
      new_cards = Enum.into(Enum.map(cards, fn {k, v} ->
        if !(v |> Map.get(:matched) == true) do         
          {k, %{v | flipped: false}}
        else
          {k, v}
        end
      end), %{})
      fl = %{}
      first = nil
      %{game | cards: new_cards, flip: fl, first: first, reset: true}
    else
      %{game | reset: true}
    end
  end

  def update_card(cards, id, newCard) do
    Enum.into(Enum.map(cards, fn {k, v} ->
      if k == id do
        {k, newCard}
      else
        {k, v}
      end
    end), %{})
  end

  def new_cards() do
    cards = [
        %{value: "A", flipped: false, matched: false},
        %{value: "B", flipped: false, matched: false},
        %{value: "C", flipped: false, matched: false},
        %{value: "D", flipped: false, matched: false},
        %{value: "E", flipped: false, matched: false},
        %{value: "F", flipped: false, matched: false},
        %{value: "G", flipped: false, matched: false},
        %{value: "H", flipped: false, matched: false},
        %{value: "A", flipped: false, matched: false},
        %{value: "B", flipped: false, matched: false},
        %{value: "C", flipped: false, matched: false},
        %{value: "D", flipped: false, matched: false},
        %{value: "E", flipped: false, matched: false},
        %{value: "F", flipped: false, matched: false},
        %{value: "G", flipped: false, matched: false},
        %{value: "H", flipped: false, matched: false},
    ]
#    cards = Enum.shuffle(cards)
    new_map = Stream.zip(Stream.iterate(0, &(&1+1)), cards) |> Enum.into(%{})
    for {key, val} <- new_map, into: %{}, do: {Kernel.inspect(key), val}
  end
end
