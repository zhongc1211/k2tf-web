import logo from './k8s.svg';
import './App.css';
import React from 'react';
import axios from 'axios';

class Form extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: "A tool for converting Kubernetes API Objects (in YAML format) into HashiCorp's Terraform configuration language.",
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }
  
  handleChange(event) {
    this.setState({value: event.target.value});
  }

  handleSubmit(event) {
    const status = "Converting..."
    const input = this.state.value
    this.setState({value: status});
    const request = 
      { url: "https://nzqvi6dyu8.execute-api.ap-southeast-1.amazonaws.com/dev/convert",
        method: 'POST', 
        headers: {'Content-Type': 'XMLHttpRequest'},
        data: {
          "OverwriteExisting": false,
          "Debug": false,
          "Input": input,
          "Output": "Output",
          "InputUnsupported": false,
          "TF12Format": false,
          "PrintVersion": false
        }
      };

    axios(request)
      .then(response => {
        this.setState({value: response.data});
      })
      .catch(error => {
        console.log(error)
        this.setState({value: error + "\n\n" + input})
      });
    event.preventDefault();
  }

  

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Convert:
          <textarea style={{height: "500px", width: "800px"}} value={this.state.value} onChange={this.handleChange} />
        </label>
        <input type="submit" value="Submit" />
      </form>
      
    );
  }
}

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <Form/>  

      </header> 
    </div>
  );
}

export default App;
