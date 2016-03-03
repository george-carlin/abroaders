const sampleData = [
  "Dave", "Robert", "Jimmy", "John", "Paul", "Kevin", "Mike", "Sarah", "Susan",
  "Drew", "Taylor", "Sue", "Claire", "Joanna",
];

window.React    = require("react");
window.ReactDOM = require("react-dom");
window.React     = require("react/addons");
window.TestUtils = React.addons.TestUtils;

console.log(ReactDOM);

const TypeaheadDropdownMenu = React.createClass({

  propTypes: {
    activeItemIndex: React.PropTypes.number.isRequired,
    hidden: React.PropTypes.bool,
    query:  React.PropTypes.string.isRequired,
    // TODO possibly make this a function so that min length must be >= 0
    queryMinLength: React.PropTypes.number.isRequired,
    items: React.PropTypes.array.isRequired,
  },


  getDefaultProps() {
    return {
      hidden: true,
    };
  },


  getInitialState() {
    return {
      style: {
        top: 0,
        left: 0
      }
    };
  },


  setMenuPosition(menu) {
    var parentEl = menu.parentElement;
    this.setState({
      style: {
        top:  parentEl.offsetTop  + parentEl.offsetHeight,
        left: parentEl.offsetLeft,
      }
    })
  },


  componentWillReceiveProps(newProps) {
    var source = function (query) {
      var items = _.select(sampleData, function (name) {
        return name.toLowerCase().indexOf(query.toLowerCase()) > -1;
      })
      this.props.processSearchResults(items);
    }.bind(this);

    var query = newProps.query;
    if (newProps.query === this.props.query) return; // query is unchanged

    if (newProps.query.length < this.props.queryMinLength) {
      return this;
      // TODO return this.shown ? this.hide() : this;
    }

    source(newProps.query);
  },


  getStyle() {
    var style = this.state.style;
    style.display = this.props.hidden ? "none" : "block";
    return style;
  },


  render() {
    var that = this;

    var items = this.props.items.slice(0, this.props.maxItemsToShow);
      
    items = _.map(items, function (item, index) {
      // TODO highlight item
      return (
        <TypeaheadItem
          active={index == that.props.activeItemIndex}
          key={index}
          onMouseEnter={that.props.onItemMouseEnter}
          onMouseLeave={that.props.onItemMouseLeave}
          text={item}
          query={that.props.query}
        />
      )
    });

    // We need to clone the style object or React raises an error:
    const style = _.clone(this.getStyle());

    return (
      <ul
        className="typeahead dropdown-menu"
        ref={this.setMenuPosition}
        role="listbox"
        style={style}
        onClick={this.props.onClick}
        onMouseEnter={this.props.onMouseEnter}
        onMouseLeave={this.props.onMouseLeave}
      >
        {items}
      </ul>
    );
  }

});
