const React = require("react");
const _ = require("underscore");
const $ = require("jquery");

// TODO delete me once we've set 'source' up properly:

const sampleData = [
  "Dave", "Robert", "Jimmy", "John", "Paul", "Kevin", "Mike", "Sarah", "Susan",
  "Drew", "Taylor", "Sue", "Claire", "Joanna",
];

const TypeaheadItem = require("../TypeaheadItem")

const TypeaheadDropdownMenu = React.createClass({

  propTypes: {
    activeItemIndex: React.PropTypes.number.isRequired,
    hidden: React.PropTypes.bool,
    query:  React.PropTypes.string.isRequired,
    // TODO possibly make this a function so that min length must be >= 0
    queryMinLength: React.PropTypes.number.isRequired,
    items: React.PropTypes.array,
  },


  getDefaultProps() {
    return {
      items:  [],
    };
  },


  getInitialState() {
    return {
      style: {
        top:  0,
        left: 0,
      },
    };
  },


  componentWillReceiveProps(newProps) {
    const source = (query) => {
      var items = _.select(sampleData, (name) => {
        return name.toLowerCase().indexOf(query.toLowerCase()) > -1;
      });
      this.props.processSearchResults(items);
    };

    const query = newProps.query;
    if (newProps.query === this.props.query) return; // query is unchanged

    if (newProps.query.length < this.props.queryMinLength) {
      return this;
      // TODO return this.shown ? this.hide() : this;
    }

    source(newProps.query);
  },


  getStyle() {
    const style = this.state.style;
    style.display = this.props.hidden ? "none" : "block";
    return style;
  },


  setMenuPosition(menu) {
    const parentEl = menu.parentElement;
    this.setState({
      style: {
        top:  parentEl.offsetTop  + parentEl.offsetHeight,
        left: parentEl.offsetLeft,
      }
    })
  },


  render() {
    // (We need to clone the result of `getStyle` or React raises an error)
    return (
      <ul
        className="TypeaheadDropdownMenu typeahead dropdown-menu"
        ref={this.setMenuPosition}
        role="listbox"
        style={_.clone(this.getStyle())}
        {...this.props}
      >
        {(() => {
          const items = this.props.items.slice(0, this.props.maxItemsToShow);
          return _.map(items, (item, index) => {
            return (
              <TypeaheadItem
                active={index == this.props.activeItemIndex}
                key={index}
                onMouseEnter={this.props.onItemMouseEnter}
                onMouseLeave={this.props.onItemMouseLeave}
                text={item}
                query={this.props.query}
              />
            );
          });
        })()}
      </ul>
    );
  }

});

module.exports = TypeaheadDropdownMenu;
