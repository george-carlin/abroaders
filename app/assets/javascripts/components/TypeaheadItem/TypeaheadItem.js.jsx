const React = require("react");

const TypeaheadItem = React.createClass({

  propTypes: {
    active : React.PropTypes.bool,
    query  : React.PropTypes.string.isRequired,
    text   : React.PropTypes.string.isRequired,
  },


  highlightedText() {
    const query = this.props.query;
    var   item  = this.props.text;

    var i = item.toLowerCase().indexOf(query.toLowerCase());
    var leftPart, middlePart, rightPart, key;
    const len = query.length;

    if (len === 0){
      els = item;
    } else {
      key = 0;
      els = [];
      while (i > -1) {
        leftPart   = item.substr(0, i);
        middlePart = item.substr(i, len);
        rightPart  = item.substr(i + len);
        els.push(<span key={key}>{leftPart}</span>);
        els.push(<strong key={key + 1}>{middlePart}</strong>);
        key += 2;
        item = rightPart;
        i = item.toLowerCase().indexOf(query.toLowerCase());
      }
      els.push(<span key={key}>{item}</span>);
    }
    return els;
  },


  render() {
    return (
      <li
        className={`TypeaheadItem ${this.props.active ? "active" : ""}`}
        {...this.props}
      >
        <a className="dropdown-item" href="#" role="option">
          {this.highlightedText()}
        </a>
      </li>
    );
  },

});


module.exports = TypeaheadItem;
