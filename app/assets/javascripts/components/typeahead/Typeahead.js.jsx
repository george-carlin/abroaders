const React = require("react");
const $     = require("jquery");

const DestinationSearchEngine =
  require("../../modules/DestinationSearchEngine");
const LoadingSpinner          = require("../LoadingSpinner");
const TypeaheadDropdownMenu   = require("../TypeaheadDropdownMenu");

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
      // Note: if you change this, you'll probably need to change the 'limit'
      // line in DestinationSearchEngine too:
      maxItemsToShow: 8,
      minLength:      1,
      // Use a default prop for this so we can override it with a mock
      // during testing:
      source: (a,b,c,d,e) => {
        DestinationSearchEngine.search(a,b,c,d,e);
      },
    };
  },


  getInitialState() {
    return {
      activeItemIndex: 0,
      inputFocused:    false,
      inputMousedover: false, // TODO what if m is over when component renders?
      result:          "",
      query:           "",
      isLoading:       false,
      isSearching:     false,
      items:           [],
      showDropdown:    false,
      suppressKeyPressRepeat: false,
    };
  },


  onInputBlur() {
    var newState = { inputFocused: false };
    if (!this.state.inputMousedover) newState.showDropdown = false;
    this.setState(newState);
  },


  onInputChange(e) {
    var query = e.target.value.trim().toLowerCase();

    // skip if query is unchanged
    if (this.state.query.trim().toLowerCase === query) return;

    if (query.length < this.props.queryMinLength) return;

    this.search(query);
  },


  onInputFocus() {
    this.setState({ inputFocused: true });
  },


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
        // Highlight the next item up. If the top item is highlighted, loop
        // around to the bottom item.
        if (this.state.activeItemIndex === 0) {
          this.setState({ activeItemIndex: resultsLength - 1 });
        } else {
          this.setState({ activeItemIndex: this.state.activeItemIndex - 1 })
        }
      } else if (e.keyCode === 40) { // down arrow
        // Highlight the next item down. If the bottom item is highlighted,
        // loop around to the top item.
        if (this.state.activeItemIndex == resultsLength - 1) {
          this.setState({ activeItemIndex: 0 })
        } else {
          this.setState({ activeItemIndex: this.state.activeItemIndex + 1 })
        }
      }
    }
  },


  onInputKeyPress(e) {
    if (this.state.suppressKeyPressRepeat) return;
    // Remember, the input is the one that receives the keys, even when
    // scrolling up and down the menu and selecting a result.
    switch (e.charCode) {
      case 38: // up arrow
      case 40: // down arrow
      case 16: // shift
      case 17: // ctrl
      case 18: // alt
        break;

      case  9: // tab
      case 13: // enter
        if (!this.state.showDropdown) return;
        this.select(this.state.items[this.state.activeItemIndex]);
        break;

      case 27: // escape
        this.setState({ showDropdown: false });
        break;
    };
  },


  onMenuClick(e) {
    e.preventDefault();
    this.select(e.target.textContent);
  },


  onMenuItemMouseEnter(e) {
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


  select(item) {
    this.setState({
      activeItemIndex: 0,
      isSearching:  false,
      items:        [],
      result:       item,
      showDropdown: false,
    });
  },


  search(query) {
    const that = this;

    this.setState({
      isLoading:   true,
      isSearching: true,
      query:       query,
    });

    this.props.source(
      query,
      // This first callback is passed any results that bloodhound pulls from
      // the local cache. At the moment we're not caching anything locally
      // (which we should! TODO), so this callback will always be passed an
      // empty array; so just make it a noop for now:
      $.noop,
      // This callback will be called asynchronously with any results that
      // DestinationSearchEngine pulls from the API (via bloodhound).
      (results) => {
        // Bloodhound is done searching, so hide the loading spinner:
        this.setState({isLoading: false });
        this.processSearchResults(results);
      }
    )

    // The actual results will be handled in the 'processSynchronously' and
    // 'processAsynchronously' callbacks that were passed to `bloodhound`
    // above. In the meantime just return an empty array (because we
    // haven't loaded any results at this point):
    return [];
  },


  render() {
    var value = this.state.isSearching ? this.state.query : this.state.result;
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
        <LoadingSpinner hidden={!this.state.isLoading} />

        <TypeaheadDropdownMenu
          activeItemIndex={this.state.activeItemIndex}
          hidden={!this.state.showDropdown}
          items={this.state.items}
          maxItemsToShow={this.props.maxItemsToShow}
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

module.exports = Typeahead;
