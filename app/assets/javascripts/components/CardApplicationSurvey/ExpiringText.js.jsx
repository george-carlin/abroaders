import React from "react";

// Text that disappears after a delay (default 2 seconds). Heavily inspired by
// http://stackoverflow.com/a/24172140/1603071 . Note that this could be
// converted into a more generic 'wrap anything in this component to make it
// disappear after a delay' component with a small amount of work, if we need
// it.
const ExpiringText = React.createClass({
  getDefaultProps() {
    return {delay: 2000};
  },

  getInitialState() {
    return { visible: true };
  },

  componentDidMount() {
    // clear any existing timer
    if (this._timer) clearTimeout(this._timer);

    // hide after `delay` milliseconds
    this._timer = setTimeout(() => {
      this.setState({ visible: false });
      this._timer = null;
    }, this.props.delay);
  },

  componentWillUnmount() {
    clearTimeout(this._timer);
  },

  render() {
    return this.state.visible
      ? <span className="ExpiringText">{this.props.text}</span>
      : <noscript />;
  },
});

export default ExpiringText;
