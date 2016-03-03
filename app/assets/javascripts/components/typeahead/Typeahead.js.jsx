const React = require("react");

const Typeahead = React.createClass({

  propTypes: {
    maxItemsToShow: React.PropTypes.number,
    minLength: (props, propName, componentName) => {
      if (!(typeof props[propName] === "number" && props[propName] >= 1)) {
        return new Error(propName + " must be greater than 0");
      }
    },
  },


  getDefaultProps() {
    return {
      maxItemsToShow: 8,
      minLength:      1,
    };
  },


  getInitialState() {
    return {
      activeItemIndex: 0,
      inputFocused:    false,
      inputMousedover: false, // TODO what if m is over when component renders?
      result:          "",
      query:           "",
      isSearching:     false,
      items:           [],
      showDropdown:    false,
      suppressKeyPressRepeat: false,
    };
  },


  onInputBlur() {
    console.log("onInputBlur");
    var newState = { inputFocused: false };
    if (!this.state.inputMousedover) newState.showDropdown = false;
    this.setState(newState);
  },


  onInputChange(e) {
    this.setState({ isSearching: true, query: e.target.value });
  },


  onInputFocus() {
    console.log("onInputFocus");
    this.setState({ inputFocused: true });
  },


  // TODO what to do with this?
  onInputKeyDown(e) {
    var suppress = ~$.inArray(e.keyCode, [40,38,9,13,27]);
    this.setState({ suppressKeyPressRepeat: suppress });

    if (!this.state.showDropdown && e.keyCode == 40 /* down arrow */) {
      // TODO original code was `this.lookup()`. How to handle this?
      // this.setState({ query: e.target.value });
    } else {
      var resultsLength = this.state.items.length;
      // Skip if shift is held or there's not enough results to scroll through
      if (e.shiftKey || resultsLength <= 1) {
        return;
      }

      if (e.keyCode === 38) { // up arrow
        if (this.state.activeItemIndex === 0) {
          this.setState({ activeItemIndex: resultsLength - 1 });
        } else {
          this.setState({ activeItemIndex: this.state.activeItemIndex - 1 })
        }
      } else if (e.keyCode === 40) { // down arrow
        if (this.state.activeItemIndex == resultsLength - 1) {
          this.setState({ activeItemIndex: 0 })
        } else {
          this.setState({ activeItemIndex: this.state.activeItemIndex + 1 })
        }
      }
    }
  },


  onInputKeyPress(e) {
    // Remember, the input is the one that receives the keys, even when
    // scrolling up and down the menu and selecting a result.
    // console.log("keypress: " + e.keyCode);
    switch (e.charCode) {
      case 38: // up arrow
      case 40: // down arrow
      case 16: // shift
      case 17: // ctrl
      case 18: // alt
        break;

      case  9: // tab
      case 13: // enter
        console.log("tab or enter");
        if (!this.state.showDropdown) return;
        console.log("about to select:")
        this.select();
        break;

      case 27: // escape
        this.setState({ showDropdown: false });
        break;
    };
  },


  onMenuClick(e) {
    console.log("onMenuClick");
    e.preventDefault();
    this.select();
  },


  onMenuItemMouseEnter(e) {
    // console.log("onMenuItemMouseEnter");
    // console.log("setting activeItemIndex to " + $(e.currentTarget).index());
    this.setState({
      activeItemIndex: $(e.currentTarget).index(),
      inputMousedover: true,
    });
  },


  onMenuItemMouseLeave() {
    var newState = { inputMousedover: false }; 
    if (!this.state.inputFocused) newState.showDropdown = false;
    this.setState(newState);
  },


  processSearchResults(results) {
    // TODO apply matcher and sorter
    this.setState({
      items:        results,
      showDropdown: (results.length ? true : false),
    });
  },


  select() {
    this.setState({
      activeItemIndex: 0,
      isSearching:  false,
      items:        [],
      result:      this.state.items[this.state.activeItemIndex],
      showDropdown: false,
    });
  },


  render() {
    // console.log(JSON.stringify(this.state));
    var value = this.state.isSearching ? this.state.query : this.state.result;
    // console.log("isSearching: " + this.state.isSearching)
    // console.log("value: " + value)
    return (
      <div className="Typeahead">
        <input
          autoComplete="off"
          className="TypeaheadInput form-control"
          onBlur={this.onInputBlur}
          onChange={this.onInputChange}
          onFocus={this.onInputFocus}
          onKeyDown={this.onInputKeyDown}
          onKeyPress={this.onInputKeyPress}
          value={value}
        />

        <TypeaheadDropdownMenu
          activeItemIndex={this.state.activeItemIndex}
          hidden={!this.state.showDropdown}
          items={this.state.items}
          processSearchResults={this.processSearchResults}
          onClick={this.onMenuClick}
          onItemMouseEnter={this.onMenuItemMouseEnter}
          onItemMouseLeave={this.onMenuItemMouseLeave}
          query={this.state.query}
          queryMinLength={this.props.minLength}
        />
      </div>
    )
  },

});
