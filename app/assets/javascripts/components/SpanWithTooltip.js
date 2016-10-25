/* global $ */
import { createElement, createClass, PropTypes } from "react";

const SpanWithTooltip = createClass({
  componentDidMount() {
    $(this._ref).tooltip();
  },

  setRef(ref) {
    this._ref = ref;
  },

  render() {
    return createElement(
      "span",
      {
        children:      this.props.children,
        className:     "SpanWithTooltip",
        "data-title":  this.props.title,
        "data-toggle": "tooltip",
        ref:           this.setRef,
      }
    );
  },
});

SpanWithTooltip.propTypes = {
  title: PropTypes.string.isRequired,
};

module.exports = SpanWithTooltip;
