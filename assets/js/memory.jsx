import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function game_init(root, channel) {
  ReactDOM.render(<MemoryGame channel={channel}/>, root);
}

class MemoryGame extends React.Component {
  constructor(props) {
  super(props);
    this.channel = props.channel;
    this.state = { 
      cards: [],
      flip: [],
      first: null,
      done: 0,
      clicked: 0,
      reset: false};
    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("MemoryGame Unable to join", resp) });
  }

  gotView(view) {
    this.setState(view.game, this.checkBoard(view.game.reset));
  }

  sendClick(id) {
    this.channel.push("guess", { id: id, cards: this.state.cards })
      .receive("ok", this.gotView.bind(this));
    setTimeout(() => {
      this.channel.push("timeout", { id: id, cards: this.state.cards })
        .receive("ok", this.gotView.bind(this))
    }, 500)
  }

  checkBoard(flag) {
    var done = this.state.done;
    if (done >= 16 && flag) {
      alert("Board cleared! Generating new board!")
      this.restartGame();
    }
  }

  restartGame() {
    this.channel.push("reset", { cards: this.state.cards })
      .receive("ok", this.gotView.bind(this));
  }  

  render() {
    return (
      <div className="row">
        <Button className="col" onClick={this.restartGame.bind(this)}>Restart!</Button>
        <div className="col-6">
          <span className="score">Score:{this.state.clicked}</span>
        </div>
        <div className="col">
          &nbsp;
        </div>
        <Board cards={this.state.cards} sendClick={this.sendClick.bind(this)}/>
      </div>
    );
  }
}

function Board(params) {
  let cards = params.cards
  let cardsSet = _.map(cards, (card, ii) => {
    return <Card id={ii} card={card} key={ii} sendClick={params.sendClick}/>;
  });
  return (
    <div className="board">
      {cardsSet}
    </div>
  );

}

function Card(params) {
  let card = params.card
  let text = params.card.flipped? params.card.value : "?"
  text = params.card.matched? "✓" : text
  let id = params.id
  function cardClicked(e) {
    params.sendClick(id)
  }

  return (
    <div id={id} className="card" onClick={cardClicked}>
      {text}
    </div>
  );
}
