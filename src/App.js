
import React from 'react';
import logo from './logo.svg';
import './App.css' ;


// function Hello(props){

//   return <h2> {props.title} </h2>
// }
// const Hello =(props) => <h2>{props.title}</h2>
class Hello extends React.Component {
  render() {
    return <h1>Hello,World {this.props.name}</h1>;
  }
}




function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <Hello title="xddddddd"/>
        <a
          className="App-link"
          href="https://www.cavetech.pe"
          target="_blank"
          rel="noopener noreferrer"
        >
        
          https://www.cavetech.pe/
        </a>
      </header>
    </div>
  );
}

export default App;
