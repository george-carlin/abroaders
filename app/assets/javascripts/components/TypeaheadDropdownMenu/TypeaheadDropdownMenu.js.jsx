const React = require("react");
const _ = require("underscore");
const $ = require("jquery");

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
                text={item.name}
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
