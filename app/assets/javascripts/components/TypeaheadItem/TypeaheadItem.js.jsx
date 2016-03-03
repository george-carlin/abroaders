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

    var   i = item.toLowerCase().indexOf(query.toLowerCase());
    var   leftPart, middlePart, rightPart, els;
    const len = query.length;

    if (len === 0){
      els = item;
    } else {
      els = [];
      while (i > -1) {
        leftPart   = item.substr(0, i);
        middlePart = item.substr(i, len);
        rightPart  = item.substr(i + len);
        els.push(leftPart);
        els.push(<strong>{middlePart}</strong>);
        item = rightPart;
        i = item.toLowerCase().indexOf(query.toLowerCase());
      }
      els.push(item);
    }
    return els;
  },


  render() {
    return (
      <li
        className={this.props.active ? "active" : ""}
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
